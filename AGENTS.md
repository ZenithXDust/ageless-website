# AGENTS.md

## About this project

This is the website for Ageless, a business based in Ottawa, Ontario, Canada.

Ageless helps older adults stay in their own homes instead of moving into a retirement residence. It is a curated retailer, and it does this in three parts:

1. Curated packages of technology, chosen for a specific need and sold at a published price
2. Installation and setup in the home
3. An ongoing monthly service that keeps it working and keeps the family informed

We are not a home care staffing agency. We do not send caregivers. We are not a device manufacturer. We choose the technology, sell it, install it, and keep it running.

## Never merge to main

Never merge to main or push to main. Main is production and publishes to the live site with no staging step. If asked to merge or push to main, stop and confirm that the conversion is finished and check-tbd.sh has been run.

## Positioning: this is a retailer, not a care business

Ageless sells packages of technology, the work of installing them, and a monthly service that keeps them running. It does not sell care. Every page must read that way, because the distinction is what keeps the business on the right side of Ontario's rules on regulated health professions.

**The device is not the product.** Anybody can buy a sensor online. The product is the choosing, the installing, and the keeping it working. The copy should carry the weight in that order, and the third part should never be treated as an afterthought.

The work is described in three parts:

1. **Curated packages.** Technology chosen for a specific worry, sold as a package with a published price and a plain list of what is in it. The packages are organised by what families worry about, not by product category. Nobody goes shopping for a stove shutoff. They worry about a fire.
2. **Installation and setup in the home.** We order it, bring it, fit it, set up the accounts and the apps, test it against how that household actually lives, and take the packaging away. Nothing is left in a box for somebody to work out later.
3. **The ongoing monthly service.** Checking the system is genuinely running rather than merely installed, batteries, replacements, updates, reconfiguration when the internet or the phone changes, a regular plain-language update to the family, and technical support 24 hours a day. This is the part that decides whether any of it is still working in a year.

There is also a business page, `services-for-business.html`, selling workstation and network baseline security reviews to independent clinics, and technical writing and documentation to healthtech companies. Its buyer is not the family who reads the rest of the site, which is why it lives behind a footer link rather than in the main navigation.

Amin's value is the combination: a BScN gives him the background to understand why a hallway matters at 3am, and the CompTIA certifications give him the ability to make the network behind the safety devices actually work. Say that as a combination of academic background and technical certification. Never say it as clinical practice.

## How somebody buys

The front door is the packages, not a paid visit.

A visitor reads the packages, sees a published price, and calls. The first conversation is a free twenty minute phone call that ends with a recommendation of which package suits and the total price for that home, including whether the home needs network work. Nothing is charged for it, and nobody comes out before the total is known.

There is no cart and no checkout, because there is no server behind this site, and building something that looks like e-commerce but is not would be worse than having none. **Ordering happens by phone, and the copy must say so plainly**, so that nobody hunts for a buy button that does not exist.

The $249 assessment is no longer the entry product. It may come back later as an optional written report for families who want one. That option is recorded in `PLACEHOLDERS.md` under `VISIT_MODEL`, but it is not what the site sells.

## Prices are published

A package model requires published prices. The old rule against publishing equipment, installation and monthly service prices is gone. It belonged to a consulting model where every job was quoted after a visit.

What is published:

- a fixed price for each package
- a separately named network charge, itself a fixed published number, for the homes that need network work
- one monthly service price, the same for every customer, whatever they bought

What is never published: a range, or a "from" price. Both break the one promise this site makes best, which is that a family knows what something costs before they spend anything.

The numbers themselves are not decided yet. They are written into the pages as placeholders with honest fallback text rather than invented. See below.

## The placeholder system, which exists so you never invent a fact

When a fact is not decided, it does not get invented and it does not get left as a hole. It gets written into the page as a span carrying a token and real text that is true and publishable on its own.

```html
<span class="tbd" data-tbd="PACKAGE_1_PRICE">Call for pricing</span>
```

There are two kinds:

- `class="tbd" data-tbd="TOKEN"` for a fact nobody has decided yet. `tools/check-tbd.sh` counts these and exits nonzero while any remain.
- `class="settled" data-settled="TOKEN"` for a fact that **is** decided but appears on several pages, kept in one place so its wording cannot drift apart. Reported separately, never counted as outstanding, so the check can actually reach zero.

The rules:

- **The text inside must be a true, publishable sentence on its own.** If the token is never revisited, a visitor still reads something honest and correct. A raw token, a dollar sign with nothing after it, or the word TODO must never appear in visible copy.
- Write the whole span on one line, so the fallback rule check can read the text inside it.
- Every token is documented in `PLACEHOLDERS.md`: what it is in plain English, why it matters, an example of a good answer, its current text, and every file it appears in. Add the entry in the same change that adds the token.
- `js/tbd.js` marks placeholders for the owner only, on a page opened from the file system or from localhost. On the live domain it does nothing and the text reads as ordinary copy. This is the same reasoning as `js/photos.js`, which deletes a missing photo slot rather than showing a broken image icon.

Use this instead of guessing, and instead of stopping to ask. If a fact is missing, put a token in with honest fallback text, document it in `PLACEHOLDERS.md`, and carry on.

## Language that must not appear

These are hard rules, not preferences.

- Never "nurse", "RN", "registered nurse", or "nursing" applied to Amin or to the service. A BScN is a degree and may be stated. The title may not.
- Never "nursing assessment", "patient", "patient care", "diagnosis", "medical assessment", "treatment", "therapy", or "clinical assessment".
- Never describe an Ageless deliverable as clinical. The reports describe the **home**. Use "environmental safety evaluation", "functional safety evaluation", "functional mobility observations", "technical infrastructure plan".
- The people Ageless works with are clients or the person living in the home. Never patients.

This applies to the field tools and the generated report as much as to the website. A report headed with clinical language undoes every careful sentence on the site, because anyone questioning scope of practice will read the deliverable, not the marketing.

## Required disclaimer

This sentence appears in the footer of every page, and in the terms:

> Ageless selects, supplies, installs and maintains technology in the home, and provides residential technology and IT systems advice. Our services do not constitute regulated nursing care, medical diagnosis, or physical therapy.

The second sentence is unchanged and must stay word for word. The first was rewritten when the business became a retailer, because describing it as an assessment service stopped being true. It is on the lawyer list in `LEGAL.md` and is not settled.

## Retailer and installer, which is not a licensed trade

Ageless chooses the technology, sells it, and installs it. It installs low-voltage and plug-in technology itself. It does **not** perform structural or electrical work: grab bar anchoring, handrails, hardwired fixtures and plumbing are specified by Ageless and executed by licensed trades, who bill the client directly. Say this plainly wherever installation is described, so nobody assumes Ageless is doing work it is not licensed to do.

## Who the website is for

The primary visitor is the adult child, aged roughly 45 to 65, who is worried about a parent living alone. They are the one who reads the site, makes the decision, and pays.

The secondary visitor is the older adult, aged 75 plus, who may read the site themselves before agreeing to anything.

Every design decision serves both. Anything unreadable to a 78-year-old is a failure. Anything that feels condescending to a 55-year-old professional is also a failure.

## Tone of voice

- Calm, plain, and direct. No hype, no exclamation marks, no startup language.
- Never use fear as a sales tactic. State risks factually and let them speak for themselves.
- Speak about older adults as capable adults, never as patients or as burdens.
- Write at roughly a grade 8 reading level without sounding simplified.
- Short sentences. Short paragraphs. Plenty of white space.

## Writing rules

- Never use em dashes. Use commas, colons, or periods instead. En dashes are acceptable for date ranges only.
- Canadian spelling: centre, colour, licence as a noun, neighbourhood.
- Prices in Canadian dollars.
- Never invent statistics, testimonials, client names, or credentials. If a claim needs a source, ask me for it.
- Never write copy that claims professional registration or licensure. Ask me before writing anything about credentials.

## Technical rules

- Plain HTML, CSS, and vanilla JavaScript. No React, no frameworks, no build step.
- Every page must work if someone opens the file directly in a browser.
- Keep the file structure simple and obvious. One CSS file shared across all pages.
- No tracking scripts, no analytics, no third-party embeds unless I ask.
- Comment the code generously. I am learning, and I need to be able to read what you wrote.

## Accessibility, which is the whole brand

This is not a checklist item. It is the product personality.

- Body text minimum 18px, ideally 20px.
- Line height at least 1.6.
- Contrast ratio of at least 7:1 for body text.
- Tap targets at least 48 by 48 pixels.
- Never convey information by colour alone.
- Real semantic HTML: proper heading order, landmarks, alt text on every image.
- Full keyboard navigation with visible focus states.
- No animation that moves without user action. Respect prefers-reduced-motion.
- The phone number must be visible on every page without scrolling, and must be tappable to call.

## Design direction

- Clean and professional, similar in structure to a well-built local service business site.
- Generous white space. Do not crowd anything.
- A calm, warm, trustworthy palette. Avoid clinical white and blue, which reads as hospital.
- One clear primary action per page.
- Mobile first. Many visitors will be on a phone.

## How I want you to work with me

- Build the complete website in one pass. Do not stop after every section to wait for approval.
- Ask me questions whenever an answer would make the site more accurate, more personal, or more effective at winning customers. Asking is encouraged. Stalling is not.
- If one fact is missing, build everything around it, mark the gap clearly, and tell me what you need. Do not hold up the whole site for one answer.
- After each change, tell me plainly what you did and why.
- If I ask for something that is a bad idea, say so and explain why. If I confirm, do it my way.
- Never invent a fact about the business. Ask me instead.
- Explain any technique I might not know. Assume I am new to this and want to learn, not just receive output.

## Facts you may use

- Business name: Ageless
- Founder: Amin Osman
- Amin's title: Founder and Lead Consultant. Never Lead Assessor, and never anything containing a protected health title.
- Service area: Ottawa and Toronto, Ontario
- Phone: 437-457-5307
- Founder background: works across healthcare and IT
- Founder credentials: a BScN, plus CompTIA A+, Network+ and Security+
- Founder experience: in-home care and crisis intervention, focused on older adults
- There is no founder photo. The founder section uses his name only.
- Technical support, remote or on site, is available 24 hours a day, 7 days a week
- Amin runs the whole service himself today. More staff are intended but not hired. Never write "our team" or "our staff" as though they already exist.
- Bookings are offered Monday to Sunday, 9am to 9pm Eastern time
- The three booking types are: a free phone call, an in-home installation, and on-site technical support
- The first conversation is a free twenty minute phone call that ends with a package recommendation and the total price for that home
- Ordering is by phone. There is no cart, no checkout and no server behind this site
- Response time commitment: within one business day
- Service area: Ottawa and the surrounding region, and Toronto and the Greater Toronto Area
- Cancellation is deliberately generous. An appointment can be cancelled or moved at any time before it, at no charge. The monthly service can be cancelled at any time, with no notice period, no fee, and a refund of the unused part of the month.
- The business is incorporated. The exact legal name is still to be confirmed, so the footer says "Ageless" until it is.
- Package names, package prices, the network charge, the monthly service price and the legal name are not decided. They are placeholders with honest fallback text, not blanks. See `PLACEHOLDERS.md`.

## Facts you must ask me about before using

- Any price that is not already recorded in `PLACEHOLDERS.md`
- Email address and mailing address
- Specific product brands we sell. Never name a brand without asking first.
- Anything about insurance, bonding, or police checks
- Any professional title, registration, or licence claim beyond the credentials listed above

## Claims that must never appear

These are not "ask first." These are never.

- Never call Amin a nurse, an RN, or registered. He holds a BScN and is not currently licensed, so those words must not appear anywhere on the site.
- Never describe any Ageless service as nursing, clinical, diagnostic, or therapeutic. See "Language that must not appear" above.
- Never imply Ageless answers medical emergencies. Ageless is not an emergency response service. Emergency alerts route to 911 and to the family's emergency contacts. The 24/7 availability is for technical support, remote or on site, and the copy must always say so.
- Never write invented statistics, testimonials, client names, or credentials.
