---
title: stitch
type: note
permalink: newxos/stitch
---

# stitch — Multi-Repo Git Coordination Tool

`stitch` is the standalone multi-repo Git coordination tool for Phenix-style
workspaces.  It coordinates Git state across multiple related repos using
workspace-aware operations.

## Relationship to phenix

```
tend   — low-level distributed task/check/hook harness (make the workspace correct)
stitch — multi-repo git coordinator (commit/sync workspace state)
phenix — reserved for higher-level Phenix workspace/OS commands
```

`phenix` may later delegate to `stitch`, but `stitch` must remain usable
independently.

## Why `phenix sync` was removed

The old `phenix sync` was a DAG-based nix flake update orchestration tool
that read `sync.json` files and `nodes.json` to perform coordinated flake
updates across repos.

It was removed and replaced with `stitch` because:

- The old tool conflated "update flake inputs" with "sync workspace state"
- The DAG-based model was tied to a specific nix flake update workflow
- `stitch` provides a clean model that works for any multi-repo Git operation
- The old `sync.json` / `nodes.json` config format is retired
- `stitch` uses `.stitch.json` instead

`sync.json` files in individual repos are no longer consumed by any active
tool.  `tend` covers the maintenance/check workflow that `sync.json` used to
describe.

## Concepts

### Workspace

A workspace is a directory containing multiple Git repos.  The workspace
config file `.stitch.json` lists the repos and the workspace name.

### Commit Trailers

Every commit created by `stitch` includes these trailers:

```
Workspace: <workspace-name>
Managed-By: stitch
```

## Config

`.stitch.json`:

```json
{
  "version": 1,
  "workspace": "phenix",
  "repos": [
    { "name": "phenix-tend",   "path": "flakes/02-producers/phenix-tend" },
    { "name": "phenix-stitch", "path": "flakes/02-producers/phenix-stitch" },
    { "name": "phenix",        "path": "." }
  ]
}
```

If `.stitch.json` does not exist, `stitch` falls back to discovering
immediate child directories that contain `.git`.

## CLI

```
stitch repos              # list configured repos
stitch status             # show workspace status (--json for agent)
stitch diff               # show diffs across repos
stitch dag                # show ordered operation DAG (--mode commit|sync|full)
stitch commit             # commit changed files in DAG dependency order (local only)
stitch commit --apply     # execute the commit
stitch push               # push committed changes in dependency order
stitch sync               # sync/update/push (update flake inputs, validate, push)
stitch graph derive       # derive workspace graph from flake.lock files
stitch graph verify       # validate workspace graph topology
stitch graph order        # show provider-before-consumer topological order
stitch graph print        # print workspace graph (default format: mermaid)
```

## Agent-Friendly JSON

`--json` is supported for:

- `stitch status --json`
- `stitch commit --dry-run --json`
- `stitch dag --json`

## Workflow

### Multi-repo commit

```
1. stitch status                    # inspect workspace state
2. stitch diff --repo <name>        # review changes in a repo
3. stitch dag --mode commit         # plan commit order
4. stitch commit --dry-run          # preview what would be committed
5. stitch commit --apply            # execute local commits
6. stitch push                      # push committed changes
```

### Sync/push workflow

```
1. stitch dag --mode sync           # plan sync order
2. stitch sync --dry-run            # preview sync actions
3. stitch sync --apply              # update flake inputs, validate, push
```

## Graph Subsystem

Stitch can reconstruct the workspace dependency graph by reading `flake.lock`
files.  Edge direction is **consumer -> provider** (e.g., `phenix-hosts -> phenix-pins`).

For sync execution order, providers must be processed before consumers.  Use
`stitch graph order` to get the provider-before-consumer topological order.

### Edge direction

```
consumer -> provider
```

So if `phenix-hosts` depends on `phenix-pins`, the edge is:

```
phenix-hosts -> phenix-pins
```

### Graph commands

```
stitch graph derive --source locks --workspace . --metadata stitch.workspace.json
stitch graph verify --source locks --workspace . --metadata stitch.workspace.json
stitch graph order  --source locks --workspace . --metadata stitch.workspace.json
stitch graph print  --source locks --workspace . --metadata stitch.workspace.json --format mermaid
```

### Graph source

- `locks` (default): derive edges from `flake.lock` files
- `json`: use explicit edge list from metadata file (fallback/manual mode)

### Validation rules

1. **Cycles**: forbidden between workspace nodes (cycles inside one node are allowed).
2. **Layer rule**: for edge `consumer -> provider`, `provider.layer <= consumer.layer`.
3. **Root rule**: no non-root node may depend on the workspace root.
4. **Provider/consumer rule**: providers must not depend on consumers.
5. **Duplicate edges**: warned.
6. **Missing flake.lock**: warned by default, error with `--strict`.

### Layer model

| Layer | Kind               | Example node       |
|-------|--------------------|--------------------|
| 0     | pins               | phenix-pins        |
| 1     | providers          | phenix-packages    |
| 1     | providers          | phenix-tend        |
| 1     | providers          | phenix-stitch      |
| 2     | desktop providers  | phenix-de          |
| 3     | host consumers     | phenix-hosts       |
| 4     | workspace root     | phenix             |

## Safety Rules

1. Never auto-commit without an explicit commit message.
2. Never push before all local commits succeeded.
3. Never force-push by default.
4. Never stage ignored files silently.
5. Never commit repos not listed in the workspace config.
6. Never mutate outside configured workspace repos.

## MCP Tools

Read-only (implemented):

- `stitch.status` — show multi-repo git status
- `stitch.diff` — show diffs across repos
- `stitch.dag` — show ordered operation DAG
- `stitch.commit_template` — generate commit message template (read-only)

Mutating (implemented):

- `stitch.commit` — DAG-wide commit with validation (requires `apply: true`)

Mutating (planned):

- `stitch.sync` — pull/rebase/push across repos

## Not Yet Implemented

- Rebase, merge, branch management
- Interactive prompts
- Auto-commit message generation
- Daemon mode
- Workspace lock (simple lock file detection exists)
