# Ageless

The website for Ageless, a curated retailer of home technology in Ottawa and
Toronto, Ontario.

Ageless helps older adults stay in their own homes instead of moving into a
retirement residence, in three parts: curated packages of technology chosen
for a specific need and sold at a published price, installation and setup in
the home, and an ongoing monthly service that keeps it working and the family
informed.

The device is not the product. The choosing, the installing and the keeping it
working are.

**Live site:** https://zenithxdust.github.io/ageless-website/

## How this site is built

Plain HTML, CSS and vanilla JavaScript. No frameworks, no build step, no
dependencies. Every page works if you open the file directly in a browser.

```
index.html              how-it-works.html      solutions.html
booking.html            pricing.html           about.html
contact.html            faq.html               resources.html
terms.html              privacy.html           404.html
resources-*.html        four articles

css/style.css           one stylesheet, shared by every page
js/nav.js               the mobile menu
js/booking.js           the appointment picker
js/photos.js            shows or removes reserved photo spaces
js/tbd.js               marks unfinished facts, locally only
images/                 logo, illustrations, share card
tools/check-tbd.sh      what is still undecided, run before merging
tools/audit.sh          links, headings, alt text, chrome, dashes
```

The header and footer are copied into each page rather than shared. That is
deliberate: the usual JavaScript approach uses `fetch`, which browsers block on
`file://` addresses, and that would break the rule that every page must work
when opened directly.

## Publishing

GitHub Pages serves the `main` branch. Pushing to `main` publishes the site,
and it goes live in about a minute. There is no staging step, so `main` is
production.

**Never merge or push to `main` without checking first.** Run
`tools/check-tbd.sh` and `tools/audit.sh`, and confirm the work is actually
finished. A half-converted site on `main` is live immediately and the only way
back is another push.

## Accessibility

This is the product, not a checklist. 20px body text, 1.65 line height, every
colour measured at 7:1 contrast or better, 48px tap targets, one `h1` per page
with no skipped heading levels, skip links, visible focus states, full keyboard
navigation, and no motion without user input. The phone number is visible and
tappable on every page without scrolling.

## Other files worth reading

| File | What it is |
|---|---|
| `CLAUDE.md` | House rules: tone, writing style, technical constraints, confirmed facts, and claims that must never appear |
| `LEGAL.md` | What the terms and privacy policy do and do not cover, and what a lawyer should check |
| `PHOTOS.md` | How to add photographs, where to source them, and the one rule not to break |
| `PLACEHOLDERS.md` | Every fact still to be decided, what it means, and where it appears |
| `design/logo-concepts.html` | The four logo directions considered, and why the current one was chosen |

## Not finished

- No email address or contact form. Contact is phone only until a domain is settled.
- Package names and every price are placeholders, not blanks. They read as true
  sentences today and are listed by `tools/check-tbd.sh`. See `PLACEHOLDERS.md`.
- The terms and privacy policy have not been reviewed by a lawyer, and the
  retail model added four new questions for one. See `LEGAL.md`.
