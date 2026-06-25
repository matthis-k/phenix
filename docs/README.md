---
title: README
type: note
---

# Phenix Development Docs

This document describes the intended Phenix workflow. Items not yet implemented must be tracked in `docs/roadmap.md`.

This documentation is an **ought-state** documentation set. It defines how the workspace is supposed to behave, while the roadmap tracks what is actually implemented, missing, deferred, or enforced.

## Reading order

1. `guardrails.md`
2. `opencode.md`
3. `testing.md`
4. `migration.md`
5. `roadmap.md`

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

## Foundation boundary

The foundation phase may create:

- docs
- roadmap
- repo-local OpenCode config
- dev shell basics
- minimal gate scaffold
- simple passing presence checks

The foundation phase must not migrate real `newxos` features.