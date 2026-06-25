---
title: README
type: note
permalink: newxos/readme
---

# Phenix Development Docs

This documentation describes the intended Phenix development workflow.

It is an **ought-state** documentation set. That means it defines how the workspace is supposed to behave, even while some pieces are still being implemented.

Implementation gaps must be tracked in [`roadmap.md`](./roadmap.md).

## Reading order

1. [`guardrails.md`](./guardrails.md)
2. [`opencode.md`](./opencode.md)
3. [`testing.md`](./testing.md)
4. [`migration.md`](./migration.md)
5. [`roadmap.md`](./roadmap.md)

## Core idea

Phenix is not a monolithic dotfiles repository.

Phenix is an operating-system composition workspace made of separate repos with clear ownership:

- root orchestration
- tools
- packages and wrappers
- reusable modules
- host configs
- shell/UI
- pins/input policy
- tests and gates

The structure is part of the product.

## Development order

The project intentionally proceeds in this order:

1. Guardrails and OpenCode workflow
2. Testing and gate tooling
3. Migration from `newxos`

Do not migrate features before the guardrails and test runner exist.

## Task scope boundary

Every task should have a clear stop condition.

**Required** for any task:
- ought-state docs exist and are consistent
- roadmap exists and was updated
- guardrails are respected

**Allowed only if small** relative to the task:
- new OpenCode agents, commands, or skills
- minimal gate runner improvements
- new `.phenix-checks.json` checks

**Forbidden unless explicitly requested**:
- real `newxos` feature migration
- editing files inside `~/phenix/newxos`
- implementing browser/shell/Hyprland/VPN/theming/host features
- broad generic frameworks or libraries
- global OpenCode config mutation (writes to `~/.config/opencode`)
- large testing DSLs or plugin systems
- compatibility layers for `newxos` patterns