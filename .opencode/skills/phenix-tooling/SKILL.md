# Phenix Tooling Skill

Documents the Phenix tooling and gate infrastructure.

## Dev shell

The dev shell should make expected tools available. Enter with:

```sh
nix develop
```

## Gate runner

- Command: `tend`
- Check files: `.phenix-checks.json`
- Discovery: recursive from workspace root
- Merge: deterministic, sorted by path, duplicate IDs are errors

## Subcommands

- `tend status` — list known checks and config health
- `tend run --mode all` — run all checks
- `tend run --mode changed` — run checks affected by changed files
- `tend run --mode selected --targets <id>` — run a specific check by ID

## Key principle

Never claim a check passed unless it actually ran.

## Design rules

- Check routing is not AI-based
- Narrow checks before broad checks
- No expected-failing default gates
- No large testing DSL in foundation phase
