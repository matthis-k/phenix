---
title: README
type: note
permalink: newxos/readme
---

# Phenix Development Docs

This document describes the intended Phenix workflow. Items not yet implemented must be tracked in `docs/roadmap.md`.

This documentation is an **ought-state** documentation set. It defines how the workspace is supposed to behave, while the roadmap tracks what is actually implemented, missing, deferred, or enforced.

## Reading order

1. `guardrails.md`
2. `architecture/flake-topology.md`
3. `opencode.md`
4. `stitch.md`
5. `tend.md`
6. `testing.md`
7. `migration.md`
8. `roadmap.md`

## Core idea

Phenix is not a monolithic dotfiles repository.

Phenix is an operating-system composition workspace made of separate repos with clear ownership:

- root orchestration
- development tools
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

## Agent workflows

Agents should use the Phenix MCP tools rather than reconstructing workflows from shell commands.

- Use `tend` for check planning and execution.
- Use `stitch` for multi-repo git status, DAGs, commits, and sync.

See:

- `docs/agents/tool-routing.md`
- `docs/workflows/agent-check-flow.md`
- `docs/workflows/agent-commit-flow.md`
- `docs/mcp/contracts.md`

## Check execution model

- `git commit` runs `tend check --profile git-hook --staged`.
- `git push` runs `tend check --profile pre-push`.
- `nix flake check` runs `tend check --profile nix-check --offline --locked`.
- Developers can run `repo-check` for the full local gate.
- Developers can run `repo-fix` for mutating fixes.
- `stitch commit` relies on Git hooks.
- `stitch commit --sync` may use a Tend preflight token to avoid duplicate hook runs.

See `docs/tend.md` for the full profile specification and validation rules.

## Foundation boundary

The foundation phase may create:

- docs
- roadmap
- repo-local OpenCode config
- dev shell basics
- minimal gate scaffold
- simple passing presence checks

The foundation phase must not migrate real `newxos` features.