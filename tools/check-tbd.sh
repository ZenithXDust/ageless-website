#!/usr/bin/env sh
#
# check-tbd.sh
#
# Reports the state of every placeholder on the site. Run it before merging.
#
#   tools/check-tbd.sh              all three states, the counts, an exit code
#   tools/check-tbd.sh --by-token   the same thing grouped by token
#
# There are THREE states, and the third is the one that matters most.
#
#   1. UNDECIDED, and blocking. A fact nobody has settled yet.
#
#        <span class="tbd" data-tbd="PACKAGE_1_PRICE">Call for pricing</span>
#
#      Counted, listed, and it makes the script exit nonzero.
#
#   2. SETTLED, and centralised. A fact that IS decided, but which is written
#      into more than one page and would drift out of step if every page
#      carried its own wording.
#
#        <span class="settled" data-settled="VISIT_MODEL">a free twenty
#        minute phone call</span>
#
#      Reported, never counted, never blocks. Nothing is waiting on it.
#
#   3. EXPECTED BUT MISSING. A page that the manifest says must carry a token
#      does not carry it.
#
#      This is the important one, because its evidence is an absence and no
#      amount of counting what is present can find it. Without this check the
#      script reports a clean pass at the exact moment the work has not
#      started: no tokens placed anywhere means nothing outstanding means
#      exit zero, which is a green light pointing the wrong way. It also
#      catches somebody quietly typing a real number over a placeholder
#      without telling anybody.
#
#      The manifest lives in PLACEHOLDERS.md between the MANIFEST-START and
#      MANIFEST-END markers, so there is one list and it sits next to the
#      documentation it describes.
#
# There is also a tripwire. The preview site carries a robots noindex tag,
# injected at publish time into the preview repository only. If that tag ever
# gets committed here, merging it would tell search engines to drop the real
# site. The tripwire fails if it appears anywhere in the tracked tree apart
# from an allowlist of tooling and documentation that has to mention it. The
# allowlist is printed when the script runs, so the exemption is visible.
#
# Exit codes:
#
#   0  clean. Nothing undecided is present and nothing expected is missing.
#      Settled tokens may still exist, and that is correct.
#   1  work remains. An undecided token is on a page, or a page named in the
#      manifest is missing a token it should carry.
#   2  a fault. Text that must not be published, the tripwire, or a scan that
#      could not run.

set -u

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd) || exit 2
cd "$ROOT" || exit 2

MODE="${1:-list}"

# Every HTML page at the root. design/logo-concepts.html is deliberately
# excluded: it is a working document about the logo, not a page of the site.
FILES=$(ls -1 ./*.html 2>/dev/null | sed 's|^\./||')

if [ -z "$FILES" ]; then
  echo "check-tbd.sh: no HTML files found in $ROOT"
  exit 2
fi

# --------------------------------------------------------------------------
# The scan.
#
# Deliberately ONE pass of awk rather than several grep-into-sed pipelines.
# Each pipeline stage is another process, and on Git Bash under Windows
# process creation fails intermittently. During development one stage
# returned nothing and the script cheerfully reported zero placeholders on a
# file that had four. A check that can quietly undercount is worse than no
# check, so this runs as a single process whose exit status is tested.
#
# Rows are tab separated:
#   OPEN     TOKEN  file  line
#   SETTLED  TOKEN  file  line
#   BAD      TOKEN  file  line  text
# --------------------------------------------------------------------------
SCAN=$(awk '
  function emit(kind, attr,   rest, tok) {
    rest = $0
    while (match(rest, "data-" attr "=\"[A-Z0-9_]+\"")) {
      tok = substr(rest, RSTART, RLENGTH)
      sub("data-" attr "=\"", "", tok)
      sub("\"$", "", tok)
      print kind "\t" tok "\t" FILENAME "\t" FNR
      rest = substr(rest, RSTART + RLENGTH)
    }
  }

  {
    emit("OPEN", "tbd")
    emit("SETTLED", "settled")

    # Whole spans, so the text inside can be checked against the rule. This
    # reads spans written on one line, which is how they are written here.
    rest = $0
    while (match(rest, "<span class=\"(tbd|settled)\" data-(tbd|settled)=\"[A-Z0-9_]+\">[^<]*</span>")) {
      span = substr(rest, RSTART, RLENGTH)
      rest = substr(rest, RSTART + RLENGTH)

      tok = span
      sub(/^.*data-(tbd|settled)="/, "", tok)
      sub(/".*$/, "", tok)

      text = span
      sub(/^[^>]*>/, "", text)
      sub(/<\/span>$/, "", text)
      gsub(/^[ \t]+|[ \t]+$/, "", text)

      up = toupper(text)
      if (text == "" || text == "$" ||
          up == "TODO" || up == "TBD" || up == "XXX" || up == toupper(tok)) {
        print "BAD\t" tok "\t" FILENAME "\t" FNR "\t" text
      }
    }
  }
' $FILES)

if [ $? -ne 0 ]; then
  echo "check-tbd.sh: the scan failed to run. Refusing to report a count."
  exit 2
fi

rows() {
  printf '%s\n' "$SCAN" | awk -F'\t' -v k="$1" '$1 == k { print $2 "\t" $3 "\t" $4 }' | sort -u
}

OPEN=$(rows OPEN)
SETTLED=$(rows SETTLED)
BAD=$(printf '%s\n' "$SCAN" | awk -F'\t' '$1 == "BAD" { printf "%s:%s  %s  text is \"%s\"\n", $3, $4, $2, $5 }' | sort -u)

count()  { printf '%s' "$1" | awk 'NF { n++ } END { print n + 0 }'; }
tokens() { printf '%s\n' "$1" | awk -F'\t' 'NF { print $1 }' | sort -u; }

OPEN_COUNT=$(count "$OPEN")
SETTLED_COUNT=$(count "$SETTLED")
BAD_COUNT=$(count "$BAD")

OPEN_TOKENS=$(tokens "$OPEN")
SETTLED_TOKENS=$(tokens "$SETTLED")

OPEN_DISTINCT=$(count "$OPEN_TOKENS")
SETTLED_DISTINCT=$(count "$SETTLED_TOKENS")

# --------------------------------------------------------------------------
# The manifest, and the expected-but-missing check.
# --------------------------------------------------------------------------
MANIFEST_FILE="PLACEHOLDERS.md"
MANIFEST=""

if [ -f "$MANIFEST_FILE" ]; then
  MANIFEST=$(awk '
    /MANIFEST-START/ { inside = 1; next }
    /MANIFEST-END/   { inside = 0 }
    inside {
      line = $0
      sub(/^[ \t]+/, "", line)
      if (line ~ /^#/)   next
      if (line ~ /^```/) next
      if (line == "")    next
      print line
    }
  ' "$MANIFEST_FILE")
fi

if [ -z "$MANIFEST" ]; then
  echo "check-tbd.sh: no manifest found in $MANIFEST_FILE."
  echo "Expected a list between MANIFEST-START and MANIFEST-END."
  exit 2
fi

# For every token and page the manifest names, confirm the page carries it.
PRESENT=$(printf '%s\n%s\n' "$OPEN" "$SETTLED" | awk -F'\t' 'NF { print $1 " " $2 }' | sort -u)

MISSING=$(printf '%s\n' "$MANIFEST" | awk -v present="$PRESENT" '
  BEGIN {
    n = split(present, lines, "\n")
    for (i = 1; i <= n; i++) if (lines[i] != "") have[lines[i]] = 1
  }
  NF >= 2 {
    tok = $1
    for (i = 2; i <= NF; i++) {
      if (!((tok " " $i) in have)) print $i "  is missing  " tok
    }
  }
' | sort -u)

MISSING_COUNT=$(count "$MISSING")

# --------------------------------------------------------------------------
# The tripwire.
#
# The needle is assembled from two halves so that this script does not match
# itself, and a short allowlist covers the files that have to discuss it.
# Tracked files only, because scratch files are not what gets merged.
# --------------------------------------------------------------------------
NEEDLE="no""index"
ALLOWLIST="tools/check-tbd.sh tools/deploy-preview.sh PLACEHOLDERS.md CLAUDE.md README.md"

TRACKED=$(git ls-files 2>/dev/null)
if [ -z "$TRACKED" ]; then
  TRACKED=$(ls -1 ./*.html css/*.css js/*.js 2>/dev/null | sed 's|^\./||')
fi

TRIPPED=$(printf '%s\n' "$TRACKED" | awk -v allow="$ALLOWLIST" '
  BEGIN { n = split(allow, a, " "); for (i = 1; i <= n; i++) skip[a[i]] = 1 }
  NF && !($0 in skip) { print }
' | while IFS= read -r f; do
  [ -f "$f" ] || continue
  grep -l -- "$NEEDLE" "$f" 2>/dev/null
done)

TRIPPED_COUNT=$(count "$TRIPPED")

# --------------------------------------------------------------------------
# Report
# --------------------------------------------------------------------------
print_group() {
  for t in $2; do
    echo "$t"
    printf '%s\n' "$1" | awk -F'\t' -v tok="$t" 'NF && $1 == tok {print "    " $2 ":" $3}'
    echo
  done
}

if [ "$MODE" = "--by-token" ]; then
  echo "Placeholders by token"
  echo "====================="
  echo
  echo "UNDECIDED, and blocking"
  echo "-----------------------"
  echo
  if [ "$OPEN_COUNT" -eq 0 ]; then echo "None."; echo; else print_group "$OPEN" "$OPEN_TOKENS"; fi
  echo "SETTLED, and centralised"
  echo "------------------------"
  echo
  if [ "$SETTLED_COUNT" -eq 0 ]; then echo "None."; echo; else print_group "$SETTLED" "$SETTLED_TOKENS"; fi
  echo "EXPECTED BUT MISSING"
  echo "--------------------"
  echo
  if [ "$MISSING_COUNT" -eq 0 ]; then echo "None."; else printf '%s\n' "$MISSING" | awk 'NF {print "  " $0}'; fi
  echo
else
  echo "Placeholders"
  echo "============"
  echo
  echo "1. UNDECIDED, and blocking. These are what you still have to decide."
  echo
  if [ "$OPEN_COUNT" -eq 0 ]; then
    echo "  None."
  else
    printf '%s\n' "$OPEN" | awk -F'\t' 'NF {printf "  %-22s %s:%s\n", $1, $2, $3}'
  fi
  echo
  echo "  $OPEN_COUNT present, $OPEN_DISTINCT distinct token(s)."
  echo
  echo "2. SETTLED, and centralised. Decided, kept in one place so the wording"
  echo "   cannot drift between pages. Reported only, never counted."
  echo
  if [ "$SETTLED_COUNT" -eq 0 ]; then
    echo "  None."
  else
    printf '%s\n' "$SETTLED" | awk -F'\t' 'NF {printf "  %-22s %s:%s\n", $1, $2, $3}'
  fi
  echo
  echo "  $SETTLED_COUNT present, $SETTLED_DISTINCT distinct token(s)."
  echo
  echo "3. EXPECTED BUT MISSING. Pages the manifest says must carry a token"
  echo "   and do not. An absence, which counting what is present cannot find."
  echo
  if [ "$MISSING_COUNT" -eq 0 ]; then
    echo "  None. Every page named in the manifest carries what it should."
  else
    printf '%s\n' "$MISSING" | awk 'NF {print "  " $0}'
  fi
  echo
  echo "  $MISSING_COUNT missing."
  echo
  echo "  Plain English for every token is in PLACEHOLDERS.md."
  echo "  Tripwire allowlist: $ALLOWLIST"
fi

# --------------------------------------------------------------------------
# Exit
# --------------------------------------------------------------------------
if [ "$TRIPPED_COUNT" -gt 0 ]; then
  echo
  echo "TRIPWIRE: the preview-only robots tag is present in files that get merged."
  echo "Merging that would tell search engines to drop the real site. Remove it:"
  echo
  printf '%s\n' "$TRIPPED" | awk 'NF {print "  " $0}'
  exit 2
fi

if [ "$BAD_COUNT" -gt 0 ]; then
  echo
  echo "PROBLEM: $BAD_COUNT placeholder(s) have text that must not be published."
  echo "Every placeholder has to read as a true sentence on its own. These do not:"
  echo
  printf '%s\n' "$BAD" | awk 'NF {print "  " $0}'
  exit 2
fi

if [ "$OPEN_COUNT" -gt 0 ] || [ "$MISSING_COUNT" -gt 0 ]; then
  exit 1
fi

exit 0
