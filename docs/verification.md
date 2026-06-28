# Verification

## Passing criteria

Normal verification targets syntax, formatting, linting, compile/evaluation,
tests, behavior-level contracts, and workspace topology. It must not fail solely
because an active submodule lacks an incidental file such as `.tend.json`; file
layout audits belong in explicit optional workspace-audit workflows.

In full `/flow` mode, `status: passed` requires:

```yaml
mechanical_verification:
  status: passed
plan_conformance:
  status: passed
architecture_verification:
  status: passed
plan_context:
  available: true
```

Do not report `passed` if:

* only mechanical checks passed;
* only generic architecture checks passed;
* original plan artifacts are missing;
* final diff cannot be compared to the accepted implementation plan;
* final diff cannot be compared to the accepted architecture contract;
* any changed file is outside the planned change list without justification;
* any actual change lacks a planned change ID;
* dependency direction or module boundaries changed without explicit plan/docs support;
* docs/tests/config are inconsistent with behavior;
* tests freeze incidental architecture;
* useful verification was removed.

Full workflow verification must read the original `.opencodestate/` blackboard
artifacts and ledgers where present. The ledgers provide run history, decisions,
artifact provenance, and verification evidence; they supplement but do not
replace the accepted implementation plan, planned changes, architecture review,
and architecture contract.

## Plan-conformance verification

The verifier must compare the final diff against:

```text
.opencodestate/implementation-plan.yaml
.opencodestate/planned-changes.yaml
.opencodestate/implementation-summary.yaml
.opencodestate/artifact-ledger.yaml
```

It must fail if implementation substantially deviates from the original plan and no replan occurred.

## Architecture-contract verification

The verifier must compare the final diff against:

```text
.opencodestate/architecture-review.yaml
.opencodestate/architecture-contract.yaml
.opencodestate/decision-ledger.yaml
```

It must fail if implementation passes tests but violates the accepted architecture contract.

## Standalone verification

Standalone `/verify` may pass mechanical and generic architecture checks without `.opencodestate/`.

However, it must clearly report:

```yaml
plan_context:
  available: false
  consequence: Cannot verify implementation against accepted original plan; only generic repo architecture verification was performed.
```

## Architecture verification

Architecture verification checks the final diff against the planned architecture and accepted architecture contract.

The verifier should use:

- `git diff`
- `git diff --stat`
- `.opencodestate/planner-output.yaml`
- `.opencodestate/architecture-review.yaml`
- `.opencodestate/architecture-contract.yaml`
- repo docs
- codebase memory tools for structural context
- `.opencodestate/run-ledger.yaml` and `.opencodestate/verification-ledger.yaml`
  when present for workflow transition and check evidence

Architecture verification should fail if the implementation passes tests but violates the intended repo shape or deviates from the accepted architecture contract.

## Tool routing

Use `tend` for verification planning and execution. Use `stitch` for multi-repo
Git status, diff, commit, push, and sync coordination. Verification should not
be made to pass by routing around these tools with ad hoc raw shell or Git
workflows when the documented route exists.
