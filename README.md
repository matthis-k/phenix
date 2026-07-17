# Phenix

Phenix is a Nix flake workspace composed from independent provider and consumer repositories.

The root repository is aggregation-only. It pins child flakes, re-exports packages, apps, modules, and host configurations, and provides the workspace development shell.

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
