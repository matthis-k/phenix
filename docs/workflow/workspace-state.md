# Workspace state model

Phenix no longer uses Git submodules or a committed Stitch repo list as the
normal source of workspace truth.

- **locked mode** derives the workspace DAG from `flake.lock` and remote flake
  inputs. This is the CI and `nix flake check` truth and must not require local
  checkouts under `repos/`.
- **workspace mode** may use local repo mappings from Stitch state under XDG
  state/config/cache paths for developer operations.
- **mixed mode** keeps the lock file authoritative while allowing selected local
  repo overrides for commands that need a working tree.

Local checkouts belong under `/repos/` or XDG-configured paths and are ignored by
Git. Commit, push, destructive actions, secret/auth changes, and permission
weakening remain explicit-ask gated.
