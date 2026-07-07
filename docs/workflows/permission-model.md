---
title: permission-model
type: reference
permalink: phenix/permission-model
---

## Role permission table

| Role | Allowed operations | Denied operations |
|------|-------------------|-------------------|
| Frontend (phenix-workflow) | RepoRead, create_workflow, delegate | WorkspacePatch, StageTrackedChanges, LocalCommit, Push |
| Planner (phenix-planner) | RepoRead, create_plan | WorkspacePatch, LocalCommit, Push |
| Architect (phenix-architect) | RepoRead, architecture_review | WorkspacePatch, LocalCommit, Push |
| Worker (phenix-worker) | RepoRead, WorkspacePatch, WorkspaceCreateFile, WorkspaceMkdir, FormatFix, StageNewFiles | LocalCommit, Push |
| Verifier (phenix-verifier) | RepoRead, Verify | WorkspacePatch, FormatFix, LocalCommit, Push |
| Committer (phenix-commit-sync) | RepoRead, StageTrackedChanges, LocalCommit, LocalCommitNoVerify, SyncNoPush | Push (unless explicit push lease) |

## Lease types

| Lease kind | Composed operations | Expected approvals |
|------------|-------------------|-------------------|
| ReadOnly | RepoRead + RepoSearch | 0 |
| BoundedWorkspaceEdit | WorkspacePatch + WorkspaceCreateFile + WorkspaceMkdir + FormatFix + StageNewFiles + Verify | 1 |
| Verification | RepoRead + Verify | 0 |
| LocalCommit | StageTrackedChanges + LocalCommit (+ LocalCommitNoVerify in local DAG mode) | 1 |
| SyncNoPush | StageTrackedChanges + LocalCommit + LockUpdate | 1 |
| Push | Push | 1 (always explicit) |

## Approval counts by workflow

| Workflow | Total approvals |
|----------|----------------|
| inspect-only | 0 |
| bounded local edit + verify | 1 |
| bounded edit + local commits (no push) | 2 |
| sync/push | 1 extra |
| dangerous/destructive | always ask |

## Auto-allow commands (0 approvals)

```
ls, pwd, read, rg/grep/find, git status/diff/log/show/rev-parse
stitch status, stitch diff, stitch dag (read-only)
tend status, tend plan (read-only)
```

## Auto-deny (always ask)

```
git push, stitch sync with push
sudo, rm -rf tracked, chmod outside repo
editing secrets / tokens
networked lock updates, branch delete, force push
```

## Nix flake source visibility rule

Created files imported by a flake are auto-staged before `nix flake check`. No extra approval needed under BoundedWorkspaceEdit.

## Local DAG commit mode

`LocalCommitNoVerify` allowed when:
1. LocalWorkspaceMode enabled
2. Reason recorded (workspace repo commit exists locally not pushed)
3. Will be pushed before remote consumers evaluate

## go on / continue / resume

1. Resume current session
2. Continue from last blocked/incomplete task
3. Reuse still-valid permission leases
4. Don't re-plan unless plan is missing/invalid
5. Don't repeat answered questions

## Generated file policy

`.pre-commit-config.yaml` is ignored everywhere (root + all workspace repos). Stitch status treats it as non-meaningful.

## Key references

- Full spec: `docs/agent-workflow.md`
- Commit flow: `docs/workflows/agent-commit-flow.md`
- Check flow: `docs/workflows/agent-check-flow.md`
