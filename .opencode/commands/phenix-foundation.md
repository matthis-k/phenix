# /phenix-foundation

Used for foundation work only.

## Scope

- guardrails
- OpenCode config
- dev shells
- test runner
- gate infrastructure
- docs
- roadmap

## Hard rule

Must not migrate real `newxos` features.

## Workflow

1. Inspect current state
2. Understand what foundation piece is needed
3. Write change contract
4. Implement smallest complete slice
5. Run gates (via `phenix-tools gate`)
6. Review invariants
7. Update `docs/roadmap.md`

## After each task

Update `docs/roadmap.md` with the current completion status.
