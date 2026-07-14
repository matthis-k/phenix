# Workspace state model

Phenix does not use Git submodules, gitlinks, or a committed Stitch repository list as
the normal source of workspace truth.

- **Locked mode** derives the aggregate DAG from root flake inputs and `flake.lock`.
  This is the CI and `nix flake check` truth and does not require local child checkouts.
- **Workspace mode** maps locked repositories to mutable local worktrees through Stitch
  state under XDG configuration/state paths.
- **Mixed mode** keeps the lock graph authoritative while using selected local worktrees
  for commands that require edits or Git operations.

The conventional local layout is:

```text
${PHENIX_WORKSPACE:-$HOME/phenix}/repos/<repository>
```

Local paths are developer state and must not be encoded into root flake inputs or
committed topology files.

The integration sequence is:

1. Change and validate the owning child repository.
2. Merge the child revision.
3. Update the root input and lock graph.
4. Verify the strict Stitch graph and complete root Tend/Nix gate.
5. Merge the root only when the locked aggregate passes.

Commit, push, merge, destructive actions, secret/auth changes, and permission weakening
remain explicit-ask gated. A local override must never make CI validate a graph different
from the committed lock graph.
