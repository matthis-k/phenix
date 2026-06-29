# /phenix-task

General entrypoint for Phenix work.

## Enforced workflow

1. **Intake** — clarify the request
2. **Discovery** — explore relevant files and ownership
3. **Ownership decision** — which repo does this belong to?
4. **Change contract** — write before editing
5. **Implementation** — smallest complete slice
6. **Gate execution** — run `tend`
7. **Invariant review** — check against guardrails
8. **Simplification review** — check for debt/copying
9. **Final report** — summary, files, checks, roadmap

## Foundation boundary

For now, respects the foundation boundary unless the user explicitly asks for a later phase.

## Hard rule

Must still follow the strict workflow. No skipping directly to edits.
