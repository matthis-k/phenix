# Phenix Architecture Skill

Documents the Phenix repo architecture and guardrails.

## Referenced docs

- `docs/guardrails.md` — root repo rule, dendritic rule, wrapper-first rule
- `docs/migration.md` — ownership table

## Key rules

- Root repo is orchestration-only
- One feature per file/directory
- Wrapper-first runtime composition
- No newxos compatibility debt
- No big-bang migration
- Docs as ought-state — describe the intended workflow, not historical notes
- Roadmap tracks actual implementation vs documented intent
