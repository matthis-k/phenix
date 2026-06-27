---
title: repo-roles
type: note
permalink: newxos/repo-roles
---

# Phenix repo roles

This document describes the intended Phenix workflow. Items not yet implemented must be tracked in `docs/roadmap.md`.

## Role table

| Repo | Role | Layer | Allowed inputs |
|---|---:|---:|---|
| `phenix-pins` | pins | 0 | external only |
| `phenix-tools` | producer | 2 | pins, lib, protocols, pkgs-base |
| `phenix-nvim` | producer | 2 | pins, lib, protocols, pkgs-base |
| `phenix-opencode` | integration | 3 | pins, producers |
| `phenix-packages` | pkgs-aggregator | 4 | pins, pkgs-base, producers, integrations |
| `phenix-de` | consumer | 5 | pins, pkgs, integrations, selected producers |
| `phenix-hosts` | consumer | 5 | pins, pkgs, de, home, secrets |
| `phenix` | root | 6 | all internal flakes |

## Filesystem layout

The root repo mirrors the dependency DAG via layer-numbered directories:

```
flakes/
  00-pins/           layer 0 — external pin authority
    phenix-pins/
  01-foundation/     layer 1 — lib, protocols, pkgs-base (future)
  02-producers/      layer 2 — package producers
    phenix-tools/
    phenix-nvim/
  03-integrations/   layer 3 — cross-producer wiring (future)
    phenix-opencode/
  04-pkgs/           layer 4 — aggregated package set
    phenix-packages/
  05-consumers/      layer 5 — config and composition flakes
    phenix-de/
    phenix-hosts/
```

A flake may depend on flakes in lower-numbered directories. It must not depend on flakes in same-numbered or higher-numbered directories.

`phenix-opencode` lives in layer 3 because its wrapped Opencode configuration
integrates with `phenix-tools`. `phenix-de` remains a layer-5 consumer; any
package or overlay outputs there are consumer-local desktop-environment
composition, not a reusable lower-layer provider API. The current root workspace
is `phenix`; the former shell role has been absorbed into `phenix-de`.

## Validation

Run:

```sh
stitch graph verify \
  --source locks \
  --workspace . \
  --metadata .stitch/topology.json \
  --strict
```

to validate the published flake-input topology.

Rules enforced:

1. No non-root repo may depend on root.
2. No published internal edge may point to same or higher layer.
3. No producer may depend on another producer.
4. No producer may depend on a pkgs-aggregator.
5. Root may depend on any internal repo.
6. Local path edges are allowed only in root/workspace mode.
7. Unknown internal repo inputs fail unless marked external.
