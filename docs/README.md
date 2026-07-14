---
title: README
type: note
permalink: phenix/readme
---

# Phenix development documentation

Phenix is a multi-repository NixOS composition workspace with explicit ownership,
locked aggregate revisions, and deterministic verification.

## Reading order

1. `guardrails.md`
2. `architecture/flake-topology.md`
3. `pi.md`
4. `stitch.md`
5. `tend.md`
6. `testing.md`
7. `migration.md`
8. the root `ROADMAP.md`

## Repository model

- The root `phenix` flake is the integration surface.
- `phenix-hosts` owns concrete machines and system policy.
- `phenix-de` owns the graphical desktop and Phenix Shell.
- `phenix-nvim` owns the Neovim wrapper.
- `phenix-agent-harness` owns Pi.
- `phenix-packages` owns shared development packages.
- `phenix-pins` owns shared upstream revisions.
- Tend owns checks; Stitch owns cross-repository coordination.

## Verification

```console
tend check --profile git-hook --context local
tend check --profile pre-push --context local
tend check --profile manual --context local
tend check --profile ci --context ci --base <base> --head <head>
```

Each feature repository must pass its own gate before the root lock is updated.
The root gate then validates the exact aggregate graph.

## Agent workflow

Use Pi through `phenix ai` or the wrapped package from `phenix-agent-harness`.
Use Tend for deterministic checks and Stitch for workspace graph and Git actions.
Agent prompts must not replace typed runtime contracts or repository verification.
