# Ageless — website

Static marketing site for **Ageless**, an RN-led in-home safety assessment and
adaptive-equipment consulting practice serving Ottawa, ON.

No build step, no framework, no JavaScript. Plain HTML + one CSS file.

## Structure

```
.
├── index.html          Home
├── about.html          About + consultant bio (Amin Osman, RN)
├── framework.html      Assessment Framework — 4 priority zones (CSS-only accordions)
├── contact.html        Booking request form + FAQ
├── services.html       Services detail (secondary page; linked from footer)
├── assessment.html     The Walk-Through — full room-by-room checklist (secondary page)
├── css/
│   └── styles.css      All styles (design tokens at the top)
├── assets/
│   └── favicon.svg
├── .gitignore
└── README.md
```

Primary nav is four items — **Home · About · Assessment Framework · Contact**.
`services.html` and `assessment.html` remain in the footer.

## Design

- **Palette** (CSS custom properties in `css/styles.css`):
  warm cream background `#F8F1E3`, dark navy-blue text `#172438`,
  muted-orange buttons `#A85520` with white text, and `#703A12` when orange is
  used as text. Values were chosen to clear **WCAG 2.1 AAA** contrast (≥7:1 for
  body text, ≥4.5:1 for large text) on every surface.
- **Type**: system sans-serif stack, 18px base, ~19px body, line-height 1.65.
- **Accessibility**: "Skip to main content" link on every page; semantic
  landmarks (`header` / `nav` / `main` / `section` / `footer`) with `aria-label`
  on each `nav` and `aria-labelledby` on major sections; `aria-current` nav
  state; visible 3px `:focus-visible` outlines; ≥48px interactive tap targets;
  labelled form controls with a `<fieldset>`/`<legend>` group; semantic
  `<address>` for contact/location; `prefers-reduced-motion` respected. Single
  light theme by brand direction; every colour is set explicitly.
- **Print**: `framework.html` and `assessment.html` have print styles (drop
  nav/footer/CTA, force accordions open, black-on-white).

## Run locally

Just open `index.html` in a browser, or serve the folder:

```
python -m http.server 8000
# then visit http://localhost:8000
```

## Before you publish

Phone (`437-457-5307`) and email (`Agelesshomesafety@protonmail.com`) are live
values in every page footer and on `contact.html`. Still to do:

| Item | Action |
|---|---|
| `contact.html` `<form action="#">` | point at a no-JS form endpoint (Formspree, Web3Forms) or, on Netlify, add `netlify` + `name` attributes and a redirect |
| Service-area town list on `contact.html` | confirm coverage |
| Business hours ("By appointment, Monday–Saturday") | confirm |
| `© 2026 Ageless` | keep current |

Also review with a clinician/legal advisor: the cost bands and the
"assesses the home environment; does not provide medical diagnosis or treatment"
disclaimer wording in each footer and at the bottom of `assessment.html`.

## Deploy

Any static host works (Netlify, Cloudflare Pages, GitHub Pages, S3). Point it at
the repo root; no configuration required.
