---
title: testing
type: note
permalink: newxos/testing
---

# Phenix Testing and Gates

This document describes the intended Phenix workflow. Items not yet implemented must be tracked in `docs/roadmap.md`.

## Purpose

Phenix should not rely on AI review for correctness.

Anything repeatedly checked by an agent should become a deterministic gate.

The gate runner should answer:

- what changed?
- which checks are affected?
- which checks failed?
- which checks passed?
- which checks are missing?

## Main command

Preferred command:

```sh
phenix gate
```

Expected eventual subcommands:

```sh
phenix gate list
phenix gate all
phenix gate changed
phenix gate id <id>
phenix gate group <group>
phenix gate tag <tag>
phenix gate explain <id>
```

If the first implementation is smaller, it should at least support or scaffold:

```sh
phenix gate list
phenix gate all
phenix gate changed
phenix gate id <id>
```

## Distributed check files

Canonical file name:

```text
.phenix-checks.json
```

The runner should eventually discover these files recursively from the workspace root.

Explicit config files should be passable with:

```sh
phenix gate --config path/to/.phenix-checks.json
phenix gate -c path/to/.phenix-checks.json
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

Each check should eventually support:

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

Expected output shape for failure:

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

Expected output shape for success:

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
* No expected-failing checks in the default gate.
* Future desired checks belong in `roadmap.md`, not as failing gates.

## Test Shell

The workspace provides a deterministic test shell:

```sh
nix develop .#test
```

This shell contains:
- `git`, `nix`, `jq`, `ripgrep`
- `tend` and `stitch` binaries

Use this shell for CI/runtime task execution.  Tend can enter it automatically
via `context.shell` (see [tend.md](tend.md)).

### Workspace DAG verification

```sh
# Via the test shell directly
nix develop .#test --command stitch graph verify --source locks --workspace . --metadata stitch.workspace.json

# Via tend (automatic shell entry)
tend check --profile pre-push
```

Both commands must succeed.  The root `.tend.json` defines two verification
tasks:

- `workspace-dag-valid-shell` — uses `nix develop` (profiles: pre-push, manual)
- `workspace-dag-valid-nix-check` — direct execution (profile: nix-check)

## Initial useful checks

The first gate set should cover simple presence or static checks only, unless deeper checks are already passable:

* docs presence
* OpenCode config presence
* Nix formatting if already passable
* Nix static analysis if already passable
* flake check if already passable
* gate runner self-test if implemented

Do not add migration-specific checks before migration starts.