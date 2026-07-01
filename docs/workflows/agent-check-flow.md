---
title: agent-check-flow
type: note
permalink: newxos/agent-check-flow
---

# Agent Check Flow

The canonical agent workflow for running checks:

Checks are selected from the active WorkScope. `c1`/`c2` work uses minimal
preflight and lightweight local evidence unless escalation or handoff needs more.
`c3` uses planned verification. `c4` requires strict evidence, including
WorkScope conformance, plan conformance, architecture checks when routed, and
tend/stitch scope appropriate to the DAG.

## Phase 1: Plan

Before making changes, understand what checks apply:

```text
tend plan
# or
tend plan --mode full
```

This shows which tasks would run, grouped by phase and mode. No mutations occur.

## Phase 2: Run

Execute checks:

```text
tend run --mode changed --phase verify
```

- `--mode changed` — only tasks affected by current changes
- `--mode full` — all tasks (useful for CI)
- `--phase verify` — non-mutating checks only

For mutating actions:

```text
tend run --mode changed --phase fix
tend run --mode changed --phase generate
```

## Phase 3: Explain

If a check fails, understand why:

```text
tend explain            # run checks and explain failures
tend run --mode full --phase verify  # re-run with full output
```

## Safety Rules

1. Always `tend plan` before `tend run` to preview the scope.
2. Use `--mode changed` for local c1/c2/c3 development, `--mode full` for CI or
   c4/full confidence.
3. `verify` phase refuses mutating tasks by default.
4. `fix` / `generate` phases require explicit selection.
5. Do not skip `verify` before committing.
6. Fail checks on WorkScope invariant violations: unrelated changes, permission
   weakening, secret/auth drift, undeclared public API or flake output changes.
