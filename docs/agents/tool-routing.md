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

In workflow runs, commit coordination belongs to `stitch commit`. Sync, update,
pull/rebase, and push coordination belong to `stitch sync` / `stitch push`.
The workflow orchestrator and agents must not invent ad hoc multi-repo Git
sequences when these Stitch routes are available.

## Workflow control plane

`.opencodestate/` is the durable workflow blackboard for full `/flow` runs. It
stores original request, plan, architecture, implementation, verification,
failure-analysis, run-ledger, decision-ledger, artifact-ledger, and
verification-ledger artifacts. Tool routing decisions should be recorded there
when they affect scope, verification, commit coordination, or failure analysis.

Workflow-depth routing is a planning/orchestration decision, not a tool bypass:
nontrivial, architectural, workflow/config, submodule, or multi-file tracked
changes still require the full planner -> architect -> implementer -> verifier
gates. Optional specialist critics may provide advisory feedback, but they do
not replace architect acceptance or verifier success.

Partitioned implementers are allowed only when the accepted plan divides work by
planned change ID, repo/submodule, allowed files, allowed operations, and
verification expectations. The final combined diff remains subject to normal
verification.

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
