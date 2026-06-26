---
title: agent-commit-flow
type: note
permalink: newxos/agent-commit-flow
---

# Agent Commit Flow

The canonical agent workflow for multi-repo commits:

## Phase 1: Inspect

```text
stitch status
stitch diff --repo <name>
stitch dag --mode commit
```

Understand what is dirty and how repos depend on each other.

## Phase 2: Template

Generate commit message templates for dirty repos:

```text
stitch commit --write-template
```

This outputs a JSON structure keyed by repo name with `subject`, `body`, and `files` fields.

## Phase 3: Commit

Commit with explicit messages:

```text
stitch commit --message "feat: add X" --repo <name>
# or via JSON messages file:
stitch commit --messages <file>.json --apply
```

- `--dry-run` — preview without mutating
- `--apply` — execute (required for safety)
- `--no-push` — commit locally without pushing
- `--staged` — use only staged files

## Phase 4: Push

```text
stitch push
```

Push committed changes in dependency order.

## Safety Rules

1. Never auto-commit without an explicit commit message.
2. Never push before all local commits succeeded.
3. Never force-push by default.
4. Never stage ignored files silently.
5. Never mutate outside the configured workspace repos.

## MCP Workflow

For AI agents using MCP:

1. `stitch.status` — inspect workspace
2. `stitch.diff` — review changes
3. `stitch.dag` — plan commit order
4. `stitch.commit_template` — generate message template
5. `stitch.commit` with `apply: true` — execute

## Deprecated

Do NOT use:

- `stitch changeset` subcommands — replaced by `stitch commit` / `stitch push`
- Raw `git commit` in multiple repos — use `stitch commit` for coordinated commits
- `sync.json` — retired
