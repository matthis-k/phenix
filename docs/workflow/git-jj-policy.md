# Git / jj workflow policy

## Model

- **jj changes** are editing units. They are the working surface for development.
  A jj change may be incomplete, have broken tests, or represent an intermediate
  state. This is normal and expected.
- **Git commits** are integration units. Every pushed Git commit must be a valid
  state that passes its scope checks.
- **Root aggregate commits** must only point to valid submodule commits.

## Rules

1. **jj for development, Git for integration.**
   Use jj for day-to-day work. Use Git commits (via Stitch) for integration points.

2. **Validate before Git commit.**
   Before creating a Git commit, run the relevant checks:
   - `repo-hook` or `tend check --profile git-hook --staged --affected-dag` for
     pre-commit validation.
   - `repo-pushgate` or `tend check --profile pre-push --affected-dag` for pre-push
     validation.
   - `stitch verify --changed --dry-run` for workspace-level integration checks.

3. **Root aggregate safety.**
   A root aggregate commit is invalid if:
   - Submodule pointers point to unverified commits.
   - Submodule working tree is dirty.
   - Submodule has uncommitted changes.
   - Topology mismatch exists.
   - Root checks fail.

4. **No push of known-invalid state.**
   Do not push Git commits that knowingly leave the repo invalid. If a commit
   fails checks, fix the issue before pushing, or do not push.

5. **Avoid "fix previous commit" cleanup.**
   Use jj amend/squash/evolve before exporting Git commits to avoid chains
   of fixup commits.

6. **No remote history rewrite.**
   Do not force-push or rewrite remote history without explicit human confirmation.

7. **Stitch is the multi-repo executor.**
   Do not manually loop through repos for multi-repo operations. Use `stitch`
   for coordinated multi-repo Git operations (status, diff, commit, push, sync).

8. **Tend is the verifier.**
   Use `tend` for verification and planning. Do not use hand-written ad hoc
   command sequences when `tend` equivalents exist.

## Commands

| Step | Command |
|------|---------|
| Pre-commit check | `repo-hook` or `tend check --profile git-hook --staged --affected-dag` |
| Pre-push check | `repo-pushgate` or `tend check --profile pre-push --affected-dag` |
| Integration status | `stitch verify --changed --dry-run` |
| Safe to commit? | `stitch status` + `repo-hook` |
| Safe to push? | `repo-pushgate` + `stitch status` |
