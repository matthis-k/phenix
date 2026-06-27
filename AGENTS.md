# Phenix workspace

This repository is the root Phenix workspace. It aggregates the Phenix subflakes
as Git submodules under `flakes/**`.

Root-level actions are workspace actions. They may inspect, verify, commit, push,
or synchronize multiple submodules together. Do not treat the root repository as
an isolated flake.

Root commits may update submodule gitlinks.

Before committing or pushing from the root, verification must account for:

- root files,
- changed submodule gitlinks,
- dirty or staged files inside submodules,
- affected downstream DAG nodes,
- each affected submodule's own verification contract.

Use `tend` for verification and planning. Use `stitch` for coordinated multi-repo
Git operations. Avoid ad hoc multi-repo Git sequences when an equivalent
`tend`/`stitch` workflow exists.

Direct work inside a submodule must still pass that submodule's local verification.
Do not remove verification just because architecture changes; verification should
target syntax, formatting, linting, compile/eval checks, and behavior-level checks
rather than brittle file-existence assertions.

## Agent guidelines

- Prefer `stitch` for coordinated multi-repo Git operations (status, diff, commit,
  push, sync). Do not use raw `git commit`/`git push` across repos.
- Prefer `tend` for verification/planning (plan, run, explain, status). Do not use
  hand-written ad hoc command sequences when `tend`/`stitch` equivalents exist.
- Before proposing a root commit that touches submodule gitlinks, run
  `tend plan --mode changed` and/or `tend plan --mode staged` to understand the
  verification scope.
- When working inside a submodule, operate from that submodule's directory and
  run its own verification (`tend run` or its shell hooks) before committing.
- The `tend --affected-dag` flag exists to scope checks to downstream nodes.
  Ensure any verification workflow that can affect multiple DAG nodes passes this
  flag so that downstream consumers are verified too.
