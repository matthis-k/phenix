# Standalone maintenance model

Every active repository has a `devenv.nix` that discovers local `maintenance.nix` modules.

A maintenance script declares the packages available only while that command runs. Tasks compose those scripts into `maintenance:check`, `maintenance:fix`, and `devenv:enterTest`.

The project flake remains an ordinary flake. `nix flake check` is one maintenance command rather than the host for the maintenance framework.
