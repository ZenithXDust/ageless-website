# Placeholders

This is the file to open when you are ready to fill things in.

Several facts about Ageless are not decided yet: the package names, the
prices, the exact registered legal name. Rather than invent them or leave
holes in the pages, each one is written into the site as a placeholder that
already reads correctly.

## Three states

Two kinds of placeholder, and a third state that is about a placeholder not
being there at all.

**Undecided, and blocking.** Nobody has settled this fact yet.

```html
<span class="tbd" data-tbd="PACKAGE_1_PRICE">Call for pricing</span>
```

`tools/check-tbd.sh` counts these and exits nonzero while any remain. They
are what the pre-merge check exists to find.

**Settled, and centralised.** This fact *is* decided, but it appears on more
than one page, and a site where each page carries its own wording of the same
promise is a site that ends up contradicting itself.

```html
<span class="settled" data-settled="VISIT_MODEL">a free twenty minute phone call</span>
```

These are reported separately and are **not** counted as outstanding, because
nothing is waiting on them. A settled token is a maintenance aid, not
unfinished work.

Keeping the two apart is what lets the check reach zero. If every token
counted as outstanding forever, the gate could never pass, and a gate that
can never pass is a gate you learn to ignore.

**Expected but missing.** The third state, and the one that matters most. A
page the manifest says must carry a token does not carry it. Its evidence is
an absence, so counting what is present cannot find it. See the manifest
below.

## The four rules

1. **The text must be a true, publishable sentence on its own.** This applies
   to both kinds. If a token is never revisited, a visitor still reads
   something honest and correct. A raw token, a dollar sign with nothing
   after it, or the word TODO must never appear in visible copy.
2. **This is the same principle as `js/photos.js`.** That file deletes a
   reserved photo space when the photograph does not exist yet, rather than
   showing a broken image icon. The page is complete either way. Placeholders
   do the same thing with words.
3. **`js/tbd.js` shows them to you and to nobody else.** Open any page from
   your own disk, or from localhost, and undecided placeholders are marked
   amber with a dashed outline, settled ones a quieter green with a dotted
   one, each labelled with its token. On the live domain the script does
   nothing at all and everything reads as ordinary copy.
4. **`tools/check-tbd.sh` lists what is left.** One command, before merging.

## How to fill one in

Find the token below, decide the real answer, then replace the **whole span**
with the real text. Delete the span, not just its contents.

Before:

```html
<p>The Foundation costs <span class="tbd" data-tbd="PACKAGE_1_PRICE">Call for pricing</span>.</p>
```

After:

```html
<p>The Foundation costs $890 plus tax.</p>
```

Then run `tools/check-tbd.sh` to confirm it has gone from the list.

A settled token is different. You are not filling it in, you are **changing a
decision**, so change it in every page at once and update the entry here at
the same time. `tools/check-tbd.sh --by-token` tells you every place it
appears.

## The manifest, which is what stops a false pass

There is a third state, and it is the one that matters most.

A token can be **expected but missing**. If `solutions.html` is supposed to
carry `PACKAGE_1_PRICE` and does not, then the page is quietly wrong: it is
either missing a price entirely or, worse, somebody typed a real number in
without telling anybody. Counting only the tokens that are present cannot
detect that, because the evidence is the absence.

Without this, the check reports a clean pass at the exact moment the work has
not started: no tokens placed anywhere means nothing outstanding means exit
zero. That is a green light pointing the wrong way.

So the manifest below names which pages must contain each token.
`tools/check-tbd.sh` reads it from this file, and fails naming the file if a
page that should carry a token does not.

Keep it accurate. Adding a token to a page means adding the page here in the
same change.

<!-- MANIFEST-START -->
```
# TOKEN               pages that must contain it
PACKAGE_1_NAME        index.html solutions.html pricing.html
PACKAGE_1_PRICE       solutions.html pricing.html
PACKAGE_1_CONTENTS    solutions.html
PACKAGE_2_NAME        index.html solutions.html pricing.html
PACKAGE_2_PRICE       solutions.html pricing.html
PACKAGE_2_CONTENTS    solutions.html
PACKAGE_3_NAME        index.html solutions.html pricing.html
PACKAGE_3_PRICE       solutions.html pricing.html
PACKAGE_3_CONTENTS    solutions.html
PACKAGE_4_NAME        index.html solutions.html pricing.html
PACKAGE_4_PRICE       solutions.html pricing.html
PACKAGE_4_CONTENTS    solutions.html
NETWORK_CHARGE        solutions.html pricing.html how-it-works.html faq.html
INSTALL_INCLUDED      pricing.html how-it-works.html faq.html
MONTHLY_PRICE         pricing.html how-it-works.html faq.html
MARGIN_STATEMENT      pricing.html
LEGAL_NAME            terms.html
PACKAGE_ORDER_RULE    solutions.html pricing.html
VISIT_MODEL           index.html how-it-works.html pricing.html booking.html
VISIT_MODEL           contact.html faq.html
WORKSHOP_TALK_LENGTH  workshops.html
WORKSHOP_DATES        workshops.html
WORKSHOP_SERIES_LENGTH workshops.html
VISIT_MODEL           resources-medical-alert-questions.html resources-pill-dispensers.html
VISIT_MODEL           resources-stove-left-on.html resources-talking-to-a-parent.html
```
<!-- MANIFEST-END -->

## Checking what is left

```
tools/check-tbd.sh              all three states, the counts, and an exit code
tools/check-tbd.sh --by-token   the same thing grouped by token
```

Exit codes:

- `0` clean. No undecided token is present, no expected token is missing.
  Settled tokens may still be there, and that is correct.
- `1` work remains. An undecided token is still on a page, or a page named in
  the manifest is missing a token it should carry.
- `2` a fault. A placeholder of either kind has text that must not be
  published, a settled token is worded two different ways on different pages,
  the noindex tripwire fired, or the scan could not run.

## The noindex tripwire

The preview site carries a `robots` noindex tag in the head of every page so
that Google never indexes it. That tag is injected at publish time into the
preview repository only. **It must never be committed on `retail-model`**,
because merging it would tell Google to deindex the real site.

`tools/check-tbd.sh` fails with exit 2 if that tag appears anywhere in the
tracked working tree, apart from a small allowlist of tooling and
documentation files that necessarily talk about it, which are
`tools/check-tbd.sh`, `tools/deploy-preview.sh`, `tools/preview-inject.py`,
`PLACEHOLDERS.md`, `CLAUDE.md` and `README.md`. The script prints the
allowlist when it runs, so the exemption is visible rather than hidden.

A GitHub Action runs the same script on every push and writes the result into
the run summary. It reports, it does not block. Publishing is a legacy Pages
branch build and is not driven by Actions, so nothing in that workflow can
stop the site going live.

---

# Decisions already made

Changing any of these changes copy on more than one page. This is where you
would come to change them.

## The four packages

The six worries that `solutions.html` was already organised around are
grouped into four packages:

| Package | Absorbs |
|---|---|
| 1. The Foundation | Home safety basics, staying connected |
| 2. The Daily Routine | Kitchen and fire, medication |
| 3. Help When It's Needed | Falls and getting help |
| 4. Knowing the Day Went Right | Activity and daily check-ins |

Falls and check-ins were deliberately **not** merged, which would have given
the tidier number of three. Families who choose passive check-ins are
frequently the ones whose parent will not wear a pendant, and the site
already says so plainly: a pendant left on the dresser protects nobody.
Bundling the two would force such a family to buy the exact thing the site
tells them will not work.

## The packages are independent

**All four stand alone and can be bought in any order. The prices do not
compound. There is no package anybody has to buy first.**

The Foundation is not a base layer. The only thing packages 2, 3 and 4
genuinely depend on is a working network in that particular home. They do not
depend on the rest of the Foundation: the motion lighting, the keyless entry,
the leak sensors. Making the Foundation compulsory would force a family who
wants a pill dispenser to also buy lighting they may not need, which is the
exact behaviour this site argues against everywhere else.

Carried on the site by `PACKAGE_ORDER_RULE`, which is settled.

> **If you ever change this** and decide the Foundation is a prerequisite,
> the prices compound and the shop page has to say so in the price itself,
> not in a footnote. Revisit every `PACKAGE_N_PRICE` at the same time.

## How the network work is priced

**A fixed package price, plus a separately named network charge which is
itself a published fixed number.** Not "varies". Not "from".

The mechanism, which the copy has to make plain:

1. The free phone call asks the two or three questions needed to know whether
   that home needs network work.
2. The caller is told **the total** on that call, before anybody comes out.
3. The network charge reads on the page as a known, named item with a price
   on it, never as a surprise added later.

Two reasons this was chosen over the alternatives, recorded so nobody
reopens it in six months:

- A "from" price is the exact thing the families reading this site have been
  burned by before. It undoes the one promise the site makes best, which is
  that they know the cost before they spend anything.
- Unpriced variance cannot be absorbed at this volume. One bad house would
  take the margin off several good ones.

### Rejected, and why

**Rejected: a single fixed price with the network work absorbed.** Requires
volume that does not exist yet to average out across houses. One difficult
house wipes out the margin on several straightforward ones. Revisit only if
volume grows enough that the average becomes reliable rather than hopeful.

**Rejected: "from $X", with the network work quoted after the call.** It is
what most trades do, and it is honest in the narrow sense. But "from" is the
word this audience has learned to distrust, and it breaks the promise that a
family knows the total before they spend anything. That promise is the best
piece of writing on the site and it is not worth trading for pricing
convenience.

## One monthly price, not one per package

`MONTHLY_PRICE` is a single price applying to every customer, whatever they
bought. Simpler to explain, simpler to sell, and consistent with the monthly
service being the product rather than an add-on priced off the hardware.

> **The alternative**, if a four-package home turns out to cost meaningfully
> more to keep running than a one-package home: split it into
> `PACKAGE_1_MONTHLY` through `PACKAGE_4_MONTHLY`, one per row of the pricing
> table. The table already has a monthly column per package, so the change is
> mechanical. Say plainly on the page which it is, because a monthly price
> that varies and is not explained reads as a price being hidden.

---

# Undecided, and blocking

Seventeen tokens. These are what `tools/check-tbd.sh` counts.

The **appears in** line is filled once the tokens are placed in the pages, and
`tools/check-tbd.sh --by-token` regenerates it at any time, so it cannot
silently go out of date.

## The packages

### PACKAGE_1_NAME

- **What it is:** the customer-facing name of the first package, the one
  covering lighting, locks, leaks, heat and staying in touch.
- **Why it matters:** it is the first package a visitor reads, and the
  cheapest, so it sets the expectation for the other three.
- **Good answer:** something plain that says what it does. Avoid anything
  that sounds like a tier, because these are not tiers.
- **Example:** `The Foundation`, `Home Essentials`, `The Basics`
- **Fallback now:** The Foundation
- **Appears in:** not yet placed

### PACKAGE_1_PRICE

- **What it is:** what the first package costs, before tax and before any
  network charge.
- **Why it matters:** publishing prices is the whole point of the retail
  model. A package with no number is a consultation with extra steps.
- **Good answer:** a fixed number in Canadian dollars. Not a range, not a
  "from". See the pricing decision above.
- **Example:** `$890 plus tax`
- **Fallback now:** Call for pricing
- **Appears in:** not yet placed

### PACKAGE_1_CONTENTS

- **What it is:** the plain list of what is actually supplied and installed.
- **Why it matters:** this is what a family compares against buying the parts
  themselves online. Vagueness here reads as something being hidden.
- **Good answer:** concrete items, in ordinary words, not model numbers.
- **Example:** `Motion lighting on the route from the bed to the bathroom,
  keyless entry, leak sensors under the sink and behind the washing machine,
  a temperature alert, and video calling that works on the first try.`
- **Fallback now:** the short description already on the shop page, which
  describes the area of the home rather than the specific items
- **Appears in:** not yet placed

### PACKAGE_2_NAME, PACKAGE_2_PRICE, PACKAGE_2_CONTENTS

The kitchen, fire and medication package. Same three questions as above.

- **Fallbacks now:** The Daily Routine / Call for pricing / the existing
  worry copy
- **Appears in:** not yet placed

### PACKAGE_3_NAME, PACKAGE_3_PRICE, PACKAGE_3_CONTENTS

The falls package.

- **Fallbacks now:** Help When It's Needed / Call for pricing / the existing
  worry copy
- **Appears in:** not yet placed

### PACKAGE_4_NAME, PACKAGE_4_PRICE, PACKAGE_4_CONTENTS

The activity and check-ins package.

- **Fallbacks now:** Knowing the Day Went Right / Call for pricing / the
  existing worry copy
- **Appears in:** not yet placed

## The rest

### NETWORK_CHARGE

- **Added during the build**, and not on the original token list. It exists
  because of the pricing decision above: the network work is a separately
  named item with its own published price.
- **What it is:** the fixed price for making a home's network good enough to
  run the equipment reliably. Mesh coverage where a pendant is actually worn,
  no dead zones where a sensor sits.
- **Why it matters:** it is the difference between a published total and a
  surprise. It is also the single most likely thing to be read as a hidden
  extra, so the number has to be visible next to the package prices rather
  than explained after them.
- **Good answer:** one fixed number, and a plain statement of who needs it.
  The free call determines whether a given home does, and the caller is told
  the total before anybody visits.
- **Example:** `$340 plus tax, and we tell you on the call whether your
  parent's home needs it.`
- **Fallback now:** Some homes need network work first, and some do not. We
  ask two or three questions on the call and tell you the total before anybody
  comes out.
- **Appears in:** not yet placed
- **Note:** the fallback is deliberately true whichever number you pick, and
  it already describes the mechanism, so the page reads correctly today.

### INSTALL_INCLUDED

- **What it is:** whether installation is inside the package price or charged
  on top, and if on top, how much.
- **Why it matters:** installation is one of the three things this business
  actually sells. Leaving it ambiguous invites the assumption that the price
  covers hardware only, which is the assumption that produces an argument on
  the day.
- **Good answer:** a plain yes or no, with the consequence attached.
- **Example:** `Installation is included in every package price.` or
  `Installation is $180 flat, whatever the package.`
- **Fallback now:** Installation is included. We fit it, set it up and test
  it, and we take the packaging away with us.
- **Appears in:** not yet placed
- **Note, and this one wants an answer:** the pricing decision named exactly
  two line items, the package and the network charge. That implies
  installation sits inside the package price, and the fallback above asserts
  it does. If that is wrong, this is the highest priority token on the list,
  because it is the one most likely to be read as a promise.

### MONTHLY_PRICE

- **What it is:** what the ongoing monthly service costs.
- **Why it matters:** the monthly service is the actual product. It is the
  number that decides whether this business is worth running.
- **Good answer:** one price per household, per month, in Canadian dollars.
  See the decision above about not varying it per package.
- **Example:** `$45 a month plus tax`
- **Fallback now:** Call for the monthly price
- **Appears in:** not yet placed

### MARGIN_STATEMENT

- **What it is:** the honest sentence about how Ageless makes its money.
- **Why it matters:** the pricing page used to say Ageless takes no
  commission from manufacturers, which was a strong trust line under a
  consulting model. As a retailer you make margin on the product, so that
  line became misleading and had to go. This replaces it.
- **Fallback now:** option 2 below.
- **Appears in:** not yet placed

Three honest options, all true as far as is known:

1. *Ageless makes its money on the packages it sells and on the monthly
   service, not on commission from any one manufacturer.*
   Keeps most of the old trust line. It asserts that you take no manufacturer
   commission, which is a claim you would then have to keep true.
2. *Ageless is a retailer. We buy the equipment and sell it to you as part of
   a package, and what we make on it is inside the package price. No
   manufacturer pays us to recommend their product.*
   **This is the fallback**, because it states the margin plainly and makes
   no claim beyond what you have already confirmed.
3. *The package price includes what the equipment costs us and what we make
   on it. Nothing is added afterwards.*
   Shortest and safest. Says less, promises less, and drops the independence
   point entirely.

### WORKSHOP_TALK_LENGTH

- **What it is:** how long the free community talk runs, and whether you stay
  afterwards.
- **Why it matters:** a library or a seniors centre cannot put something in a
  room booking without a length. It is the first question a host asks and the
  page currently answers it with a hedge.
- **Good answer:** a duration, and what happens at the end of it.
- **Example:** `About 45 minutes, and we stay for another half hour for
  questions.`
- **Fallback now:** The talk takes about an hour, and we stay afterwards for
  as long as there are questions.
- **Appears in:** workshops.html
- **Note:** the fallback commits you to roughly an hour. If that is wrong,
  change it before anybody books a room on the strength of it.

### WORKSHOP_DATES

- **What it is:** whether there is a public schedule somebody can turn up to,
  or whether every talk is arranged with a host.
- **Why it matters:** an older adult reading this page wants to know how to
  attend one. Right now the honest answer is that they cannot, directly,
  because talks are booked by venues.
- **Good answer:** either a place the schedule lives, or a plain statement
  that talks are arranged through venues and how to ask.
- **Example:** `Upcoming talks are listed at your local library. Call us and
  we will tell you what is booked in your area.`
- **Fallback now:** Talks are arranged with the place that hosts them, so ask
  at your library or centre, or call us and we will tell you what is coming
  up.
- **Appears in:** workshops.html

### WORKSHOP_SERIES_LENGTH

- **What it is:** how many sessions the hands-on series runs to, and how
  often.
- **Why it matters:** it is a commitment being asked of somebody, and asking
  people to commit to an unspecified number of sessions is how you get an
  empty second week.
- **Good answer:** a number of sessions and a frequency.
- **Example:** `Six sessions, one a week, each about ninety minutes.`
- **Fallback now:** The series runs over several sessions. Call and we will
  tell you how many and how often, so you know what you are committing to
  before you start.
- **Appears in:** workshops.html

### LEGAL_NAME

- **What it is:** the exact registered legal name of the incorporated
  business.
- **Why it matters:** it belongs in the terms and in the footer. `LEGAL.md`
  already records that the spelling was given verbally and could not be
  transcribed reliably, and a wrong legal name in a contract term is worse
  than no legal name at all.
- **Good answer:** copied character for character off the articles of
  incorporation, not from memory.
- **Example:** `1234567 Ontario Inc., operating as Ageless`
- **Fallback now:** Ageless
- **Appears in:** not yet placed

## A note on the workshops page

`workshops.html` carries no prices and never will: the talks and the series
are both free. It also carries no `MARGIN_STATEMENT`, no package tokens and no
`VISIT_MODEL`, deliberately. That page is community work and is kept separate
from the part of the site that sells, so the tokens that exist to describe
selling do not belong on it.

The one thing on that page that mentions nursing is the footer disclaimer,
which is mandated and unchanged. It is outside `<main>` and is not page copy.

---

# Settled, and centralised

Two tokens. Decided, not waiting on anybody, and kept in one place only
because they appear on several pages and must not drift apart.
`tools/check-tbd.sh` reports them separately and does **not** count them as
outstanding.

### PACKAGE_ORDER_RULE

- **What it is:** the sentence saying the packages can be bought in any
  order, with nothing required first.
- **Why it is centralised:** it is the difference between a shop and a
  funnel. If one page said it and another implied otherwise, the site would
  be quietly misleading people about what they have to spend.
- **Settled as:** Every package works on its own. Buy one, or several, in
  whatever order suits. There is no package you have to buy first, and if the
  home needs network work that is a separate named item on the price list
  rather than another package.
- **Why the wording changed during the build:** the first draft said each
  package "includes the setup that home needs". With the network charge
  billed as its own published line, "includes" reads as "free", which
  would have been a quiet contradiction of the pricing page. The network work
  is in scope of every package; it is billed separately because not every home
  needs it.
- **Appears in:** not yet placed
- **To change it:** see the package independence decision above, and revisit
  every `PACKAGE_N_PRICE` at the same time.

### VISIT_MODEL

- **What it is:** how somebody gets from interested to buying. The front
  door, replacing the $249 assessment.
- **Why it is centralised:** it is named on the home page, how it works,
  pricing and booking. Four pages describing the first conversation four
  slightly different ways is how a visitor stops believing any of them.
- **The exact string on the pages:** `a free twenty minute phone call`

  It is deliberately short, because it is dropped into the middle of other
  sentences on four pages. The surrounding copy carries the rest of the
  promise: that it ends with which package suits and the total for that home,
  and that there is no obligation.
- **The rest of the model, which the copy states:** the call asks the two or
  three questions needed to know whether that home needs network work, and
  the caller is told the total on that call, before anybody comes out.
- **Appears in:** index.html, how-it-works.html, pricing.html, booking.html
- **Checked automatically:** `tools/check-tbd.sh` fails with exit 2 if this
  string is worded differently in different places, which is the entire
  reason it is a settled token rather than plain copy.

Two alternatives, kept so the decision can be reversed by editing this one
token and the copy it names:

1. **A small fitting fee, credited against the package.** It filters out
   tyre-kickers and pays for the trip. It also adds friction at exactly the
   point where an anxious family is most likely to stop, and reintroduces the
   thing the retail model was meant to remove.
2. **Keep the $249 assessment, as an optional written report.** Some families
   genuinely want the document, for a sibling or for a care conference, and it
   is real work worth real money. Sold as an extra rather than as the way in.
   The risk is that it quietly becomes the front door again.
