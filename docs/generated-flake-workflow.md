# Generated flake workflow

Repositories using `flake-file` keep input declarations in their source module and regenerate `flake.nix` with:

```sh
nix run .#write-flake
```

After provider changes, regenerate the flake, update `flake.lock`, run `devenv test`, and commit only canonical source, generated flake, and lock changes. Temporary logs and result links remain untracked.
