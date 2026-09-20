# Phenix

Phenix is a Nix flake workspace composed from independent provider and consumer repositories.

The root repository is aggregation-only. It pins child flakes, re-exports packages, apps, modules, and host configurations, and provides the workspace development shell.

## Agent architecture

Phenix uses one canonical AI stack:

- `phenix-ai` owns the frontend-neutral core, runtime, plugins, providers, supported product configuration, routing, orchestration, and skills.
- `phenix-ai.nvim` owns the canonical Neovim AI client and packages the matching ACP runtime and Lua binding.
- `phenix-nvim` owns editor composition and pins the client and runtime as one tested dependency unit.
- `phenix-hosts` installs the supported `phenix-ai` product and the Neovim distribution for concrete systems.

Conductor and Harness remain implementation components inside `phenix-ai`. Their standalone repositories are retired and are not part of the workspace dependency graph.

## Local workspace

The root owns the desired Phenix repository set through its lock graph and `.stitch-workspace.json` policy. Local clones live under the gitignored `repos/` directory.

```sh
# Clone missing repositories and fast-forward clean existing clones.
nix run .#init-workspace

# Preview or apply removal of obsolete wrapper-managed clones.
nix run .#clean-workspace
nix run .#clean-workspace -- --apply

# Run arbitrary Nix commands against the root with local flake overrides.
nix run .#nixdev -- flake check
nix run .#nixdev -- develop
nix run .#nixdev -- build .#phenix
```

`nixdev` changes to the Phenix root, injects `--override-input` for every local Phenix flake, and then forwards the remaining arguments directly to Nix. The convenience apps `dev` and `check-local` remain aliases for `nixdev -- develop` and `nixdev -- flake check`.

The local commands use `git+file:` input overrides and do not modify the production lock file. Dirty tracked changes are evaluated immediately. New files only need `git add`; they do not need to be committed.

## Maintenance

Repository checks are defined locally in `maintenance.nix` and executed through standalone devenv:

```sh
devenv test
devenv tasks run maintenance:check
devenv tasks run maintenance:fix
```

## Workspace coordination

Cross-repository selection and ordering are provided by Stitch. Stitch does not define repository-specific checks; it invokes the command supplied by the caller:

```sh
stitch exec --changed --closure downstream --order providers-first -- devenv test
```
