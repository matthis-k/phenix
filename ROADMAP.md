# Phenix Roadmap

> This project is not alpha yet. Roadmap/backlog are planning tools, not release records.

**Current status**: Pre-alpha tooling groundwork. Creating a clean, reliable base for future NewXOS migration.

## jj/Git policy

- **jj changes** are editing units. They may be incomplete, experimental, or invalid.
- **Git commits** are integration units. Every pushed Git commit must pass the relevant scope checks.
- **Root commits** must only point to valid submodule commits.
- Do not push "fix previous commit" cleanup commits if avoidable.
- Use jj amend/squash/evolve before exporting Git commits.
- Do not rewrite remote history without explicit human confirmation.

## Clean-base milestone (in progress)

The current priority. Complete these before any NewXOS migration:

### Toolchain
- [x] Tend task cache (conservative, deterministic, read-only)
- [ ] Tend task prerequisites / requires — deferred: requires planning/design beyond scope of clean-base pass
- [ ] Tend generated flake support (adopt flake-file or defer explicitly) — deferred: flake-file API maturity needs evaluation
- [x] Stitch topology validation (URL match, path existence, layer consistency)
- [ ] Stitch safe integration status gate — deferred: requires additional Stitch feature work
- [x] Topology URLs normalized to SSH
- [x] agent-harness URL corrected (phenix-opencode → phenix-agent-harness)

### Root aggregate cleanup
- [x] Remove mkForce-based module re-exports
- [x] Composable export style established
- [ ] Clean phenix-wrappers.nix (make useful or delete) — deferred: phenix-wrappers kept as minimal option placeholder
- [x] Delete legacy tend-shell.nix
- [x] Fix .gitignore for .stitch/ (only ignore cache, not topology.json)

### Agent friction cleanup
- [x] Remove old .opencode/agent definition files (replaced by generated config from agent harness)
- [ ] Canonicalize permissions classification — deferred: requires model-level semantic classification > string matching (ongoing work)
- [ ] MCP-first enforcement (verifier checks transport evidence) — deferred: verifier logic needs update for transport evidence format
- [ ] Routing mode docs aligned with actual tool support — deferred: requires OpenCode native routing API

### Shared devshell helpers
- [x] Create shared helper module (phenix-helpers.nix)
- [x] Deduplicate repo-hook/repo-pushgate/repo-check/repo-fix (root now uses centralized helpers)

### Docs
- [x] docs/workflow/git-jj-policy.md
- [x] Repository topology documented with agreed names and URLs

## NewXOS migration backlog

**Migration starts only after clean-base milestone is complete.**

Do not start migrating NewXOS feature content during clean-base tasks.

### Planned migration slices (not started)

1. First real host (nixosConfiguration)
2. Base Nix configuration
3. HM bridge/user setup
4. SOPS bootstrap
5. Dev tools (packages already scaffolded in phenix-packages)
6. Hyprland base
7. Shell/browser/theme/VPN (later slices)

### Migration principles

- One vertical slice at a time: package → module → host → checks → docs
- No big-bang migration
- Do not copy debt from newxos
- Wrapper-first: wrapper package before module options before host enablement

## Tend backlog

- [ ] CLI surface stabilization tests — still needed
- [x] Task cache (conservative read-only)
- [ ] Task prerequisites / requires — deferred
- [ ] Profile validation enforcement — still needed
- [ ] Generated flake: adopt flake-file or mark experimental — deferred

## Stitch backlog

- [x] Topology validation: URL vs .gitmodules match, path existence, layer consistency
- [ ] Integration status gate — deferred
- [ ] Commit safety — deferred
- [ ] Sync safety — deferred
- [ ] Full Stitch → Tend verification command — deferred

## Deferred/deleted items

- Old `.opencode/agents/*.md` files — replaced by generated config from agent harness
- `docs/roadmap.md` — replaced by root ROADMAP.md
- `tend-shell.nix` — legacy, removed
- Changelog/release ceremony — never existed, no need to add
- `phenix-wrappers.nix` — kept as minimal placeholder
