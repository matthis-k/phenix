# Phenix workspace

This repository is the root Phenix integration superflake. It aggregates locked
Phenix subflakes and exposes the composed packages, applications, modules, and concrete
NixOS configurations. It does not own feature implementation.

## Repository boundaries

- `phenix-de` owns desktop packages and NixOS/Home Manager desktop configuration.
- `phenix-hosts` owns concrete systems, hardware, storage, users, secrets, networking,
  and host-specific services.
- `phenix-nvim` owns the configured Neovim package.
- `phenix-agent-harness` owns the Pi coding-agent runtime and configuration.
- `phenix-packages` owns shared development packages and related Home Manager modules.
- `phenix-tend` owns deterministic verification behavior.
- `phenix-stitch` owns the multi-repository dependency graph and coordinated Git actions.
- `phenix-pins` owns shared upstream revisions.

Do not copy feature configuration into the root to avoid changing another repository.
Change the owning repository, validate it there, merge it, then update the root lock.

## Aggregate contract

The root `flake.lock` is the authoritative aggregate revision set. Root input overrides
must make child flakes follow the root instance of shared dependencies whenever those
inputs represent the same source.

A valid root revision must:

- point only to merged child revisions that passed their local CI,
- pass strict Stitch lock-derived graph verification,
- pass the root Tend `ci` profile,
- pass complete `nix flake check`,
- evaluate both concrete NixOS configurations,
- contain no temporary migration workflows or diagnostic artifacts.

The current concrete systems are:

- `nixosConfigurations.matthisk-laptop-newxos`
- `nixosConfigurations.matthisk-desktop-newxos`

The `*-newxos` names are temporary compatibility names. Do not rename them until the
migrated systems have been activated and rollback-tested on physical hardware.

## Workspace model

Phenix does not use Git submodules or committed gitlinks. Locked mode derives the graph
from flake inputs and `flake.lock`. Local developer worktrees are optional mappings used
by Stitch and do not alter CI truth.

The conventional local workspace is `${PHENIX_WORKSPACE:-$HOME/phenix}/repos`.
Repository paths must not be encoded into the root flake.

## Verification

Use Tend profiles instead of ad hoc check scripts:

```text
tend check --profile git-hook --context local
tend check --profile pre-push --context local
tend check --profile manual --context local
tend check --profile ci --context ci --base <base> --head <head>
```

The root development shell provides these aliases:

```text
repo-hook
repo-pushgate
repo-check
repo-fix
```

Use Stitch for graph and coordinated repository operations:

```text
stitch graph verify --workspace . --source locks --strict
stitch hooks plan --all
stitch hooks install --all
```

Each feature repository must pass its own verification before the root input is updated.
The root check is an integration gate, not a replacement for child checks.

## Agent runtime

The supported coding-agent integration is the Pi-based `phenix-agent-harness`. Do not
restore old OpenCode routing documentation, OpenCode wrapper assumptions, or deprecated
subagent packages in the root.

Agent behavior is contract-driven and should keep deterministic validation, state
transitions, output verification, and permissions in TypeScript/Nix rather than relying
on prompt-only enforcement.

## Migration policy

The first migration pass preserves behavior before redesign. Existing QML, Lua, host
names, option names, and compatibility environment variables may remain until the
systems are proven on hardware.

When doing follow-up cleanup:

1. Identify the owning repository.
2. Preserve or add behavior-level tests before moving source files.
3. Remove only compatibility that is no longer consumed.
4. Keep hardware and storage policy explicit.
5. Update the root lock and run the aggregate gate after merging the child change.

The current migration status and remaining acceptance gates are documented in
`ROADMAP.md`.

## Secrets and destructive actions

Encrypted SOPS payloads may be committed. Plaintext secrets and host age identities may
not be read, logged, or committed unless explicitly required and approved.

Commit, push, merge, destructive Git actions, secret/auth changes, and permission
weakening remain explicit actions. Never bypass a failed check merely to update an input
revision.
