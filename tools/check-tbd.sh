#!/usr/bin/env sh
#
# check-tbd.sh
#
# Reports the state of every placeholder on the site. Run it before merging.
#
#   tools/check-tbd.sh              the list, the counts, and an exit code
#   tools/check-tbd.sh --by-token   the same thing grouped by token, which is
#                                   the form PLACEHOLDERS.md uses for its
#                                   "appears in" lines
#
# There are two kinds of placeholder, and the difference is the whole reason
# this script is useful rather than noise.
#
#   UNDECIDED, and blocking. A fact nobody has settled yet: a price, a name.
#
#     <span class="tbd" data-tbd="PACKAGE_1_PRICE">Call for pricing</span>
#
#   These are counted, listed, and they make the script exit nonzero. They are
#   what the pre-merge check exists to find.
#
#   SETTLED, and centralised. A fact that IS decided, but which is written
#   into more than one page and would drift out of step if every page carried
#   its own wording.
#
#     <span class="settled" data-settled="VISIT_MODEL">a free twenty minute
#     phone call</span>
#
#   These are reported separately and are NOT counted as outstanding, because
#   nothing is waiting on them. A settled token is a maintenance aid, not a
#   piece of unfinished work.
#
# Keeping the two apart is what lets this script reach exit 0. If every token
# counted as outstanding forever, the check could never pass, and a check that
# can never pass is a check people learn to ignore.
#
# Exit codes:
#
#   0  nothing undecided. Settled tokens may still exist, and that is correct.
#   1  undecided placeholders remain. Normal until every fact is decided.
#   2  a placeholder of either kind breaks the fallback rule: it is empty, or
#      its text is something that must never be published, such as a bare
#      dollar sign or the word TODO. This one is a real fault.
#
# The GitHub Action that runs this reports the result rather than blocking
# anything. See .github/workflows/placeholders.yml.

set -u

# Work from the repository root, wherever this was called from.
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd) || exit 2
cd "$ROOT" || exit 2

MODE="${1:-list}"

# Every HTML page at the root of the repository. design/logo-concepts.html is
# deliberately excluded: it is a working document about the logo, not a page
# of the website.
FILES=$(ls -1 ./*.html 2>/dev/null | sed 's|^\./||')

if [ -z "$FILES" ]; then
  echo "No HTML files found in $ROOT"
  exit 2
fi

# --------------------------------------------------------------------------
# The scan.
#
# This is deliberately ONE pass of awk over every file, rather than several
# grep-into-sed-into-sort pipelines. Each pipeline stage is another process,
# and on Git Bash under Windows process creation fails intermittently with
# "fork: Resource temporarily unavailable". When that happened during
# development, one stage returned nothing and the script cheerfully reported
# zero placeholders. A pre-merge check that can quietly undercount is worse
# than no check, so the scan now runs as a single process whose exit status
# is tested.
#
# It emits one tab separated row per finding:
#
#   OPEN     TOKEN  file  line
#   SETTLED  TOKEN  file  line
#   BAD      TOKEN  file  line  text
#
# The BAD rows are the fallback rule: text that must never be published if
# the token is never revisited. That check reads a whole span, so it only
# sees spans written on a single line, which is how they are written on this
# site. A span split across two lines is still counted and listed, it just
# is not text checked.
# --------------------------------------------------------------------------
SCAN=$(awk '
  # Pull out every data-tbd= or data-settled= attribute on this line.
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

    # Whole spans, so the text inside can be checked against the rule.
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

# Pull the three kinds apart. sort -u because a token can legitimately appear
# more than once on one line only by mistake, and duplicates would inflate the
# count without telling anybody anything.
rows() {
  printf '%s\n' "$SCAN" | awk -F'\t' -v k="$1" '$1 == k { print $2 "\t" $3 "\t" $4 }' | sort -u
}

OPEN=$(rows OPEN)
SETTLED=$(rows SETTLED)
BAD=$(printf '%s\n' "$SCAN" | awk -F'\t' '$1 == "BAD" { printf "%s:%s  %s  text is \"%s\"\n", $3, $4, $2, $5 }' | sort -u)

count() { printf '%s' "$1" | awk 'NF { n++ } END { print n + 0 }'; }
tokens() { printf '%s\n' "$1" | awk -F'\t' 'NF { print $1 }' | sort -u; }

OPEN_COUNT=$(count "$OPEN")
SETTLED_COUNT=$(count "$SETTLED")
BAD_COUNT=$(count "$BAD")

OPEN_TOKENS=$(tokens "$OPEN")
SETTLED_TOKENS=$(tokens "$SETTLED")

OPEN_DISTINCT=$(count "$OPEN_TOKENS")
SETTLED_DISTINCT=$(count "$SETTLED_TOKENS")

# --------------------------------------------------------------------------
# Report
# --------------------------------------------------------------------------
print_group() {
  # $1 = collected rows, $2 = the list of tokens in them
  for t in $2; do
    echo "$t"
    printf '%s\n' "$1" | awk -v tok="$t" 'NF && $1 == tok {print "    " $2 ":" $3}'
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
  if [ "$OPEN_COUNT" -eq 0 ]; then
    echo "None. Every undecided token has been filled in."
    echo
  else
    print_group "$OPEN" "$OPEN_TOKENS"
  fi
  echo "SETTLED, and centralised"
  echo "------------------------"
  echo
  if [ "$SETTLED_COUNT" -eq 0 ]; then
    echo "None."
    echo
  else
    print_group "$SETTLED" "$SETTLED_TOKENS"
  fi
else
  echo "Placeholders"
  echo "============"
  echo
  echo "UNDECIDED, and blocking. These are what the exit code is about."
  echo
  if [ "$OPEN_COUNT" -eq 0 ]; then
    echo "  None. Every undecided token has been filled in."
  else
    printf '%s\n' "$OPEN" | awk 'NF {printf "  %-24s %s:%s\n", $1, $2, $3}'
  fi
  echo
  echo "  $OPEN_COUNT outstanding, $OPEN_DISTINCT distinct token(s)."
  echo
  echo "SETTLED, and centralised. Decided already, kept in one place so the"
  echo "wording cannot drift between pages. Not counted as outstanding."
  echo
  if [ "$SETTLED_COUNT" -eq 0 ]; then
    echo "  None."
  else
    printf '%s\n' "$SETTLED" | awk 'NF {printf "  %-24s %s:%s\n", $1, $2, $3}'
  fi
  echo
  echo "  $SETTLED_COUNT on the site, $SETTLED_DISTINCT distinct token(s)."
  echo
  echo "  Plain English for every token is in PLACEHOLDERS.md."
fi

if [ "$BAD_COUNT" -gt 0 ]; then
  echo
  echo "PROBLEM: $BAD_COUNT placeholder(s) have text that must not be published."
  echo "Every placeholder has to read as a true sentence on its own. These do not:"
  echo
  printf '%s\n' "$BAD" | awk 'NF {print "  " $0}'
  exit 2
fi

if [ "$OPEN_COUNT" -gt 0 ]; then
  exit 1
fi

exit 0
