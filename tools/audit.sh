#!/usr/bin/env sh
#
# audit.sh
#
# Checks the things that quietly break on a hand-maintained static site where
# the header and footer are copied into every page rather than shared.
#
#   1. Every internal link and asset reference resolves to a real file.
#   2. One h1 per page, and no skipped heading levels.
#   3. Every img has an alt attribute.
#   4. Header and footer identical across all pages, apart from aria-current.
#   5. No em dashes or en dashes anywhere in the repository.
#   6. No page shows a raw placeholder token in visible text.
#   7. Every page still works when opened straight from the file system.
#
# Each check reports PASS or FAIL with the offending file and line. Exit 0 if
# everything passes, 1 if anything fails.
#
# Check 7 is honest about its own limits and worth reading before trusting it.
# Nothing here runs a browser, so it cannot literally prove a page renders.
# What it does prove is the set of things that actually break a file:// page
# on this site: an asset path rooted at "/" resolves to the drive root rather
# than the project, fetch() of a local file is blocked by the browser, and a
# missing asset is a missing asset. It is a strong proxy, not a render.
#
# Like check-tbd.sh, the scan is a single awk pass rather than a stack of
# pipelines, because process creation fails intermittently on Git Bash under
# Windows and a checker that silently skips a check is worse than no checker.

set -u

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd) || exit 1
cd "$ROOT" || exit 1

FILES=$(ls -1 ./*.html 2>/dev/null | sed 's|^\./||')
if [ -z "$FILES" ]; then
  echo "audit.sh: no HTML files found in $ROOT"
  exit 1
fi

# The tokens the placeholder system knows about, read from the manifest so
# there is one list rather than two that drift apart.
TOKENS=$(awk '
  /MANIFEST-START/ { inside = 1; next }
  /MANIFEST-END/   { inside = 0 }
  inside && $0 !~ /^[ \t]*#/ && $0 !~ /^[ \t]*```/ && NF { print $1 }
' PLACEHOLDERS.md 2>/dev/null | sort -u | tr '\n' ' ')

REPORT=$(awk -v tokenlist="$TOKENS" '
  function fail(check, file, line, msg) {
    printf "FAIL\t%s\t%s\t%s\t%s\n", check, file, line, msg
  }

  BEGIN {
    n = split(tokenlist, t, " ")
    for (i = 1; i <= n; i++) if (t[i] != "") known[t[i]] = 1
  }

  FNR == 1 {
    file[++nfiles] = FILENAME
    h1count[FILENAME] = 0
    lastlevel[FILENAME] = 0
    inheader[FILENAME] = 0
  }

  {
    line = $0

    # ---------------------------------------------------------------- 5. dashes
    if (index(line, "\342\200\224") || index(line, "\342\200\223"))
      fail("dashes", FILENAME, FNR, "em or en dash in the page")

    # ------------------------------------------------------- 4. header/footer
    if (index(line, "<header class=\"site-header\">")) cap = "H"
    if (index(line, "<footer class=\"site-footer\">")) cap = "F"
    if (cap != "") {
      norm = line
      gsub(/ aria-current="page"/, "", norm)
      gsub(/^[ \t]+|[ \t]+$/, "", norm)
      if (cap == "H") header[FILENAME] = header[FILENAME] norm "\n"
      else            footer[FILENAME] = footer[FILENAME] norm "\n"
    }
    if (index(line, "</header>")) cap = ""
    if (index(line, "</footer>")) cap = ""

    # ------------------------------------------------------------- 2. headings
    rest = line
    while (match(rest, /<h[1-6][ >]/)) {
      tag = substr(rest, RSTART, RLENGTH)
      lvl = substr(tag, 3, 1) + 0
      rest = substr(rest, RSTART + RLENGTH)
      if (lvl == 1) h1count[FILENAME]++
      if (lastlevel[FILENAME] > 0 && lvl > lastlevel[FILENAME] + 1)
        fail("headings", FILENAME, FNR,
             "jumps from h" lastlevel[FILENAME] " to h" lvl)
      lastlevel[FILENAME] = lvl
    }

    # ------------------------------------------------------------ 3. img alt
    rest = line
    while (match(rest, /<img[ \t][^>]*>/)) {
      tag = substr(rest, RSTART, RLENGTH)
      rest = substr(rest, RSTART + RLENGTH)
      if (tag !~ /[ \t]alt=/) fail("alt", FILENAME, FNR, "img with no alt attribute")
    }
    # An img tag split across lines: opened here, alt may be on a later line.
    if (line ~ /<img[ \t]/ && line !~ /<img[ \t][^>]*>/) {
      openimg[FILENAME] = FNR
      openimghasalt[FILENAME] = (line ~ /[ \t]alt=/) ? 1 : 0
    } else if (openimg[FILENAME] > 0) {
      if (line ~ /[ \t]alt=/) openimghasalt[FILENAME] = 1
      if (index(line, ">")) {
        if (!openimghasalt[FILENAME])
          fail("alt", FILENAME, openimg[FILENAME], "img with no alt attribute")
        openimg[FILENAME] = 0
      }
    }

    # ------------------------------------------ 1 and 7. links and asset paths
    rest = line
    while (match(rest, /(href|src)="[^"]*"/)) {
      ref = substr(rest, RSTART, RLENGTH)
      rest = substr(rest, RSTART + RLENGTH)
      sub(/^(href|src)="/, "", ref)
      sub(/"$/, "", ref)

      if (ref == "" || ref ~ /^#/ || ref ~ /^(https?|mailto|tel|data):/) continue

      if (ref ~ /^\//) {
        fail("filesystem", FILENAME, FNR,
             "root-relative path \"" ref "\" breaks when opened from disk")
        continue
      }

      target = ref
      sub(/[#?].*$/, "", target)
      if (target == "") continue

      if (!(target in checked)) {
        checked[target] = ((getline probe < target) >= 0) ? 1 : 0
        close(target)
      }
      if (!checked[target])
        fail("links", FILENAME, FNR, "\"" target "\" does not exist")
    }

    # ------------------------------------------------------- 7. local fetch
    if (line ~ /fetch\(/ && line !~ /^[ \t]*(\/\/|\*)/)
      fail("filesystem", FILENAME, FNR, "fetch() is blocked on file:// pages")

    # ------------------------------------------- 6. raw tokens in visible text
    stripped = line
    gsub(/<[^>]*>/, " ", stripped)
    rest = stripped
    while (match(rest, /[A-Z][A-Z0-9_]{4,}/)) {
      word = substr(rest, RSTART, RLENGTH)
      rest = substr(rest, RSTART + RLENGTH)
      if (word in known)
        fail("tokens", FILENAME, FNR, "raw token " word " is visible to a reader")
    }
  }

  END {
    for (i = 1; i <= nfiles; i++) {
      f = file[i]
      if (h1count[f] != 1)
        fail("headings", f, 0, "has " h1count[f] " h1 elements, expected exactly 1")
      if (i > 1) {
        if (header[f] != header[file[1]])
          fail("chrome", f, 0, "header differs from " file[1])
        if (footer[f] != footer[file[1]])
          fail("chrome", f, 0, "footer differs from " file[1])
      }
    }
  }
' $FILES)

if [ $? -ne 0 ]; then
  echo "audit.sh: the scan failed to run. Refusing to report a result."
  exit 1
fi

# Dashes outside the HTML: docs, stylesheet, scripts, sitemap.
OTHER=$(ls -1 ./*.md ./css/*.css ./js/*.js ./*.xml ./*.txt 2>/dev/null | sed 's|^\./||')
REPORT2=$(awk '
  index($0, "\342\200\224") || index($0, "\342\200\223") {
    printf "FAIL\tdashes\t%s\t%s\t%s\n", FILENAME, FNR, "em or en dash"
  }
' $OTHER 2>/dev/null)

ALL=$(printf '%s\n%s\n' "$REPORT" "$REPORT2")

# --------------------------------------------------------------------------
# Report, one line per check.
# --------------------------------------------------------------------------
echo "Audit"
echo "====="
echo

STATUS=0
for check in links headings alt chrome dashes tokens filesystem; do
  case "$check" in
    links)      label="1. Internal links and assets resolve" ;;
    headings)   label="2. One h1 per page, no skipped levels" ;;
    alt)        label="3. Every img has an alt attribute" ;;
    chrome)     label="4. Header and footer identical everywhere" ;;
    dashes)     label="5. No em dashes or en dashes in the repo" ;;
    tokens)     label="6. No raw placeholder token visible to a reader" ;;
    filesystem) label="7. Pages work opened from the file system" ;;
  esac

  hits=$(printf '%s\n' "$ALL" | awk -F'\t' -v c="$check" '$1 == "FAIL" && $2 == c')
  n=$(printf '%s' "$hits" | awk 'NF {c++} END {print c + 0}')

  if [ "$n" -eq 0 ]; then
    printf '  PASS  %s\n' "$label"
  else
    printf '  FAIL  %s  (%s)\n' "$label" "$n"
    printf '%s\n' "$hits" | awk -F'\t' 'NF {printf "          %s:%s  %s\n", $3, $4, $5}'
    STATUS=1
  fi
done

echo
if [ "$STATUS" -eq 0 ]; then
  echo "  All seven checks pass."
else
  echo "  Something failed. Fix it and run this again."
fi
echo
echo "  Note on check 7: nothing here runs a browser, so this proves the"
echo "  things that actually break a file:// page (root-relative paths,"
echo "  local fetch, missing assets) rather than proving a render."

exit $STATUS
