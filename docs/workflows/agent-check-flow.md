---
title: agent-check-flow
type: note
permalink: newxos/agent-check-flow
---

# Agent Check Flow

The canonical agent workflow for running checks:

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
# MCP only (planned):
# tend.explain --check-id <id>

# CLI fallback:
tend status --json   # show check results
tend run --mode full --phase verify  # re-run with full output
```

## Safety Rules

1. Always `tend plan` before `tend run` to preview the scope.
2. Use `--mode changed` for local development, `--mode full` for CI.
3. `verify` phase refuses mutating tasks by default.
4. `fix` / `generate` phases require explicit selection.
5. Do not skip `verify` before committing.

## Deprecated Workflow

The old workflow used:

```text
tend verify changed    # was: tend gate / pt gate changed
```

This still works as a convenience alias but `plan → run → explain` is the preferred agent workflow because it gives better visibility into what will run and why.
