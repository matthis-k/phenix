---
title: testing
type: note
permalink: newxos/testing
---

# Phenix Testing and Gates

This document describes the intended Phenix workflow.

It is an **ought-state** document. Items not yet implemented must be tracked in [`roadmap.md`](./roadmap.md).

## Purpose

Phenix should not rely on AI review for correctness.

Anything repeatedly checked by an agent should become a deterministic gate.

The gate runner should answer:

- what changed?
- which checks are affected?
- which checks failed?
- which checks passed?
- which checks are missing?

## Scope boundary

The gate runner exists to constrain agents, not to be a testing framework.

**Keep it small.** Do not add:

- output verification plugins (stdoutContains, stderrContains)
- multi-step workflow DSL (steps)
- AI-based check routing
- expected-failing checks
- migration-specific checks before migration starts

Future checks belong in `roadmap.md`, not in the default gate set.

## Main command

Actual implementation:

```sh
phenix-tools gate
```

(Short alias `pt gate` is also available from the phenix-tools build.)

Expected subcommands:

```sh
phenix-tools gate list
phenix-tools gate all
phenix-tools gate changed
phenix-tools gate id <id>
phenix-tools gate group <group>
phenix-tools gate tag <tag>
phenix-tools gate explain <id>
<general>
nix run .#gate -- list
nix run .#gate -- all
nix run .#gate -- changed
nix run .#gate -- id <id>
```

The first implementation supports:

```sh
phenix-tools gate list
phenix-tools gate all
phenix-tools gate changed
phenix-tools gate id <id>
```

These can be run from the workspace root via:

```sh
nix run .#gate -- list
nix run .#gate -- all
nix run .#gate -- changed
nix run .#gate -- id <id>
```

Current implementation: these subcommands are available via `phenix-tools gate`.

## Distributed check files

Canonical file name:

```text
.phenix-checks.json
```

The runner should discover these files recursively from the workspace root.

Explicit config files should be passable with:

```sh
phenix-tools gate --config path/to/.phenix-checks.json list
phenix-tools gate -c path/to/.phenix-checks.json all
nix run .#gate -- --config .phenix-checks.json list
```

## Deterministic merge

When multiple check files are discovered, they should be merged deterministically.

Expected rules:

1. Sort config files by path.
2. Load checks in sorted file order.
3. Check IDs must be unique after merge.
4. Duplicate IDs are an error.
5. Failed config parsing is an error.
6. Invalid schema is an error.

## Minimal schema

```json
{
  "$schema": "https://phenix.local/schemas/phenix-checks.schema.json",
  "version": 1,
  "scope": {
    "root": "config",
    "workdir": "config"
  },
  "checks": [
    {
      "id": "nix-format",
      "description": "Check Nix formatting",
      "group": "nix",
      "tags": ["format", "nix"],
      "when": {
        "paths": ["**/*.nix"]
      },
      "workdir": "config",
      "command": ["nixfmt", "--check", "."],
      "expect": {
        "status": 0
      }
    }
  ]
}
```

## Required check fields

Each check should support:

```json
{
  "id": "string",
  "description": "string",
  "group": "string",
  "tags": ["string"],
  "when": {
    "paths": ["glob"]
  },
  "workdir": "config | repo | cwd",
  "command": ["program", "arg1", "arg2"],
  "expect": {
    "status": 0
  }
}
```

## Optional future fields

These are desired, but not required for the first implementation:

```json
{
  "expect": {
    "stdoutContains": ["text"],
    "stderrContains": ["text"],
    "stdoutNotContains": ["text"],
    "stderrNotContains": ["text"]
  }
}
```

```json
{
  "steps": [
    {
      "command": ["program", "arg"],
      "expect": {
        "status": 0
      }
    }
  ]
}
```

## Changed-file detection

`phenix gate changed` should use Git.

Baseline behavior:

```sh
git diff --name-only
git diff --cached --name-only
```

Optional behavior:

```sh
git diff --name-only HEAD
```

The exact behavior must be documented in the command help.

Changed-file routing must be deterministic.

Do not use AI to decide which checks to run.

## Output style

The gate runner should mostly print failures and summarize passes.

Expected output shape:

```text
FAILED nix-format
  config: ./.phenix-checks.json
  workdir: .
  command: nixfmt --check .
  status: 1

Summary:
  failed: 1
  passed: 4
  skipped: 2
```

For success:

```text
Summary:
  failed: 0
  passed: 5
  skipped: 2
```

## Gate design principles

* Narrow checks before broad checks.
* Static checks before expensive builds.
* Changed-file routing before full-repo checks.
* Behavior checks over implementation trivia.

## Initial useful checks

The first gate set should cover:

* Nix formatting
* Nix static analysis
* flake checks
* OpenCode config presence
* docs presence
* gate runner self-test

Do not add migration-specific checks before migration starts.