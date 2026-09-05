# AGENTS.md

The house rules for this project live in **[CLAUDE.md](CLAUDE.md)**. Read that
file. Everything in it applies here.

This file exists only because some tools look for `AGENTS.md` by name. It is a
pointer, deliberately, and not a copy.

It was briefly a full duplicate of `CLAUDE.md`, created as a side effect while
the site was being converted to the retail model. That is a bad idea for the
same reason this site keeps its header in one place and its settled strings in
one token each: two copies of the same rules drift apart, and the moment they
do, nobody knows which one is true. A stale safety rule is worse than a
missing one.

If you are about to change how this project works, read these three first:

| File | What it is |
|---|---|
| `CLAUDE.md` | The house rules. Tone, safety, accessibility, confirmed facts, and the claims that must never appear. |
| `PLACEHOLDERS.md` | Every fact still undecided, what it means, and which pages must carry it. |
| `LEGAL.md` | What the terms and privacy policy do not cover, and what a lawyer still needs to rule on. |

Two rules are worth repeating outside `CLAUDE.md`, because they are the ones
that do real damage when missed:

1. **Never merge or push to `main`.** It is production, it publishes to the
   live site with no staging step, and the only way back is another push. Run
   `tools/check-tbd.sh` and `tools/audit.sh` first, and confirm the work is
   actually finished.
2. **Never invent a fact.** If something is undecided, add a placeholder with
   honest fallback text and register it in `PLACEHOLDERS.md`. Do not guess a
   price, a package name, or a credential.
