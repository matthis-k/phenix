# Flake topology

The graph is provider-first by layer:

1. `phenix-pins` owns shared external pins.
2. `phenix-ai`, `phenix-stitch`, and `phenix-tools` provide runtime/tool foundations.
3. `phenix-ai.nvim` provides the canonical Neovim client against `phenix-ai`.
4. `phenix-nvim` packages the editor distribution and forces its client to follow the same `phenix-ai` revision; `phenix-packages` provides the general package set.
5. `phenix-hosts` and `phenix-de` compose concrete systems.
6. `phenix` aggregates the merged provider-first graph.

The critical AI chain is:

```text
phenix-ai
  -> phenix-ai.nvim
  -> phenix-nvim
  -> phenix-hosts
  -> phenix
```

Consumers follow provider inputs so each layer selects one compatible `phenix-ai`
revision rather than independently locking runtime copies. `sync.json` metadata
carries updates provider-first, and every repository retains its own valid flake and
maintenance gate. Standalone `phenix-conductor` and `phenix-harness` repository
inputs are retired; those package surfaces are supplied by `phenix-ai`.
