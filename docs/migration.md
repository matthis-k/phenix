---
title: migration
type: note
permalink: newxos/migration-1
---

# Phenix Migration Workflow

This document describes the intended Phenix workflow. Items not yet implemented must be tracked in `docs/roadmap.md`.

## Purpose

Migration from `newxos` should happen only after guardrails, OpenCode workflow, and gate tooling exist.

The migration should be deliberate, vertical, and checked.

## Migration is not part of the foundation pass

The foundation pass may inspect `newxos`, but must not port actual features.

No real migration should happen until:

- OpenCode workflow exists
- docs exist
- guardrails exist
- gate runner exists or is deliberately scaffolded
- basic checks pass
- roadmap has the next migration slice

## Migration unit

Migrate one vertical slice at a time:

```text
one concern
  -> package/wrapper
  -> module surface
  -> host enablement
  -> checks
  -> docs
```

Do not migrate by broad domain until the slice pattern is proven.

## Preferred first migrations

Good early candidates:

1. one simple package wrapper
2. one simple module consuming that wrapper
3. one host placeholder enabling it
4. one shell/dev tool wrapper

Avoid starting with:

* complete Hyprland stack
* complete shell stack
* secrets
* networking/VPN
* complex browser profile management
* large theming system

## Migration workflow

Each migration task must use:

1. Inspect source in `newxos`
2. Inspect target Phenix repo
3. Decide ownership
4. Write change contract
5. Implement smallest complete slice
6. Add checks
7. Run gates
8. Review invariants
9. Update docs/roadmap

## Ownership decision

For each migrated concern, decide:

| Concern               | Preferred owner   |
| --------------------- | ----------------- |
| package/wrapper       | `phenix-packages` |
| reusable module       | `phenix-modules`  |
| host enablement       | `phenix-hosts`    |
| shell/UI              | `phenix-shell`    |
| tend/check tooling   | `phenix-tend`     |
| stitch/sync tooling  | `phenix-stitch`   |
| root orchestration    | `phenixos`        |

## Wrapper-first migration

When migrating a program with config, prefer:

```text
wrapper package first
module options second
host enablement third
```

Home Manager/NixOS modules may configure wrappers, but the wrapper should remain the runtime entrypoint where practical.

## Do not copy debt

Do not copy `newxos` structure blindly.

For every migrated file, ask:

* is this still needed?
* is this in the right repo?
* is this a wrapper concern or module concern?
* is this a compatibility layer?
* is this stale documentation?
* can this be smaller?
* can this be checked?

## Migration completion checklist

A migration slice is not done until:

* [ ] ownership is clear
* [ ] files are in the correct repo
* [ ] wrapper/module/host split is explicit
* [ ] checks exist
* [ ] gates pass
* [ ] docs or roadmap are updated
* [ ] no unrelated migration happened
