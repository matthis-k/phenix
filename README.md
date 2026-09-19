# Phenix

Phenix is a Nix flake workspace composed from independent provider and consumer repositories.

The root repository is aggregation-only. It pins child flakes, re-exports packages, apps, modules, and host configurations, and provides the workspace development shell.

## Agent architecture

Phenix uses one canonical runtime/configuration stack:

- `phenix-ai` owns the core runtime, provider integration, sessions, routing, workflows, execution semantics, default policy, skills, and supported Phenix product.
- `phenix-ai.nvim` owns the canonical Neovim client and consumes `phenix-ai`.
- `phenix-nvim` owns the Neovim distribution and consumes both `phenix-ai` and `phenix-ai.nvim` at one coordinated pin.
- `phenix-hosts` installs the distribution and the consolidated `phenix-ai` product for concrete systems.
- `phenix` aggregates those merged provider-first revisions and re-exports the supported product.

The former standalone `phenix-conductor` and `phenix-harness` repositories are retired. Their useful package/app names may still be exported by `phenix-ai`, but they no longer form independent dependency edges. Historical Pi/OpenCode repository identities are also outside the current graph.

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
