# Stitch

Stitch derives and validates the workspace graph, selects dependency closures, computes deterministic order, reports repository status, and executes a caller-provided command in each selected repository.

Canonical graph edges point from consumer to provider. `providers-first` reverses those edges for execution.

Stitch does not commit, push, install hooks, define checks, or interpret maintenance profiles.
