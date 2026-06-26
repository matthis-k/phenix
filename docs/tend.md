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
| profile   | named workflow preset selecting which tasks run        |
| mode      | applicability behavior: changed, staged, full, force   |

## Check execution model

Tend uses profiles to select which tasks run in which context.
`git-hooks.nix` installs Tend as the single source of truth for all checks.
It does not duplicate task definitions.

- `git commit` → installed pre-commit hook → `tend check --profile git-hook --staged`
- `git push` → installed pre-push hook → `tend check --profile pre-push`
- `nix flake check` → `tend check --profile nix-check --offline --locked`
- Developers: `repo-check` (manual), `repo-fix` (fix), `repo-hook` (git-hook), `repo-pushgate` (pre-push)
- `stitch commit` relies on Git hooks (not direct Tend calls)
- `stitch commit --sync` uses a validated Tend preflight token

### Anti-recursion rule

The `nix-check` profile must never include a task that calls `nix flake check`.
This is enforced by `tend validate --profiles`.

### Anti-duplication rule

`git-hooks.nix` installs and invokes Tend.  It does not duplicate Tend task
definitions.  All check logic lives in `.tend.json` task definitions.

## Profiles

| Profile       | Caller                         | Command                                        | Purpose                                    |
|---------------|--------------------------------|------------------------------------------------|--------------------------------------------|
| git-hook      | `git commit` / `stitch commit` | `tend check --profile git-hook --staged`       | Fast staged safety gate                    |
| pre-push      | `git push`                     | `tend check --profile pre-push`                | Medium-cost publish gate                   |
| nix-check     | `nix flake check`              | `tend check --profile nix-check --offline --locked` | Authoritative reproducible automation gate |
| manual        | dev shell                      | `tend check --profile manual` or `repo-check`  | Developer full local gate                  |
| fix           | dev shell                      | `tend check --profile fix` or `repo-fix`       | Mutating format/fix commands               |
| stitch-sync   | `stitch commit --sync`         | `tend check --profile stitch-sync --affected-dag` | One preflight for DAG/sync commits       |

Tasks declare their profiles explicitly.  A task with no profiles defaults to
`manual` only.  Tasks without the requested profile are skipped before any
change detection occurs.

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
- `profiles` — list of profile names that select this task
- `mutates` — override default mutability
- `interactive` — if true, task requires a TTY
- `network` — if true, task requires network access
- `sandbox_safe` — if true, task can run in a Nix build sandbox
- `tags` — categorization tags (e.g. "test", "slow", "network", "rust")
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
# Discovery and listing
tend tree                          # display composed task tree
tend list                          # list all tasks

# Planning (read-only, no execution)
tend plan                          # show which checks would run (preview)
tend plan --profile git-hook       # plan for a specific profile
tend plan --profile nix-check --json  # JSON output for automation

# High-level profile-based check commands
tend check --profile git-hook --staged    # git-hook: fast staged safety gate
tend check --profile pre-push             # pre-push: medium publish gate
tend check --profile nix-check --offline --locked  # nix-check: automation gate
tend check --profile manual               # manual: full local gate
tend check --profile fix                  # fix: mutating fixes

# Low-level commands (agent-friendly)
tend run --phase verify --mode changed   # execute checks (agent-friendly)
tend explain                       # run checks and explain failures

# Convenience aliases
tend verify changed                # non-mutating, changed files
tend verify full                   # non-mutating, all tasks
tend gate                          # alias for `verify changed`
tend fix changed                   # mutating, changed files

# Validation
tend validate --profiles           # validate profile safety rules

# Preflight tokens (for stitch sync)
tend preflight create --profile git-hook --staged    # create token
tend preflight validate --profile git-hook --token <token>  # validate token

# Config options
tend --root <path> tree            # override discovery root
tend --config <path> plan          # explicit config file(s)
tend -c <path> run --phase verify  # shorthand
```

## Profile Validation Rules

`tend validate --profiles` enforces:

1. A task that invokes `nix flake check` must not be in profile `nix-check`.
2. A mutating task must not be in profile `nix-check` or `git-hook`.
3. An interactive task must not be in profile `nix-check` or `git-hook`.
4. A task tagged `test` must not be in profile `git-hook`.
5. A task tagged `slow` must not be in profile `git-hook`.
6. A task tagged `network` must not be in profile `nix-check` or `git-hook`.
7. Tasks with no profiles default to `manual` only.

## Exit Codes

| Code | Meaning                        |
|------|--------------------------------|
| 0    | All required tasks passed      |
| 1    | One or more required tasks failed |
| 2    | Config/discovery/schema error  |
| 3    | CLI usage error (handled by clap) |
| 4    | Mutating task refused in non-mutating command |

## Agent Workflow

The recommended workflow for agents (and humans) is:

1. **Plan**: `tend plan` — preview which checks will run and why.
2. **Run**: `tend run --mode changed --phase verify` — execute checks.
3. **Explain**: `tend explain` — run checks and describe any failures.

Convenience aliases (human-friendly, but `plan → run → explain` is preferred):

- `tend verify changed` — same as `tend run --mode changed --phase verify`
- `tend gate` — same as `tend verify changed`
- `tend fix changed` — same as `tend run --mode changed --phase fix`

Use `tend --root <workspace> tree` to understand the composed task tree.