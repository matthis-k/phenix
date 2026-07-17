# Repository goals

- Each repository owns its implementation and local verification contract.
- Maintenance commands declare their runtime dependencies beside their implementation.
- The project flake remains independent from standalone devenv.
- Stitch coordinates repositories but does not know how a repository is maintained.
- Aggregator repositories contain no duplicate implementation.
- Git history preserves removed designs; active trees contain only the current design.
