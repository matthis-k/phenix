# Phenix glossary

- **Commit**: A Git commit in one repository.
- **Local synced commit**: A local commit made in dependency order with related
  workspace commits, before those commits are pushed.
- **Synced commit**: A coordinated set of commits whose provider/consumer pins
  and gitlinks have been updated consistently across the workspace.
- **Sync push**: Pushing a synced commit set in dependency order so providers are
  available before consumers that reference them.
- **Affected DAG**: The selected nodes plus dependency-graph neighbors that must
  be checked because a change can affect them.
- **Provider**: A lower-layer repo that exports pins, packages, tools, or shared
  contracts consumed by other repos.
- **Consumer**: A higher-layer repo that depends on providers to compose runtime,
  desktop, host, or workspace behavior.
- **Root workspace**: The top-level `phenix` repo that aggregates active
  subflakes and coordinates verification; it is not a child dependency provider.
- **Retired repo**: A former repo or role kept only for historical notes and not
  included in active topology, root inputs, hooks, or normal verification.
