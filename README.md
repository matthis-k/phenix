# Phenix

Phenix is a Nix flake workspace composed from independent provider and consumer repositories.

The root repository is aggregation-only. It pins child flakes, re-exports packages, apps, modules, and host configurations, and provides the workspace development shell.

## Local workspace

The root owns the desired Phenix repository set through its lock graph and `.stitch-workspace.json` policy. Local clones live under the gitignored `repos/` directory.

```sh
# Clone missing repositories and fast-forward clean existing clones.
nix run .#init-workspace

# Preview or apply removal of obsolete wrapper-managed clones.
nix run .#clean-workspace
nix run .#clean-workspace -- --apply

# Enter the root development shell with every local flake overridden locally.
nix run .#dev

# Run the root flake check with the same local overrides.
nix run .#check-local
```

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
