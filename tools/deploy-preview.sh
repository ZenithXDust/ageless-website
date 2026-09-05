#!/usr/bin/env sh
#
# deploy-preview.sh
#
# Publishes the current branch to a SEPARATE GitHub repository, so the work
# can be looked at on a real URL without going anywhere near the live site.
#
# Why a second repository at all. GitHub Pages on ageless-website is a legacy
# branch build: it serves main, at one URL, and it cannot serve a second
# branch. Pointing it anywhere else changes what the public sees. Switching
# the source to Actions would rebuild how production publishes. Neither is
# acceptable for a preview, so the preview lives in its own repository with
# its own Pages site, and the real one is never touched.
#
# THE IMPORTANT PART: the robots tag is injected at publish time, into the
# copy only. It never exists on the source branch. If it did, and that branch
# were merged, the live site would be telling search engines to drop it.
# tools/check-tbd.sh has a tripwire that fails if the tag ever appears in the
# tracked tree, and this script is on its allowlist because it is one of the
# few files that has to name it.
#
# robots.txt is deliberately NOT copied. A Disallow rule stops a crawler
# fetching the page, which means it never reads the noindex, and a URL can
# still end up listed with no content. Blocking the crawl is the opposite of
# what is wanted here: the crawler should fetch the page and be told plainly
# not to index it.
#
# The canonical link and og:url are stripped by tools/preview-inject.py, which
# explains why in its own docstring.
#
# Usage:  tools/deploy-preview.sh
# Result: prints the preview URL.

set -eu

PREVIEW_REPO="ageless-preview"
ROBOTS_TAG='<meta name="robots" content="no'"index"', nofollow">'

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"

BRANCH=$(git rev-parse --abbrev-ref HEAD)
OWNER=$(gh api user --jq .login)

echo "Source branch : $BRANCH"
echo "Preview repo  : $OWNER/$PREVIEW_REPO"
echo

if [ "$BRANCH" = "main" ]; then
  echo "Refusing to run from main. Check out the working branch first."
  exit 1
fi

# Refuse to publish something with a real fault in it. Exit 1 from check-tbd
# means work is outstanding, which is the expected state for a preview.
set +e
tools/check-tbd.sh >/dev/null 2>&1
CHECK=$?
set -e
if [ "$CHECK" -eq 2 ]; then
  echo "check-tbd.sh exited 2, which is a fault rather than a status:"
  tools/check-tbd.sh
  exit 1
fi
echo "check-tbd.sh: status $CHECK, continuing."

WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT
echo "Staging in $WORK"

# The site itself. Tooling, docs and the workflow are not part of the site and
# are not copied. robots.txt and sitemap.xml are deliberately left behind.
#
# Written as few commands as possible on purpose: process creation fails
# intermittently on Git Bash under Windows, and an earlier version that ran
# one awk and one mv per page died halfway through, leaving a partial copy.
cp *.html "$WORK/"
for d in css js images brand print design; do
  [ -d "$d" ] && cp -R "$d" "$WORK/"
done

# Inject the robots tag and strip the canonical and og:url. That script
# verifies its own work and exits nonzero if any page came out without the
# tag, so a partial run cannot be published by accident.
python tools/preview-inject.py "$WORK" "$ROBOTS_TAG"

cat > "$WORK/README.md" <<'ENDREADME'
# Ageless, preview build

This repository is a **disposable preview**. It is not the live site and it is
not the source of truth.

- Live site: https://github.com/ZenithXDust/ageless-website (branch `main`)
- Source of what is here: the working branch of that repository

Every page carries a `robots` noindex tag, injected at publish time so that it
never exists on the source branch. Do not edit anything here. Edit the source
repository and run `tools/deploy-preview.sh` again.
ENDREADME

# ---------------------------------------------------------------------------
# Publish.
# ---------------------------------------------------------------------------
SHA=$(git rev-parse --short HEAD)

cd "$WORK"
git init -q
git checkout -q -b main
git add -A
git -c user.name="deploy-preview" -c user.email="noreply@example.com" \
    commit -q -m "Preview of $BRANCH at $SHA"

if ! gh repo view "$OWNER/$PREVIEW_REPO" >/dev/null 2>&1; then
  echo "Creating $OWNER/$PREVIEW_REPO"
  gh repo create "$OWNER/$PREVIEW_REPO" --public \
     --description "Disposable preview of the Ageless site. Not the live site." >/dev/null
fi

git remote add origin "https://github.com/$OWNER/$PREVIEW_REPO.git"
git push -q --force origin main

# Enable Pages, or leave it alone if it is already on.
gh api -X POST "repos/$OWNER/$PREVIEW_REPO/pages" \
  -f "source[branch]=main" -f "source[path]=/" >/dev/null 2>&1 || true

LOWER=$(echo "$OWNER" | tr 'A-Z' 'a-z')
echo
echo "Published."
echo "  https://$LOWER.github.io/$PREVIEW_REPO/"
echo
echo "Pages can take a minute or two on a first build."
