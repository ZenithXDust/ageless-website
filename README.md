# Ageless — website

Static marketing site for **Ageless**, an RN-led in-home safety assessment and
adaptive-equipment consulting practice serving the Ottawa region.

No build step, no framework, no JavaScript. Plain HTML + one CSS file.

## Structure

```
.
├── index.html          Home
├── services.html       Services (assessment process, equipment, implementation)
├── framework.html      Clinical safety framework — 4 priority zones (CSS-only accordions)
├── about.html          About + consultant bio (Amin Osman, RN)
├── contact.html        Contact form + details
├── assessment.html     "The Assessment" — full walk-through framework
├── css/
│   └── styles.css      All styles (design tokens at the top)
├── assets/
│   └── favicon.svg
├── .gitignore
└── README.md
```

## Design

- **Palette** (CSS custom properties in `css/styles.css`):
  warm cream background `#F8F1E3`, dark navy-blue text `#172438`,
  muted-orange highlights/buttons `#B25E28` (`#8F4A1A` when orange is used as text).
- **Type**: system sans-serif stack, 18px base, ~19px body, line-height 1.65.
- **Accessibility**: skip link, semantic landmarks, `aria-current` nav state,
  visible 3px focus outlines, labelled form controls with a `<fieldset>` group,
  ~44px minimum tap targets, `prefers-reduced-motion` respected, WCAG-AA colour
  contrast throughout. Single light theme by brand direction; every colour is set
  explicitly.
- **Print**: `assessment.html` has a print stylesheet (drops nav/footer/CTA,
  black-on-white) so families can print it for the visit.

## Run locally

Just open `index.html` in a browser, or serve the folder:

```
python -m http.server 8000
# then visit http://localhost:8000
```

## Before you publish

Phone (`437-457-5307`) and email (`Agelesshomesafety@protonmail.com`) are set to
live values in every page footer and in `contact.html`. Still to do:

| Item | Action |
|---|---|
| `{FORM_ID}` in `contact.html` form `action` | real form endpoint (e.g. Formspree `https://formspree.io/f/xxxx`, or your provider) — or wire the form to your own handler |
| `_subject` value `"...from ageless.ca"` in `contact.html` | update to the real domain |
| Service-area town list in `contact.html` | confirm coverage |
| Business hours ("By appointment, Monday–Saturday") | confirm |
| `© 2026 Ageless` | keep current |

Also review with a clinician/legal advisor: the cost bands and the
"assesses the home environment; does not provide medical diagnosis or treatment"
disclaimer wording in each footer and at the bottom of `assessment.html`.

## Deploy

Any static host works (Netlify, Cloudflare Pages, GitHub Pages, S3). Point it at
the repo root; no configuration required. If you use Netlify Forms, add
`netlify` and `name` attributes to the `<form>` in `contact.html` and you can
drop the external form endpoint.
