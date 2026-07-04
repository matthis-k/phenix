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
stitch status              # show workspace status (--json for agent)
stitch diff                # show diffs across repos
stitch git-state           # structured workspace git state (--json for agent)
stitch classify-git-action # classify user intent against workspace state (--json for agent)
stitch check-locks         # lock/gitlink invariant check
stitch dag                 # show ordered operation DAG (--mode commit|sync|full)
stitch commit              # commit changed files in DAG dependency order (local only)
stitch commit --apply      # execute the commit
stitch push                # push committed changes in dependency order
stitch push --apply        # execute the push
stitch sync                # DAG-aware sync: update flake inputs, commit, push
stitch sync --apply        # execute the sync
stitch sync --apply --no-push  # DAG-aware sync: update inputs, commit locally, no push
stitch update-submodules   # update submodules to remote (--dry-run to preview, --apply to execute)
stitch graph derive        # derive workspace graph from flake.lock files
stitch graph verify        # validate workspace graph topology
stitch graph order         # show provider-before-consumer topological order
stitch graph print         # print workspace graph (default format: mermaid)
```

## Git semantics

stitch implements the canonical Git semantics for the Phenix workspace:

| Term | Creates commits | Pushes | Propagates downstream inputs | stitch command |
|------|:---:|:---:|:---:|------|
| `local commit` | ✅ | ❌ | ❌ | `stitch commit --apply` |
| `push` | ❌ | ✅ | ❌ | `stitch push --apply` |
| `commit and push` | ✅ | ✅ | ❌ | `stitch commit --apply` then `stitch push --apply` |
| `sync` | ✅ | ✅ | ✅ | `stitch sync --apply` |
| `sync --no-push` | ✅ | ❌ | ✅ | `stitch sync --apply --no-push` |
| `update submodules to remote` | maybe | ❌ | maybe | `stitch update-submodules --remote --apply` |

### Semantics

- **local commit** (`stitch commit`): creates commits in the current or DAG-ordered repos. Does not push. This is the default commit mode.
- **push** (`stitch push`): publishes existing local commits. Creates no new commits. Pushes in DAG dependency order.
- **commit and push**: two-step operation: `stitch commit --apply` followed by `stitch push --apply`.
- **sync** (`stitch sync`): updates downstream flake inputs/gitlinks, creates commits, and pushes in DAG dependency order. Full DAG-aware propagation.
- **sync --no-push** (`stitch sync --apply --no-push`): updates downstream flake inputs/gitlinks and creates local commits. Does not push.
- **update submodules to remote** (`stitch update-submodules --remote`): updates submodule pointers to remote HEAD. May create commits. Does not propagate downstream inputs. Not the same as sync.

### Classification

Use `stitch classify-git-action --intent <intent> --json` to resolve ambiguous user intent (e.g., "sync up submodules") against the current workspace state before mutating.

## Agent-Friendly JSON

`--json` is supported for:

- `stitch status --json`
- `stitch commit --dry-run --json`
- `stitch dag --json`
- `stitch git-state --json`
- `stitch classify-git-action --json`

## Workflow

### Local commit

```
1. stitch status                    # inspect workspace state
2. stitch diff --repo <name>        # review changes in a repo
3. stitch dag --mode commit         # plan commit order
4. stitch commit --dry-run          # preview what would be committed
5. stitch commit --apply            # execute local commits (no push)
```

### Commit and push

```
1. stitch status                    # inspect workspace state
2. stitch diff --repo <name>        # review changes in a repo
3. stitch dag --mode commit         # plan commit order
4. stitch commit --dry-run          # preview what would be committed
5. stitch commit --apply            # execute local commits
6. stitch push --dry-run            # preview push order
7. stitch push --apply              # push committed changes
```

### Sync (DAG-aware commit + push)

```
1. stitch dag --mode sync           # plan sync order
2. stitch sync --dry-run            # preview sync actions
3. stitch sync --apply              # update flake inputs, commit, push in DAG order
```

### Sync without push

```
1. stitch dag --mode sync           # plan sync order
2. stitch sync --dry-run --no-push  # preview sync actions
3. stitch sync --apply --no-push    # update flake inputs, commit locally, no push
```

### Update submodules to remote

```
1. stitch update-submodules --remote --dry-run   # preview changes
2. stitch update-submodules --remote --apply     # execute
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
- `stitch.git_state` — structured workspace git state
- `stitch.classify_git_action` — classify user intent against workspace state
- `stitch.check_locks` — lock/gitlink invariant check

Mutating (implemented):

- `stitch.commit` — DAG-wide local commit with validation (requires `apply: true`)
- `stitch.push` — push existing local commits in DAG dependency order (requires `apply: true`)
- `stitch.sync` — DAG-aware sync: update flake inputs, commit, push (requires `apply: true`)
- `stitch.update_submodules` — update submodules to remote (requires `apply: true`)

## Not Yet Implemented

- Rebase, merge, branch management
- Interactive prompts
- Auto-commit message generation
- Daemon mode
- Workspace lock (simple lock file detection exists)
