# Phenix Tooling Skill

Documents the Phenix tooling and gate infrastructure.

## Gate runner

- Command: `phenix-tools gate`
- Check files: `.phenix-checks.json`
- Discovery: recursive from workspace root
- Merge: deterministic, sorted by path, duplicate IDs are errors

## Subcommands

- `phenix-tools gate list` — list all known checks
- `phenix-tools gate all` — run all checks
- `phenix-tools gate changed` — run checks affected by changed files
- `phenix-tools gate id <id>` — run a specific check by ID

## Key principle

Never claim a check passed unless it actually ran.
