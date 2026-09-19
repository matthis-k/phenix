---
title: repo-roles
type: note
permalink: phenix/repo-roles
---

# Phenix repo roles

This document describes the intended Phenix workflow. Items not yet implemented must be tracked in `ROADMAP.md` (at repo root).

## Role table

| Repo | Role | Layer | Allowed inputs |
|---|---:|---:|---|
| `phenix-pins` | pins | 0 | external only |
| `phenix-ai` | AI runtime + supported product | 2 | pins, workspace providers |
| `phenix-stitch` | workspace provider | 2 | pins |
| `phenix-tools` | tools aggregation | 2 | pins, workspace providers |
| `phenix-ai.nvim` | canonical Neovim client | 3 | AI runtime |
| `phenix-nvim` | editor distribution | 4 | pins, AI runtime, Neovim client |
| `phenix-packages` | package provider | 4 | pins, lower-layer producers |
| `phenix-de` | desktop consumer | 5 | pins, packages |
| `phenix-hosts` | host consumer | 5 | pins, packages, desktop, AI runtime, editor distribution |
| `phenix` | workspace root | 6 | all internal flakes |

## Filesystem layout

The published dependency DAG is provider-first:

```
0  phenix-pins
   |
2  phenix-ai        phenix-stitch / phenix-tools
   |
3  phenix-ai.nvim
   |
4  phenix-nvim      phenix-packages
   |
5  phenix-hosts     phenix-de
   |
6  phenix
```

`phenix-ai` is the single repository authority for the runtime, providers,
default policy, routing, skills, ACP product, and internal conductor/harness
packages. `phenix-ai.nvim` owns only the canonical editor client.
`phenix-nvim` owns editor distribution/configuration and pins both to the same
runtime revision. `phenix-hosts` installs the resulting distribution and the
supported `phenix-ai` product.

The former standalone `phenix-conductor`, `phenix-harness`,
`phenix-agent-harness`, and `phenix-opencode` repositories are not valid
published dependency edges.

## Validation

Run:

```sh
stitch graph verify \
  --source locks \
  --workspace . \
  --source locks \
  --strict
```

to validate the published flake-input topology.

Rules enforced:

1. No non-root repo may depend on root.
2. No published internal edge may point to same or higher layer.
3. Producer-to-producer published flake-input edges are not allowed within the same layer; cross-tool orchestration belongs in root/workspace or higher integration layers.
4. No producer may depend on a pkgs-aggregator.
5. Root may depend on any internal repo.
6. Local path edges are allowed only in root/workspace mode.
7. Unknown internal repo inputs fail unless marked external.
