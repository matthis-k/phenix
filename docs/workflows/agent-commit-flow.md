---
title: agent-commit-flow
type: note
permalink: newxos/agent-commit-flow
---

# Agent Commit Flow

The canonical agent workflow for multi-repo commits:

Commit, push, sync, publish, deploy, tracked deletion, secrets/auth mutation, and
permission-policy weakening are never inferred from dirty state. They require an
explicit user request and an active WorkScope that allows the capability. DAG-aware
sync/commit is `c4` release/control-plane work and must pass strict verifier
evidence before execution.

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
# MCP (recommended for agents):
stitch.commit_template

# CLI equivalent:
stitch dag --mode commit --json
```

Edit the messages and commit with them.

## Phase 3: Commit

Commit in DAG dependency order (local commits only):

```text
stitch commit --dry-run     # preview without mutating
stitch commit --apply       # execute (required for safety)
```

For per-repo messages, use `--messages`:

```text
stitch commit --messages .stitch/messages.json --apply
```

## Phase 4: Push

```text
stitch push
```

Push committed changes in dependency order.

## Phase 5: Sync

Update flake inputs and push (if needed after dependency changes):

```text
stitch sync --dry-run       # preview sync actions
stitch sync --apply         # update inputs, validate, push
```

## Safety Rules

1. Never auto-commit without an explicit commit message.
2. Never commit, push, publish, deploy, or sync unless WorkScope capability and
   explicit user approval are present.
3. Never push before all local commits succeeded.
4. Never force-push by default.
5. Never stage ignored files silently.
6. Never mutate outside the configured workspace repos.
7. Never include unrelated dirty files unless the external-change gate documents
   user acknowledgement, classification, secret review, verifier evidence, and
   commit-summary inclusion.

## MCP Workflow

For AI agents using MCP:

1. `stitch.status` — inspect workspace
2. `stitch.diff` — review changes
3. `stitch.dag` — plan commit order
4. `stitch.commit_template` — generate message template
5. `stitch.commit` with `apply: true` — execute
6. `stitch.sync` — post-commit sync/push (planned)

## Deprecated

Do NOT use:

- `stitch changeset` subcommands — replaced by `stitch commit` / `stitch push` / `stitch sync`
- Raw `git commit` in multiple repos — use `stitch commit` for coordinated commits
- `sync.json` — retired; use `.tend.json` for checks
