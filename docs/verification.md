# Verification

For one repository:

```sh
devenv test
```

For selected repositories in dependency order:

```sh
stitch exec --changed --closure downstream --order providers-first -- devenv test
```

CI is read-only. Mutating formatting and safe cleanup run through `devenv tasks run maintenance:fix` before review, never inside the final CI gate.
