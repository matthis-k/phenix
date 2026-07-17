# Agent check flow

```text
inspect scope
  -> run narrow maintenance task
  -> implement and format
  -> run repository `devenv test`
  -> use Stitch for affected consumer/provider closure when required
  -> publish focused PR
```

Check definitions remain local and deterministic.
