# CLAUDE.md

Guidance for Claude Code (claude.ai/code) when working in this repository.

## Repository status

This repository is a scaffold. As of the initial commit it contains only
`README.md` — there is no application source, build system, dependency
manifest, test suite, or CI configuration yet.

**Do not assume tooling exists.** Before suggesting or running a command,
verify the relevant file is actually present (e.g. `package.json`,
`requirements.txt`, `Makefile`). If it is not, say so rather than guessing at
a build or test command.

## Project

`ageless-website` — the website for Ageless. The stack has not been chosen
yet; when it is, replace this section and the one below with the real
architecture and commands.

## Commands

None yet. Once a toolchain is added, document the commands a contributor
actually runs here — install, dev server, build, test (including how to run a
single test), lint, and typecheck — so they don't have to be rediscovered.

## Conventions

- Match the style of surrounding code. When adding the first files of a new
  kind, pick one convention and apply it consistently across the repo.
- Keep the working tree clean: no build output, dependency directories, or
  editor files committed. Add a `.gitignore` alongside the first tooling that
  produces them.
- Commit messages: short imperative subject line describing the change.

## Git workflow

- `main` is the default branch.
- Development happens on feature branches; push with
  `git push -u origin <branch-name>`.
- Do not open a pull request unless it was explicitly requested.

## Keeping this file useful

This file is instructions, not narration — it should hold what is not obvious
from reading the code. Update it in the same change that invalidates it: when
the stack is chosen, when commands change, or when a non-obvious constraint is
introduced. Delete guidance that no longer applies rather than leaving it to
mislead.
