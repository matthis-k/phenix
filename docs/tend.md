---
title: tend
type: note
permalink: newxos/tend
---

# tend — Low-Level Composable Task Harness

`tend` is the low-level distributed task / verification / hook harness for the
Phenix workspace.  It replaces ad-hoc pre-commit hooks, check scripts, and
agent-specific command lists with a single, discoverable, tree-composable
system.

## Relationship to phenix

```
tend   — low-level distributed task harness (this tool)
phenix — reserved for higher-level Phenix workspace/OS commands
```

`phenix` may later delegate to `tend`, but `tend` must remain usable
independently.

## Concepts

| Term      | Meaning                                                |
|-----------|--------------------------------------------------------|
| node      | a tree container that owns local tasks and children    |
| task      | an executable or built-in action                       |
| phase     | task intent: verify, fix, generate, build, test, etc.  |
| profile   | named workflow preset (e.g. gate)                      |
| mode      | applicability behavior: changed, full, force           |

## Phases

Data model supports: `generate`, `fix`, `verify`, `build`, `test`, `setup`,
`cleanup`.

CLI exposes:

- `verify` — non-mutating checks
- `fix` — mutating fix/generate actions
- `generate` — mutating generation actions
- `gate` — non-mutating gate preset (equivalent to `verify changed`)

### Mutating vs Non-Mutating

Tasks declare `"mutates": true` or `"mutates": false`.

Default by phase:

| Phase      | Default mutates |
|------------|----------------|
| generate   | true           |
| fix        | true           |
| setup      | true           |
| cleanup    | true           |
| verify     | false          |
| build      | false          |
| test       | false          |

**Hard rule:** `verify` and `gate` commands refuse to run tasks with
`mutates: true`.  Mutating commands (`fix`, `generate`) allow them.

## Config Discovery

1. Determine root: explicit `--root` or current working directory.
2. Recursively find files named exactly `.tend.json`.
3. Ignored directories: `.git`, `.direnv`, `result`, `result-*`,
   `node_modules`, `vendor`, `target`, `dist`, `build`, `.cache`, `.nix`.
4. Sorted lexicographically, loaded in order.
5. Config file paths are relative to the containing directory.
6. Duplicate task IDs in one node are an error.
7. Duplicate node paths are an error.

Use `--config <path>` / `-c <path>` to load explicit config files instead of
auto-discovery.  May be specified multiple times.

## Config Schema

```json
{
  "version": 1,
  "node": {
    "id": "docs",
    "description": "Documentation checks",
    "tags": ["docs", "foundation"],
    "when": {
      "changed": { "paths": ["docs/**/*.md"] }
    },
    "context": {
      "workdir": ".",
      "env": {}
    },
    "before": [],
    "tasks": [],
    "after": []
  }
}
```

### Node fields

- `id` — display name (default: relative path)
- `description` — human-readable description
- `tags` — categorization
- `when.changed.paths` — globs that trigger this node
- `context.workdir` — working directory override
- `before` — list of steps run before tasks
- `tasks` — list of task definitions
- `after` — list of steps run after tasks

### Task fields

- `id` — required unique ID within this node
- `description` — human-readable
- `phase` — one of: `generate`, `fix`, `verify`, `build`, `test`, `setup`,
  `cleanup`
- `kind` — one of: `command`, `filesExist`, `filesAbsent`, `forbidText`,
  `requireText`
- `mutates` — override default mutability
- `when.changed.paths` — glob conditions
- `always` — run even in full mode without changed files
- `before` / `after` — lists of steps

### Task kinds

**command**
```json
{
  "id": "flake-check",
  "phase": "verify",
  "kind": "command",
  "mutates": false,
  "command": ["nix", "flake", "check"],
  "expect": { "status": 0 }
}
```

**filesExist**
```json
{
  "id": "docs-exist",
  "phase": "verify",
  "kind": "filesExist",
  "paths": ["docs/README.md", "docs/roadmap.md"]
}
```

**filesAbsent**
```json
{
  "id": "no-root-feature-modules",
  "phase": "verify",
  "kind": "filesAbsent",
  "paths": ["modules", "hosts", "packages"]
}
```

**forbidText**
```json
{
  "id": "no-generated-fence-ids",
  "phase": "verify",
  "kind": "forbidText",
  "paths": ["docs/**/*.md"],
  "patterns": ["id=\""]
}
```

**requireText**
```json
{
  "id": "docs-declare-ought-state",
  "phase": "verify",
  "kind": "requireText",
  "paths": ["docs/guardrails.md"],
  "patterns": ["This document describes the intended Phenix workflow"]
}
```

## Before and After

Nodes and tasks may define `before` and `after` step lists.

For a task:
```
task.before → task action → task.after
```

For a node:
```
node.before → node.tasks → child nodes → node.after
```

If a node has children (via recursive discovery), its `before` runs before
all children and its `after` runs after all children.

**Failure semantics:**
- If `before` fails, the node/task fails and normal work is skipped.
- `after` runs if the node/task started.
- If `after` fails, the node/task fails.
- `after` with `"always": true` runs even if a prior step failed.

## Conditions (when.changed.paths)

Use git to detect changed files, then match against glob patterns.

Modes:
- `changed` — run only tasks affected by changed files
- `full` — evaluate all tasks, skip tasks with `when.changed.paths` unless
  `always: true` or the paths set is empty
- `force` — run everything, ignore `when.changed.paths`

## CLI

```
tend tree                          # display composed task tree
tend list                          # list all tasks

tend verify changed                # non-mutating, changed files only
tend verify full                   # non-mutating, all tasks
tend verify force                  # non-mutating, ignore conditions

tend fix changed                   # mutating, changed files only
tend fix all                       # mutating, all applicable

tend generate changed              # mutating generation, changed files
tend generate all                  # mutating generation, all

tend gate                          # non-mutating gate (verify changed)

tend --root <path> tree            # override discovery root
tend --config <path> verify full   # explicit config file(s)
tend -c <path> verify full         # shorthand
```

## Exit Codes

| Code | Meaning                        |
|------|--------------------------------|
| 0    | All required tasks passed      |
| 1    | One or more required tasks failed |
| 2    | Config/discovery/schema error  |
| 3    | CLI usage error (handled by clap) |
| 4    | Mutating task refused in non-mutating command |

## Agent Workflow

For agents, recommended usage:

1. Always run `tend verify changed` before making changes.
2. After changes, run `tend fix changed` to apply fix/generate tasks.
3. Before committing, run `tend gate` as the final check.
4. Use `tend --root <workspace> tree` to understand the composed task tree.