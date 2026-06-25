---
title: guardrails
type: note
permalink: newxos/guardrails
---

# Phenix Guardrails

This document describes the intended Phenix workflow.

It is an **ought-state** document. Items not yet implemented must be tracked in [`roadmap.md`](./roadmap.md).

## Purpose

The guardrails prevent Phenix from becoming another organic dotfiles blob.

Agents and humans should optimize for:

- explicit ownership
- local reasoning
- small vertical slices
- wrapper-first runtime behavior
- reproducible checks
- minimal hidden state
- no accidental root-repo accumulation
- no historical compatibility debt

## Repository ownership

Expected workspace layout:

```text
~/phenix/
  phenixos/          # root orchestration workspace
  phenix-tools/      # sync, gate, test runner, helper CLIs
  phenix-packages/   # packages and runtime wrappers
  phenix-modules/    # reusable NixOS/Home Manager modules
  phenix-hosts/      # actual host definitions
  phenix-shell/      # quickshell/newshell and shell UI
  phenix-pins/       # pin/input policy, if kept separate
  newxos/            # old source repo used only for migration reference
```

## Root repo rule

The root `phenixos` repo is orchestration-only.

It may contain:

* workspace docs
* repo-local OpenCode config
* superflake composition
* dev-shell entrypoints
* high-level checks
* references to subrepos
* orchestration commands

It must not accumulate feature implementation.

Suspicious examples:

```text
phenixos/modules/browser/default.nix
phenixos/modules/hyprland/default.nix
phenixos/packages/zen-wrapper.nix
phenixos/hosts/laptop/default.nix
```

Those should usually live in more specific repos.

## Dendritic rule

Prefer one feature per file or directory.

Avoid central mega-files.

Good:

```text
modules/
  programs/
    browser/
      zen.nix
    terminal/
      foot.nix
```

Bad:

```text
modules/programs.nix
modules/all-desktop-things.nix
```

## Wrapper-first rule

Runtime configuration should prefer wrappers where practical.

A configured program should usually expose a package/wrapper that injects:

* environment variables
* flags
* config paths
* generated config fragments
* runtime dependencies

Home Manager or NixOS modules may configure or select the wrapper, but should not replace wrapper-based runtime composition with scattered raw `~/.config` generation unless unavoidable.

Preferred shape:

```text
module option
  -> wrapper derivation/config
  -> installed runtime entrypoint
```

Avoid:

```text
module option
  -> many unrelated ~/.config files
  -> unclear runtime entrypoint
```

## Migration rule

Migrations from `newxos` must happen in small vertical slices.

A vertical slice is:

```text
one concern
  -> package/wrapper
  -> module surface
  -> host enablement
  -> checks
  -> docs
```

Do not do big-bang migrations.

Bad:

```text
Migrate all desktop config from newxos.
```

Good:

```text
Migrate the Zen Browser wrapper only.
```

Better:

```text
Create the package wrapper first. Add module options later.
```

## Compatibility rule

Do not preserve `newxos` compatibility unless explicitly required.

Phenix is allowed to be a clean break.

Avoid:

* migration shims
* old aliases
* dual pipelines
* deprecated option support
* historical fallback paths

## Agent workflow rule

Every nontrivial agent task should use this sequence:

1. Inspect
2. Decide ownership
3. Write a change contract
4. Implement the smallest complete slice
5. Run checks
6. Review invariants
7. Update roadmap/docs if needed

## Change contract

Before editing, the agent should produce:

```md
## Change contract

Goal:
- ...

Ownership:
- ...

Files expected to change:
- ...

Invariants:
- ...

Checks:
- ...

Non-goals:
- ...
```

## Invariant review checklist

After editing, check:

* [ ] Root repo stayed orchestration-only
* [ ] Dendritic layout was preserved
* [ ] Wrapper-first model was preserved where relevant
* [ ] No feature implementation landed in the wrong repo
* [ ] No hidden `~/.config` sprawl was introduced
* [ ] No `newxos` compatibility layer was added
* [ ] Docs still describe the intended workflow
* [ ] Roadmap tracks unfinished work
* [ ] Gates/checks cover the important behavior