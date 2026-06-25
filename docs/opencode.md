---
title: opencode
type: note
permalink: newxos/opencode
---

# Phenix OpenCode Workflow

This document describes the intended Phenix workflow. Items not yet implemented must be tracked in `docs/roadmap.md`.

## Purpose

OpenCode should not be used as an unconstrained repo-editing agent.

For Phenix, OpenCode should behave like a structured implementation coordinator:

```text
intake
  -> discovery
  -> ownership decision
  -> change contract
  -> implementation
  -> gate execution
  -> invariant review
  -> simplification review
  -> final report
```

## Preferred setup

Default to repo-local OpenCode configuration:

```text
.opencode/
  agents/
    phenix-coordinator.md
    phenix-explorer.md
    phenix-architect.md
    phenix-toolsmith.md
    phenix-gatekeeper.md
    phenix-reviewer.md
    phenix-simplifier.md
  commands/
    phenix-foundation.md
    phenix-task.md
  skills/
    phenix-architecture/
      SKILL.md
    phenix-tooling/
      SKILL.md
```

This keeps Phenix-specific behavior versioned with the workspace.

## Default OpenCode vs Phenix OpenCode

The default `opencode` wrapper should remain general-purpose.

Phenix-specific behavior should come from repo-local `.opencode/` by default.

Do not create a Nix-generated Phenix OpenCode config unless all of the following are true:

1. the existing Nix code already has a simple wrapper pattern,
2. the wrapper does not duplicate repo-local `.opencode` definitions,
3. the wrapper does not delay the foundation work.

Do not write Phenix agents into global user config.

Do not mutate `~/.config/opencode` from Nix.

## Commands

### `/phenix-foundation`

Used for foundation work only:

* guardrails
* OpenCode config
* dev shells
* test runner scaffold
* gate infrastructure
* docs
* roadmap

It must not migrate real `newxos` features.

### `/phenix-task`

General future entrypoint for Phenix work.

It must still follow the strict workflow:

1. intake
2. discovery
3. ownership decision
4. change contract
5. implementation
6. gate execution
7. invariant review
8. simplification review
9. final report

## Agents

### `phenix-coordinator`

Primary agent.

Coordinates work and enforces the phase protocol.

Must not rush directly into edits.

### `phenix-explorer`

Read-only subagent.

Finds files, patterns, checks, docs, and relevant ownership.

No edits.

### `phenix-architect`

Read-only subagent.

Decides repo boundaries and architectural invariants.

No edits.

### `phenix-toolsmith`

Implementation subagent for tooling and dev environment only.

May work on:

* dev shells
* wrapper scaffolds for tools only
* CLI skeletons
* gate runner
* JSON schema
* docs

Must not migrate real system features.

### `phenix-gatekeeper`

Check/test subagent.

Runs checks, diagnoses failures, and proposes regression guards.

Must never claim a check passed unless it actually ran.

### `phenix-reviewer`

Read-only consistency reviewer.

Checks changed files against Phenix architecture.

### `phenix-simplifier`

Read-only YAGNI/debt reviewer.

Looks for:

* copied `newxos` debt
* broad abstractions
* compatibility layers
* stale docs
* duplicated logic
* unnecessary options

## Agent permissions

Preferred default posture:

| Agent                | Read | Edit |          Bash | Task/Subagent |
| -------------------- | ---: | ---: | ------------: | ------------: |
| `phenix-coordinator` |  yes |  ask |           ask |           yes |
| `phenix-explorer`    |  yes |   no | ask/read-only |            no |
| `phenix-architect`   |  yes |   no |            no |            no |
| `phenix-toolsmith`   |  yes |  ask |           ask |            no |
| `phenix-gatekeeper`  |  yes |  ask |           ask |            no |
| `phenix-reviewer`    |  yes |   no | ask/read-only |            no |
| `phenix-simplifier`  |  yes |   no | ask/read-only |            no |

## Final report format

Every OpenCode task should end with:

```md
## Summary

## Files changed

## Checks run

## Checks not run

## Invariant review

## Roadmap updates

## Remaining gaps
```