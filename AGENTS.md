# Phenix workspace

This repository is the root Phenix integration superflake. It aggregates locked
subflakes and exposes the composed packages, applications, modules, and concrete
NixOS configurations. Feature implementation belongs in the owning repository.

## Repository ownership

- `phenix-de` owns desktop packages and NixOS/Home Manager desktop configuration.
- `phenix-hosts` owns concrete systems, hardware, storage, users, secrets, networking,
  and host-specific services.
- `phenix-nvim` owns the configured Neovim package.
- `phenix-agent-harness` owns the Pi coding-agent runtime and configuration.
- `phenix-packages` owns shared development packages and Home Manager modules.
- `phenix-tend` owns deterministic verification.
- `phenix-stitch` owns the repository graph and coordinated Git actions.
- `phenix-pins` owns shared upstream revisions.

Change the owning repository, validate it there, merge it, then update the root lock.

## Aggregate contract

The root `flake.lock` is the authoritative aggregate revision set. Shared child inputs
must follow the corresponding root inputs.

A valid root revision must:

- point only to child revisions that passed local CI,
- pass strict Stitch lock-derived graph verification,
- pass the root Tend `ci` profile,
- pass complete `nix flake check`,
- evaluate both concrete NixOS configurations,
- contain no temporary migration workflows or generated diagnostics.

The concrete systems are:

- `nixosConfigurations.matthisk-laptop-phenix`
- `nixosConfigurations.matthisk-desktop-phenix`

## Workspace model

Phenix does not use Git submodules or committed gitlinks. Locked mode derives the graph
from flake inputs and `flake.lock`. Mutable worktrees are optional local Stitch state.

The conventional workspace is `${PHENIX_WORKSPACE:-$HOME/phenix}/repos`.

## Verification

Use Tend profiles instead of ad hoc scripts:

```text
tend check --profile git-hook --context local
tend check --profile pre-push --context local
tend check --profile manual --context local
tend check --profile ci --context ci --base <base> --head <head>
```

Use Stitch for graph and coordinated repository operations:

```text
stitch graph verify --workspace . --source locks --strict
stitch hooks plan --all
stitch hooks install --all
```

## Agent runtime

Pi is the only supported coding-agent application. Provider identifiers in routing
configuration are backend names consumed by Pi, not alternative agent runtimes.

Keep routing, state transitions, output verification, and permissions in TypeScript or
Nix rather than relying on prompt-only enforcement.

## Safety

Encrypted SOPS payloads may be committed. Plaintext secrets and host age identities may
not be read, logged, or committed unless explicitly required and approved.

Commit, push, merge, destructive Git actions, secret/auth changes, and permission
weakening remain explicit actions. Never bypass a failed check to update an input.
