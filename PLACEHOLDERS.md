# Placeholders

This is the file to open when you are ready to fill things in.

Several facts about Ageless are not decided yet: the package names, the
prices, the exact registered legal name. Rather than invent them or leave
holes in the pages, each one is written into the site as a placeholder that
already reads correctly.

## What a placeholder looks like

```html
<span class="tbd" data-tbd="PACKAGE_1_PRICE">Call for pricing</span>
```

Two parts. A token, so it can be found again, and fallback text that is true
and publishable exactly as it stands.

## The four rules

1. **The fallback must be a true, publishable sentence on its own.** If a
   token is never filled in, a visitor still reads something honest and
   correct. A raw token, a dollar sign with nothing after it, or the word
   TODO must never appear in visible copy.
2. **This is the same principle as `js/photos.js`.** That file deletes a
   reserved photo space when the photograph does not exist yet, rather than
   showing a broken image icon. The page is complete either way. Placeholders
   do the same thing with words: unfinished is visible to you and invisible
   to a visitor.
3. **`js/tbd.js` shows them to you and to nobody else.** Open any page from
   your own disk, or from localhost, and every placeholder is marked amber
   with a dashed outline and its token name beside it. On the live domain the
   script does nothing at all, and the fallback text reads as ordinary copy.
4. **`tools/check-tbd.sh` lists what is left.** One command, run before
   merging.

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

## Checking what is left

```
tools/check-tbd.sh              every outstanding token, with file and line
tools/check-tbd.sh --by-token   the same thing grouped by token
```

Exit codes: `0` nothing left, `1` placeholders remain, which is normal and
expected for now, `2` a placeholder breaks rule 1 and wants fixing.

A GitHub Action runs the same script on every push and writes the result into
the run summary. It reports, it does not block. Publishing is a legacy Pages
branch build and is not driven by Actions, so nothing in that workflow can
stop the site going live.

---

# Decisions already made

These were settled while the retail rewrite was being built. They are
recorded here because changing any of them changes copy on more than one
page, and this is where you would come to change them.

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

## How the packages relate to each other

**All four stand alone and can be bought in any order. The prices do not
compound. There is no package you have to buy first.**

The Foundation is not a base layer, and this was a real decision rather than
an obvious one. The only thing packages 2, 3 and 4 genuinely depend on is a
working network in that particular home. They do not depend on the rest of
the Foundation: the motion lighting, the keyless entry, the leak sensors.

Making the Foundation compulsory would therefore force a family who wants a
pill dispenser to also buy lighting they may not need, which is the exact
behaviour this site argues against everywhere else.

So the network is handled a different way: **every package includes whatever
network work that home needs to make that package actually run.** It is part
of the installation and part of the price, not a separate purchase. That also
puts the emphasis where the business actually is, on the choosing, the
installing and the keeping it working, rather than on the box.

The token `PACKAGE_ORDER_RULE` carries this sentence on the site.

> **If you change this**, and decide the Foundation is a prerequisite after
> all, then the prices compound and the shop page has to say so in the price
> itself, not in a footnote. Package 2 would have to read as "Foundation plus
> $X", or as a combined total. Change `PACKAGE_ORDER_RULE`, and revisit every
> `PACKAGE_N_PRICE` at the same time.

## One monthly price, not one per package

`MONTHLY_PRICE` is a single price that applies to every customer, whatever
they bought. Simpler to explain, simpler to sell, and it is consistent with
the monthly service being the product rather than an add-on priced off the
hardware.

> **The alternative**, if it turns out that a four-package home costs
> meaningfully more to keep running than a one-package home: split it into
> `PACKAGE_1_MONTHLY` through `PACKAGE_4_MONTHLY`, one per row of the pricing
> table. The table already has a monthly column per package, so the change is
> mechanical: replace the single repeated token with four distinct ones. Say
> plainly on the page which it is, because a monthly price that varies and is
> not explained reads as a price that is being hidden.

---

# The tokens

Seventeen tokens, plus one added during the build and marked as such.

The **appears in** line is filled in once the tokens are placed in the pages,
and `tools/check-tbd.sh --by-token` regenerates it at any time, so it cannot
silently go out of date.

## Packages

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

- **What it is:** what the first package costs, before tax.
- **Why it matters:** publishing prices is the whole point of the retail
  model. A package with no number is a consultation with extra steps.
- **Good answer:** a number in Canadian dollars, and a decision about whether
  it is fixed or a starting point. See the note on price shape below.
- **Example:** `$890 plus tax`, or `from $890 plus tax`
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

### A question about the shape of every price

Because each package includes whatever network work that home needs, the real
cost varies between a house that already has good coverage and a house that
does not.

You have to pick one of these, and the page has to say which:

1. **A fixed price**, and you absorb the difference on awkward houses. Easiest
   to publish, easiest to trust, and it means some jobs are less profitable
   than others.
2. **"From $X"**, with the network work quoted after the free call. Honest,
   and it is what most trades do, but "from" is the word people have learned
   to distrust.
3. **A fixed price plus a separately named network charge**, quoted before
   anything is bought. The most transparent, and the most to explain.

There is no right answer here, only a decision. Whichever you pick goes into
`PACKAGE_N_PRICE`, and the copy around it has to match.

## The rest

### PACKAGE_ORDER_RULE

- **Added during the build**, and not on the original token list. It is here
  because whether the packages stand alone is exactly the kind of fact that
  might change, and it is stated on more than one page.
- **What it is:** the sentence saying the packages can be bought in any
  order, with nothing required first.
- **Why it matters:** it is the difference between a shop and a funnel. If it
  is ever wrong, the site is quietly misleading people about what they have
  to spend.
- **Good answer:** one plain sentence. See the decision recorded above.
- **Fallback now:** Every package works on its own. Buy one, or several, in
  whatever order suits. Each one includes the network setup that home needs
  to make it work, so there is nothing you have to buy first.
- **Appears in:** not yet placed

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
- **Note:** that fallback asserts installation **is** included. If that is
  wrong, this is the highest priority token on the list, because it is the
  one most likely to be read as a promise.

### MONTHLY_PRICE

- **What it is:** what the ongoing monthly service costs.
- **Why it matters:** the monthly service is the actual product. It is the
  number that decides whether this business is worth running.
- **Good answer:** one price per household, per month, in Canadian dollars.
  See the decision recorded above about not varying it per package.
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

### VISIT_MODEL

- **What it is:** how somebody gets from interested to buying. The front door.
- **Why it matters:** it replaces the $249 assessment as the entry product,
  and it is referenced on the home page, how it works, pricing and booking.
- **Fallback now:** a free twenty minute phone call that ends with a
  recommendation of which package suits, with no obligation
- **Appears in:** not yet placed

Two alternatives, kept here so you can switch by editing this one token and
the copy it names:

1. **A small fitting fee, credited against the package.** It filters out
   tyre-kickers and pays for the trip. It also adds friction at exactly the
   point where an anxious family is most likely to stop, and reintroduces the
   thing the retail model was meant to remove.
2. **Keep the $249 assessment, as an optional written report.** Some families
   genuinely want the document, for a sibling or for a care conference, and it
   is real work worth real money. Sold as an extra rather than as the way in.
   The risk is that it quietly becomes the front door again.

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
