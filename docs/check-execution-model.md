# Check execution model

- `git commit` runs `tend check --profile git-hook --staged` via `git-hooks.nix`.
- `git push` runs `tend check --profile pre-push` via `git-hooks.nix`.
- `nix flake check` runs `tend check --profile nix-check --offline --locked`.
- Developers can run `tend check --profile manual` for the full local gate.
- Developers can run `tend check --profile fix` for mutating fixes.
- `git-hooks.nix` installs and invokes Tend. It does not duplicate Tend task definitions.
- Hook entries call the exposed Tend binary directly through `${self'.packages.tend}/bin/tend`.
- The `nix-check` profile must never include a task that calls `nix flake check`.
- `stitch commit` relies on Git hooks for normal commits.
- `stitch commit --sync`, if implemented, may avoid duplicate hook runs only through validated Tend preflight tokens.
