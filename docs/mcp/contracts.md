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
| `CreatesCommit` | Creates Git commits | Yes |
| `Network` | Network access (pull/push) | Yes |

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
| `tend.status` | Show config health and known checks | ReadOnly | Planned |
| `tend.plan` | Show which checks would run and why | ReadOnly | Planned |
| `tend.run` | Execute checks | CreatesCommit | Planned |
| `tend.explain` | Explain a check failure with repro command | ReadOnly | Planned |

### Tend Schema

Tend uses `.tend.json` files for configuration. See `docs/tend.md` for the full schema.

## stitch-mcp

| Tool | Description | Mutation | Status |
|------|-------------|----------|--------|
| `stitch.status` | Show multi-repo git status | ReadOnly | Implemented |
| `stitch.diff` | Show diffs across repos | ReadOnly | Implemented |
| `stitch.dag` | Show ordered operation DAG | ReadOnly | Implemented |
| `stitch.commit_template` | Generate commit message template | ReadOnly | Implemented |
| `stitch.commit` | DAG-wide commit with validation | CreatesCommit | Implemented |
| `stitch.sync` | Pull/rebase/push across repos | Network | Planned |

### Stitch Schema

Stitch uses `.stitch.json` files for workspace configuration. See `docs/stitch.md` for the full schema.

## Deprecated Endpoints

The following tools are removed or replaced:

| Old name | Replacement | Reason |
|----------|-------------|--------|
| `stitch.commit_sync` | `stitch.commit` | Duplicate alias |
| `stitch_status` (underscore) | `stitch.status` (dotted) | Underscore naming was a placeholder |
| `pt` / `phenix-tools` | `tend` / `stitch` | Split into separate tools |
