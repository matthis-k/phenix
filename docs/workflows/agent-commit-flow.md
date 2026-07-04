---
title: agent-commit-flow
type: note
permalink: newxos/agent-commit-flow
---

# Agent Commit Flow

The canonical agent workflow for Git operations in the Phenix workspace.

## Canonical semantics

| Term | Creates commits | Pushes | Propagates downstream inputs | Tool |
|------|:---:|:---:|:---:|------|
| `local commit` | ✅ | ❌ | ❌ | `stitch commit --apply` |
| `push` | ❌ | ✅ | ❌ | `stitch push --apply` |
| `commit and push` | ✅ | ✅ | ❌ | `stitch commit --apply` then `stitch push --apply` |
| `sync` | ✅ | ✅ | ✅ | `stitch sync --apply` |
| `sync --no-push` | ✅ | ❌ | ✅ | `stitch sync --apply --no-push` |
| `update submodules to remote` | maybe | ❌ | maybe | `stitch update-submodules --remote --apply` |

## Rules

1. `commit` alone always means `local commit` — never push.
2. `commit and push` is explicit — both steps required.
3. `sync` is DAG-aware: update flake inputs, commit, push.
4. `sync up submodules` is ambiguous. Run `stitch classify-git-action --intent status --json` first.
5. Raw `git submodule update --remote` is forbidden. Use `stitch update-submodules --remote --dry-run`.

## Workflow

### Phase 1: Inspect

```text
stitch status              # multi-repo git status
stitch diff --repo <name>  # inspect changes
stitch git-state --json    # structured workspace git state
stitch classify-git-action --intent <intent> --json
```

### Phase 2: Local commit

```text
stitch commit --dry-run          # preview
stitch commit --apply            # local commits, no push
```

Per-repo messages:

```text
stitch commit_template           # generate .stitch/messages.json
stitch commit --messages .stitch/messages.json --apply
```

### Phase 3: Push

```text
stitch push --dry-run            # preview push order
stitch push --apply              # push in DAG dependency order
```

### Phase 4: Sync (DAG-aware commit + push)

```text
stitch sync --dry-run            # preview sync actions
stitch sync --apply              # update inputs, commit, push in DAG order
stitch sync --apply --no-push    # update inputs, commit locally, no push
```

### Phase 5: Update submodules to remote

```text
stitch update-submodules --remote --dry-run   # preview changes
stitch update-submodules --remote --apply     # execute
```

## Safety Rules

1. Never auto-commit without a commit message.
2. Never commit, push, or sync unless WorkScope capability and explicit approval are present.
3. Never push before all local commits succeeded.
4. Never force-push by default.
5. Never use raw `git submodule update --remote`.
6. Never mutate outside the configured workspace repos.
7. Never include unrelated dirty files without external-change gate.

## MCP Workflow

1. `stitch.status` — inspect workspace
2. `stitch.git_state` — structured git state
3. `stitch.classify_git_action` — classify user intent
4. `stitch.diff` — review changes
5. `stitch.dag` — plan commit order
6. `stitch.commit_template` — generate message template
7. `stitch.commit` — local commits only (no_push is redundant but accepted)
8. `stitch.push` — push existing commits
9. `stitch.sync` — full DAG-aware sync
10. `stitch.check_locks` — lock/gitlink invariant check
