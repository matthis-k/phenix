# Flake topology

The graph is provider-first by layer:

1. `phenix-pins`
2. `phenix-stitch`, `phenix-tools`, and `phenix-ai`
3. `phenix-ai.nvim`
4. `phenix-nvim` and package aggregation
5. desktop and host consumers
6. root aggregation

The AI path is intentionally linear:

```text
phenix-ai
  -> phenix-ai.nvim
      -> phenix-nvim
          -> phenix-hosts
              -> phenix
```

Higher layers follow the lower layer's selected inputs so a host or root lock graph
uses one `phenix-ai` revision across the runtime, canonical Neovim client, editor
distribution, and installed `phenix` package. Repositories retain independently
valid flakes and maintenance gates, while `sync.json`/Stitch metadata supplies the
provider-first update order.
