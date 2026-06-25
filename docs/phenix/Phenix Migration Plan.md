---
title: Phenix Migration Plan (Archived)
type: note
permalink: newxos/phenix/phenix-migration-plan
archive: true
---

> **DEPRECATED — This document describes the old `phenix-sync` plan.**
>
> The old `phenix sync` / `phenix-sync` tool has been retired.
>
> **`stitch` is the replacement** — a standalone multi-repo Git changeset coordinator.
>
> - Docs: `docs/stitch.md`
> - Config: `.stitch.json` (not `sync.json`)
> - State: `.stitch/changesets/<id>.json` (not DAG-based)
>
> The old `sync.json` files in individual repos are preserved for reference
> but are no longer consumed by any active tool. `tend` covers the
> maintenance/check workflow that `sync.json` used to describe.
>
> See `docs/stitch.md` and `docs/tend.md` for current documentation.

# Phenix Migration Plan (Archived)

## Required repos

- `matthis-k/phenix-pins`
- `matthis-k/phenix-packages`
- `matthis-k/phenix-shell`
- `matthis-k/phenix-nvim`
- `matthis-k/phenix-hosts`
- `matthis-k/phenix-tools`
- `matthis-k/phenix`

`phenix-sync` is **not** a separate repo. Sync/gate/style/migration tooling lives in `phenix-tools`.

`phenix-gate` is only split if gate/handoff tooling grows large enough to deserve its own lifecycle. Default is `phenix-tools`.

## Local layout

```
~/phenix
  flake.nix
  flake.lock
  .gitmodules
  README.md

  phenix-pins/
  phenix-packages/
  phenix-shell/
  phenix-nvim/
  phenix-hosts/
  phenix-tools/
```

## `phenix-tools` responsibility

Cross-repo developer and maintenance tooling:

```
sync          # update DAG / lock synchronization tool
gate          # repo-gate / handoff checks, if migrated here
style         # Phenix flake consistency checks
migrate       # optional migration helpers
local         # optional local checkout helpers
```

### Exposed apps/packages

```nix
{
  packages.${system} = {
    sync = ...;
    gate = ...;
    style = ...;
    default = self'.packages.sync;
  };

  apps.${system} = {
    sync = ...;
    gate = ...;
    style = ...;
    default = self'.apps.sync;
  };

  checks.${system} = {
    default = ...;
    sync = ...;
    style = ...;
  };
}
```

Single-binary approach:

```bash
phenix-tools sync plan --changed phenix-pins
phenix-tools gate check
phenix-tools style check
```

Multi-binary approach:

```bash
phenix-sync plan --changed phenix-pins
phenix-gate check
phenix-style check
```

Either is acceptable. Repo owner is `phenix-tools` in both cases.

## Dependency graph

```
phenix-pins
  -> phenix-packages
  -> phenix-shell
  -> phenix-nvim
  -> phenix-hosts
  -> phenix-tools

phenix-packages
  -> phenix-shell
  -> phenix-nvim
  -> phenix-hosts

phenix-shell
  -> phenix-hosts

phenix-nvim
  -> phenix-hosts

phenix-tools
  may depend on phenix-pins
  should not depend on phenix-hosts unless absolutely necessary
```

`phenix-tools` depends on `phenix-pins` for shared nixpkgs/tooling pins.

May depend on `phenix-packages` if tools need shared package overlays.

Avoid depending on `phenix-hosts`; basic maintenance tooling should not be blocked by host config failures.

## Sync config
Each repo declares its own `sync.json` at its root.

```text
phenix-pins/sync.json
phenix-packages/sync.json
phenix-shell/sync.json
phenix-nvim/sync.json
phenix-hosts/sync.json
phenix-tools/sync.json
```

The sync tool discovers repos by scanning for `sync.json` files under `~/phenix/`.

### phenix-pins/sync.json

```json
{
  "dependsOn": [],
  "updateInputs": [],
  "checks": ["nix flake check"]
}
```

### phenix-packages/sync.json

```json
{
  "dependsOn": ["phenix-pins"],
  "updateInputs": ["phenix-pins"],
  "checks": ["nix flake check"]
}
```

### phenix-shell/sync.json

```json
{
  "dependsOn": ["phenix-pins", "phenix-packages"],
  "updateInputs": ["phenix-pins", "phenix-packages"],
  "checks": ["nix flake check"]
}
```

### phenix-nvim/sync.json

```json
{
  "dependsOn": ["phenix-pins", "phenix-packages"],
  "updateInputs": ["phenix-pins", "phenix-packages"],
  "checks": ["nix flake check"]
}
```

### phenix-hosts/sync.json

```json
{
  "dependsOn": ["phenix-pins", "phenix-packages", "phenix-shell", "phenix-nvim"],
  "updateInputs": ["phenix-pins", "phenix-packages", "phenix-shell", "phenix-nvim"],
  "checks": [
    "nix flake check",
    "nixos-rebuild build --flake .#laptop",
    "nixos-rebuild build --flake .#desktop"
  ]
}
```

### phenix-tools/sync.json

```json
{
  "dependsOn": ["phenix-pins"],
  "updateInputs": ["phenix-pins"],
  "checks": ["nix flake check"]
}
```

`phenix-tools` is part of the graph but also contains the sync tool that evaluates the graph. The tool must handle checking its own repo without special cases.

## Workspace root inputs
The workspace superflake references subflakes via **GitHub URLs**, not `path:./` references. This is necessary because Nix's `restrict-eval` mode in git repos cannot see files inside submodule directories.

```nix
inputs.phenix-pins.url = "github:matthis-k/phenix-pins";

inputs.phenix-packages.url = "github:matthis-k/phenix-packages";
inputs.phenix-packages.inputs.phenix-pins.follows = "phenix-pins";

inputs.phenix-shell.url = "github:matthis-k/phenix-shell";
inputs.phenix-shell.inputs.phenix-pins.follows = "phenix-pins";

inputs.phenix-nvim.url = "github:matthis-k/phenix-nvim";
inputs.phenix-nvim.inputs.phenix-pins.follows = "phenix-pins";

inputs.phenix-hosts.url = "github:matthis-k/phenix-hosts";
inputs.phenix-hosts.inputs.phenix-pins.follows = "phenix-pins";

inputs.phenix-tools.url = "github:matthis-k/phenix-tools";
inputs.phenix-tools.inputs.phenix-pins.follows = "phenix-pins";
```

Remove `inputs.phenix-sync`.

`path:./` references would be preferred once Nix supports submodule path resolution (`path:./phenix-pins`). Consider switching if/when `flake.submodules = true` is fully respected by the `path` fetcher.

## Workspace root apps

```nix
apps.${system} = {
  sync = inputs.phenix-tools.apps.${system}.sync;
  gate = inputs.phenix-tools.apps.${system}.gate;
  style = inputs.phenix-tools.apps.${system}.style;

  shell = inputs.phenix-shell.apps.${system}.default;
  nvim = inputs.phenix-nvim.apps.${system}.default;

  default = inputs.phenix-tools.apps.${system}.sync;
};
```

If only `sync` exists initially, expose only `sync` and document `gate`/`style` as TODOs.

## Verification

```bash
cd ~/phenix/phenix-tools
nix flake check
nix run .#sync -- graph
nix run .#sync -- plan --changed phenix-pins
```

From workspace root:

```bash
cd ~/phenix
nix flake check
nix run .#sync -- graph
nix run .#sync -- plan --changed phenix-pins
```

## Deliverables

1. Uniform minimal flakes for pins/packages/shell/nvim/hosts/tools.
2. Workspace superflake aggregating all subflakes.
3. `phenix-tools` exposing at least the sync app.
4. Sync graph/check/plan working before major migration.
5. Style consistency gate either implemented in `phenix-tools` now or documented as the next tool to add.
6. Existing repo-gate/handoff tooling migrated into `phenix-tools` unless there is a clear reason to split it later.