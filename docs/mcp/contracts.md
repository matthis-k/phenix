---
title: mcp-contracts
type: note
permalink: newxos/mcp-contracts
---

# MCP Contracts

This document defines the MCP tool contracts for `tend-mcp` and `stitch-mcp`.

## Shared Conventions

### Mutation Levels

| Level | Description | Requires `apply: true` |
|-------|-------------|----------------------|
| `ReadOnly` | No side effects | No |
| `WritesWorktree` | May modify files in the worktree but does not create commits | Yes |
| `CreatesCommit` | Creates Git commits | Yes |
| `Network` | Network access (pull/push) | Yes |

`tend.run` never creates commits. Commit creation is owned by `stitch.commit`.

### Error Handling

All tools return `ToolResult` on success or `ToolFailure` on error.

Common error kinds:
- `NotFound` — config, repo, or check not found
- `Conflict` — workspace state conflicts (dirty repos, blocked DAG)
- `PolicyDenied` — missing `apply: true` or safety violation
- `Internal` — unexpected errors

### Audit

Every tool call is logged to `~/.local/share/phenix/audit/<server-name>/`.

## tend-mcp

| Tool | Description | Mutation | Status |
|------|-------------|----------|--------|
| `tend.status` | Show config health and known checks | ReadOnly | Implemented |
| `tend.plan` | Show which checks would run and why | ReadOnly | Implemented |
| `tend.run` | Execute tasks/checks | Phase-dependent: `verify` = ReadOnly; `fix`/`generate`/`setup`/`cleanup` = WritesWorktree; never creates commits | Implemented |
| `tend.explain` | Explain a check failure with repro command | ReadOnly | Implemented |

### Tend Schema

Tend uses `.tend.json` files for configuration. See `docs/tend.md` for the full schema.

## stitch-mcp

| Tool | Description | Mutation | Status |
|------|-------------|----------|--------|
| `stitch.status` | Show multi-repo git status | ReadOnly | Implemented |
| `stitch.diff` | Show diffs across repos | ReadOnly | Implemented |
| `stitch.dag` | Show ordered operation DAG | ReadOnly | Implemented |
| `stitch.commit_template` | Generate commit message template | ReadOnly | Implemented |
| `stitch.commit` | Local exact-file commits across configured repos | CreatesCommit | Implemented |
| `stitch.sync` | Pull/rebase/push across repos | Network | Planned |

`stitch.commit` does not update flake inputs and does not push. Sync/update/push behavior is owned by `stitch.sync` and `stitch.push`.

### Stitch Schema

Stitch derives workspace DAGs from root flake inputs/locks and optional XDG local workspace mappings. See `docs/stitch.md` for the current workspace model.

## Deprecated Endpoints

The following tools are removed or replaced:

| Old name | Replacement | Reason |
|----------|-------------|--------|
| `stitch.commit_sync` | `stitch.commit` | Duplicate alias |
| `stitch_status` (underscore) | `stitch.status` (dotted) | Underscore naming was a placeholder |
| `pt` / `phenix-tools` | `tend` / `stitch` | Split into separate tools |
