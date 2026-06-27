# Verification

## Passing criteria

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

## Plan-conformance verification

The verifier must compare the final diff against:

```text
.opencodestate/implementation-plan.yaml
.opencodestate/planned-changes.yaml
.opencodestate/implementation-summary.yaml
```

It must fail if implementation substantially deviates from the original plan and no replan occurred.

## Architecture-contract verification

The verifier must compare the final diff against:

```text
.opencodestate/architecture-review.yaml
.opencodestate/architecture-contract.yaml
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

Architecture verification should fail if the implementation passes tests but violates the intended repo shape or deviates from the accepted architecture contract.
