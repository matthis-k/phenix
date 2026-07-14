---
title: pi
type: note
permalink: phenix/pi
---

# Phenix Pi workflow

Pi is the supported coding-agent runtime for Phenix. Its package, extensions,
routing policy, permissions, contracts, and session behavior are owned by
`phenix-agent-harness`.

## Entry points

On a configured workstation:

```console
phenix ai
```

This enters the root Phenix repository and starts the wrapped Pi runtime.
The Pi package can also be invoked directly from the host development environment.

## Responsibility split

- Pi performs model interaction and session management.
- Tend plans and executes deterministic repository verification.
- Stitch owns cross-repository graph and Git coordination.
- Nix owns package, runtime dependency, and configuration assembly.
- TypeScript owns routing, state transitions, output verification, and permissions.

Provider identifiers such as `opencode-go` may remain in routing configuration when
they identify a model backend consumed by Pi. They do not imply use of the retired
OpenCode agent application.

## Configuration rules

- Keep runtime configuration in `phenix-agent-harness`, not the root repository.
- Prefer XDG configuration, state, and cache paths.
- Do not create a second agent wrapper in the root flake.
- Keep deterministic validation out of prompts.
- Run the owning repository's Tend profile before updating the root lock.
