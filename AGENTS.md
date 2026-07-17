# Agent guidance

1. Read the owning repository's guidance, `maintenance.nix`, and `.stitch.json` before changing code.
2. Keep repository-specific verification local to `maintenance.nix`.
3. Use `devenv test` for the complete read-only repository gate.
4. Use Stitch only for workspace discovery, closure selection, ordering, and generic command execution.
5. Update providers before consumers and regenerate consumer lock files after provider merges.
6. Do not commit logs, result links, caches, local devenv state, temporary workflows, or generated diagnostics.
7. The root repository must remain aggregation-only.
