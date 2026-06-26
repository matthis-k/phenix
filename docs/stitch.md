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
    { "name": "phenix-tools", "path": "phenix-tools" },
    { "name": "phenixos",     "path": "phenixos" }
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
stitch commit             # DAG-wide commit with validation
stitch commit --dry-run   # preview without mutating
stitch commit --apply     # execute the commit plan
stitch push               # push committed changes in dependency order
stitch sync               # pull/rebase/push across repos
```

## Agent-Friendly JSON

`--json` is supported for:

- `stitch status --json`
- `stitch commit --dry-run --json`
- `stitch dag --json`

## Workflow

### Multi-repo commit

```
1. stitch status          # inspect workspace state
2. stitch diff --repo X   # review changes in a repo
3. stitch dag --mode commit  # plan commit order
4. stitch commit --write-template  # generate message template
5. stitch commit --apply          # execute the commit
6. stitch push                     # push committed changes
```

### Sync/pull workflow

```
1. stitch dag --mode sync   # plan sync order
2. stitch sync              # pull/rebase/push
```

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
