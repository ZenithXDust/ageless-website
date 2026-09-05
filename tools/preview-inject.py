"""Prepare a copy of the site for the preview host.

Called by tools/deploy-preview.sh with the staging directory as its argument.
It never touches the working tree: it only rewrites the copy.

Three things happen to every page.

1. A robots noindex tag is inserted into the head. This is THE reason the
   script exists. It is injected here, at publish time, so that the tag never
   exists on the source branch. If it were ever committed there and that
   branch were merged, the live site would be telling search engines to drop
   it. tools/check-tbd.sh has a tripwire for exactly that.

2. The canonical link is stripped. It points at the live site, and Google's
   guidance is not to combine noindex with a canonical pointing elsewhere,
   because the noindex can end up applied to the canonical target. That target
   is the real site, so leaving it in risked deindexing the thing this is
   trying to protect.

3. og:url is stripped for the same reason: it names the live address, and this
   copy is not it.

The script verifies its own work and exits nonzero if any page came out
without the tag, so a partial run cannot be published by accident.
"""

import glob
import io
import os
import sys

NOTE = (
    "  <!-- Preview build. Not the live site. This tag is injected by\n"
    "       tools/deploy-preview.sh at publish time and is never committed\n"
    "       on the source branch, because merging it would tell search\n"
    "       engines to drop the real site. -->"
)


def main():
    if len(sys.argv) != 3:
        sys.stderr.write("usage: preview-inject.py <staging-dir> <robots-tag>\n")
        return 2

    work, tag = sys.argv[1], sys.argv[2]
    pages = sorted(glob.glob(os.path.join(work, "*.html")))

    if not pages:
        sys.stderr.write("preview-inject.py: no pages found in %s\n" % work)
        return 1

    missing = []

    for path in pages:
        source = io.open(path, encoding="utf-8").read()
        out = []
        inserted = False

        for line in source.split("\n"):
            if '<link rel="canonical"' in line:
                continue
            if '<meta property="og:url"' in line:
                continue

            out.append(line)

            # The viewport meta is on every page and sits early in the head,
            # which makes it a reliable anchor to insert after.
            if not inserted and '<meta name="viewport"' in line:
                out.append("  " + tag)
                out.append(NOTE)
                inserted = True

        text = "\n".join(out)
        if tag not in text:
            missing.append(os.path.basename(path))

        io.open(path, "w", encoding="utf-8", newline="\n").write(text)

    if missing:
        sys.stderr.write("NO ROBOTS TAG on: %s\n" % ", ".join(missing))
        return 1

    print("Robots tag added to all %d pages. Canonical and og:url stripped."
          % len(pages))
    return 0


if __name__ == "__main__":
    sys.exit(main())
