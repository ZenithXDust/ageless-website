#!/usr/bin/env sh
#
# check-tbd.sh
#
# Lists every placeholder still outstanding on the site, with the file and
# line number of each, and a count. Run it before merging.
#
#   tools/check-tbd.sh              the list, the count, and an exit code
#   tools/check-tbd.sh --by-token   the same thing grouped by token, which is
#                                   the form PLACEHOLDERS.md uses for its
#                                   "appears in" column
#
# A placeholder looks like this in the HTML:
#
#   <span class="tbd" data-tbd="PACKAGE_1_PRICE">Call for pricing</span>
#
# Exit codes, which is the part that matters for automation:
#
#   0  nothing outstanding. Every token has been replaced with a real value.
#   1  placeholders remain. This is the normal, expected state until every
#      fact has been decided, so it is a status, not a breakage.
#   2  a placeholder breaks the fallback rule: it is empty, or its fallback
#      text is something that must never be published, such as a bare dollar
#      sign or the word TODO. This one is a real fault and wants fixing.
#
# Because exit 1 is expected for a long time, the GitHub Action that runs this
# reports the result rather than blocking anything. See
# .github/workflows/placeholders.yml.

set -u

# Work from the repository root no matter where this was called from.
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
# Collect every occurrence as three fields: TOKEN, file, line.
# --------------------------------------------------------------------------
RAW=$(grep -HnoE 'data-tbd="[A-Z0-9_]+"' -- $FILES 2>/dev/null |
      sed -E 's/^([^:]+):([0-9]+):data-tbd="([A-Z0-9_]+)"$/\3 \1 \2/' |
      sort -u)

COUNT=$(printf '%s' "$RAW" | grep -c . )
TOKENS=$(printf '%s\n' "$RAW" | awk 'NF {print $1}' | sort -u)
DISTINCT=$(printf '%s' "$TOKENS" | grep -c . )

# --------------------------------------------------------------------------
# The fallback rule. Every placeholder must contain text that is true and
# publishable on its own. These are the things that must never be sitting
# inside one, because a visitor would see them if the token were never filled
# in: nothing at all, a bare currency symbol, or a note to self.
# --------------------------------------------------------------------------
BAD=$(grep -HnoE '<span class="tbd" data-tbd="[A-Z0-9_]+">[^<]*</span>' -- $FILES 2>/dev/null |
      sed -E 's/^([^:]+):([0-9]+):<span class="tbd" data-tbd="([A-Z0-9_]+)">([^<]*)<\/span>$/\1 \2 \3 |\4|/' |
      awk '
        {
          # Rebuild the fallback text, which is everything from the fourth
          # field onward, and strip the pipes used to protect its spaces.
          text = ""
          for (i = 4; i <= NF; i++) text = text (i > 4 ? " " : "") $i
          gsub(/^\|/, "", text); gsub(/\|$/, "", text)
          stripped = text
          gsub(/^[ \t]+|[ \t]+$/, "", stripped)
          upper = toupper(stripped)
          if (stripped == "" ||
              stripped == "$" ||
              upper == "TODO" ||
              upper == "TBD" ||
              upper == "XXX" ||
              upper == $3) {
            print $1 ":" $2 "  " $3 "  fallback is \"" stripped "\""
          }
        }')

BADCOUNT=$(printf '%s' "$BAD" | grep -c . )

# --------------------------------------------------------------------------
# Report
# --------------------------------------------------------------------------
if [ "$MODE" = "--by-token" ]; then
  echo "Placeholders by token"
  echo "====================="
  echo
  if [ "$COUNT" -eq 0 ]; then
    echo "None. Every token has been filled in."
  else
    for t in $TOKENS; do
      echo "$t"
      printf '%s\n' "$RAW" | awk -v tok="$t" 'NF && $1 == tok {print "    " $2 ":" $3}'
      echo
    done
  fi
else
  echo "Outstanding placeholders"
  echo "========================"
  echo
  if [ "$COUNT" -eq 0 ]; then
    echo "None. Every token has been filled in."
  else
    printf '%s\n' "$RAW" | awk 'NF {printf "  %-24s %s:%s\n", $1, $2, $3}'
  fi
  echo
  echo "  $COUNT placeholder(s) on the site, $DISTINCT distinct token(s)."
  echo "  Plain English for each one is in PLACEHOLDERS.md."
fi

if [ "$BADCOUNT" -gt 0 ]; then
  echo
  echo "PROBLEM: $BADCOUNT placeholder(s) have fallback text that must not be published."
  echo "Every placeholder has to read as a true sentence on its own if it is never"
  echo "filled in. These do not:"
  echo
  printf '%s\n' "$BAD" | awk 'NF {print "  " $0}'
  exit 2
fi

if [ "$COUNT" -gt 0 ]; then
  exit 1
fi

exit 0
