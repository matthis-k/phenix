---
title: generated-flake-workflow
type: note
permalink: newxos/generated-flake-workflow
---

# Generated flake workflow

This migration is partitioned.  The current implemented subset only enables the
shared prerequisites for later per-repository flake generation.

## Pin authority

`phenix-pins` is the only Phenix flake that may pin `flake-file` and
`import-tree` directly.  Other active flakes must consume those inputs through
`phenix-pins` when their deferred migration partition is implemented.

## Tend generated-flake commands

Tend owns explicit generated-flake maintenance through `tend flake`:

- `tend flake status` reports `flake.nix`, `flake.lock`, `flake.nix.in`, and
  whether the generated file is up to date.
- `tend flake check` requires a repo-owned `flake.nix.in` source and verifies
  that `flake.nix` matches it.
- `tend flake write` copies `flake.nix.in` to `flake.nix`.

If `flake.nix.in` is missing, Tend fails clearly instead of writing a placeholder
flake.  Repositories that adopt generated flakes should expose this maintenance
through visible Tend `generate` tasks and explicit `requires` edges; hidden
before-hooks are not the primary workflow.

## Deferred partitions

The remaining active-flake migrations are intentionally deferred from this
subset: `phenix-nvim`, `phenix-agent-harness`, `phenix-packages`, `phenix-de`,
`phenix-hosts`, and root generated-flake migration.  Those partitions must keep
root as an aggregator, avoid same-layer/upward dependencies, preserve public
outputs, and use affected-DAG verification.
