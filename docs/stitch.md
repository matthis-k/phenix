---
title: stitch
type: note
permalink: newxos/stitch
---

# stitch — Multi-Repo Git Changeset Coordinator

`stitch` is the standalone multi-repo Git coordination tool for Phenix-style
workspaces.  It coordinates Git state across multiple related repos using
explicit workspace changesets.

## Relationship to phenix

```
tend   — low-level distributed task/check/hook harness (make the workspace correct)
stitch — multi-repo changeset coordinator (commit/sync workspace changesets)
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
- `stitch` provides a clean changeset model that works for any multi-repo
  Git operation, not just flake updates
- The old `sync.json` / `nodes.json` config format is retired
- `stitch` uses `.stitch.json` and `.stitch/changesets/` instead

The old `sync.json` files in individual repos are preserved for reference
but are no longer consumed by any active tool.  `tend` covers the
maintenance/check workflow that `sync.json` used to describe.

## Concepts

### Workspace

A workspace is a directory containing multiple Git repos.  The workspace
config file `.stitch.json` lists the repos and the workspace name.

### Changeset

A changeset represents one logical feature or change spanning one or more
repos.  Changeset states:

| State              | Meaning                              |
|--------------------|--------------------------------------|
| planned            | Created, not yet validated           |
| validated          | Validation passed                    |
| committed-partial  | Some repos committed, some failed    |
| committed          | All repos committed successfully     |
| pushed-partial     | Some pushes succeeded                |
| pushed             | All pushes succeeded                 |
| aborted            | Cancelled                            |

### Commit Trailers

Every commit created by `stitch` includes these trailers:

```
Change-Set: <changeset-id>
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
stitch status --json

stitch changeset new "<title>"        # create a changeset
stitch changeset status               # show active changeset
stitch changeset plan                 # build plan from dirty repos
stitch changeset plan --write         # save the plan
stitch changeset plan --json          # plan as JSON
stitch changeset set-message <repo> "<msg>"
stitch changeset set-files <repo> <file>...
stitch changeset validate             # validate the changeset
stitch changeset validate --json
stitch changeset commit               # commit across all repos
stitch changeset push                 # push committed changes
stitch changeset abort                # cancel active changeset
```

Convenience aliases:

```
stitch plan    = stitch changeset plan
stitch commit  = stitch changeset commit
stitch push    = stitch changeset push
stitch sync    = synchronize already-committed state only
```

## Agent-Friendly JSON

`--json` is supported for:

- `stitch status --json`
- `stitch changeset plan --json`
- `stitch changeset validate --json`
- `stitch changeset status` (always JSON)

## Workflow

```text
1. stitch changeset new "Add feature X"
2. stitch changeset plan --write
3. stitch changeset set-message <repo> "feat: add X"
4. stitch changeset validate
5. stitch changeset commit
6. stitch changeset push
```

## Safety Rules

1. Never auto-commit without an explicit commit message.
2. Never push before all local commits in the changeset succeeded.
3. Never force-push by default.
4. Never stage ignored files silently.
5. Never stage untracked files unless explicitly listed in the plan.
6. Never commit repos not listed in the active changeset.
7. Never commit files not listed in the repo plan.
8. Never create a coordinated commit without Change-Set/Workspace/Managed-By trailers.
9. Never mutate `newxos`.

## Future Direction

### MCP Tools (planned)

Read-only:
- `stitch_status`
- `stitch_list_repos`
- `stitch_current_changeset`

Planning:
- `stitch_create_changeset`
- `stitch_propose_plan`
- `stitch_set_repo_message`
- `stitch_validate_changeset`

Mutating:
- `stitch_commit_changeset`
- `stitch_push_changeset`
- `stitch_sync_changeset`
- `stitch_abort_changeset`

The MCP server will call the same core logic as the CLI.

### Not Yet Implemented

- Force-push, rebase, merge, branch management
- Interactive prompts
- Auto-commit message generation
- Daemon mode
- Workspace lock (simple lock file detection exists)
