---
title: tool-routing
type: note
permalink: newxos/tool-routing
---

# Agent Tool Routing

Agents (both human and AI) should use these tools according to capability domain.

## Check/Lint/Maintenance — `tend`

`tend` owns all tree-composable task/check/hook operations.

| Agent action | Tool to use |
|---|---|
| Preview which checks will run | `tend plan` (CLI) or `tend.plan` (MCP) |
| Execute checks | `tend run` (CLI) or `tend.run` (MCP) |
| Understand a failure | `tend explain` (MCP) |
| List all known tasks | `tend list` |
| View task tree | `tend tree` |
| View config health | `tend status` |

Do NOT use raw `bash`, `git`, or standalone lint scripts. Route through `tend`.

## Multi-Repo Git — `stitch`

`stitch` owns all multi-repo Git coordination.

| Agent action | Tool to use |
|---|---|
| View workspace status | `stitch status` (CLI) or `stitch.status` (MCP) |
| View diffs | `stitch diff` (CLI) or `stitch.diff` (MCP) |
| View commit DAG | `stitch dag` (CLI) or `stitch.dag` (MCP) |
| Generate commit template | `stitch commit --write-template` (CLI) or `stitch.commit_template` (MCP) |
| Commit dirty repos | `stitch commit` (CLI) or `stitch.commit` (MCP) |
| Push committed changes | `stitch push` (CLI) |
| Pull/rebase/sync | `stitch sync` (CLI) or `stitch.sync` (MCP) |

Do NOT use raw `git commit` / `git push` across repos. Route through `stitch`.

## Shared Shell — `phenix-mcp-core`

The MCP servers (`tend-mcp`, `stitch-mcp`) share a framework crate that provides:

- Audit logging
- Root validation
- Command runner
- Safety policy

Do NOT route around the MCP safety layer. All mutations require explicit `apply: true` or confirmation.

## Deprecated / Do Not Use

- `pt` / `phenix-tools` binary — removed; use `tend` and `stitch`
- `phenix sync` — replaced by `stitch commit` / `stitch sync`
- `sync.json` — retired; use `.tend.json` for checks
- `.phenix-checks.json` — migrated to `.tend.json`
- `gate` as a separate concept — gate is now `tend verify changed` / `tend explain`
- `stitch changeset` — replaced by `stitch commit` / `stitch push` / `stitch sync`
