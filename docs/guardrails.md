# Guardrails

- No repository may depend on a retired implementation.
- No temporary workflow, diagnostic log, result link, cache, or local state belongs in Git.
- The root and tools repositories remain aggregation-only.
- Stitch remains unaware of repository-specific maintenance semantics.
- CI must be reproducible and read-only.
- Provider changes propagate through consumer locks only after provider validation.
