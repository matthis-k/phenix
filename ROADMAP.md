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
- [x] Tend task cache — implemented: cache structs, CLI commands, execution wiring, and stable content hashing (blake3) all complete; tests cover cache hit/miss, no-cache, failed-task exclusion, and key stability.
- [x] Tend task prerequisites / requires — implemented: model, planner, executor, and comprehensive tests covering prerequisite chains, cycles, unknown refs, object/bare-string refs, generated-source policy, and profile-filtering edge cases; JSON/human plan reporting and profile-policy coverage still need polish.
- [ ] Tend generated flake support (adopt flake-file or defer explicitly) — deferred: flake-file API maturity needs evaluation
- [x] Stitch topology validation (URL match, path existence, layer consistency)
- [x] Stitch safe integration status gate — validation_commands, status --integration, --no-verify flag
- [x] CI pipeline: explicit tend/stitch verification steps (config validation, nix-check, topology validation, downstream verify)
- [x] Topology URLs normalized to SSH
- [x] agent-harness URL corrected (phenix-opencode → phenix-agent-harness)

### Root aggregate cleanup
- [x] Remove mkForce-based module re-exports
- [x] Composable export style established
- [x] Clean phenix-wrappers.nix (made useful — exposes tend, stitch, opencode, pi as config.phenixWrapped)
- [x] Delete legacy tend-shell.nix
- [x] Fix .gitignore for .stitch/ (only ignore cache, not topology.json)
- [x] Lockfile dedup: flake-parts 18→10, nixpkgs-lib 18→10 via follows
- [x] Dead code removal: CacheDefaultMode enum and default_mode field from tend cache.rs

### Agent friction cleanup
- [x] Remove old .opencode/agent definition files (replaced by generated config from agent harness)
- [x] Canonicalize permissions classification — operation-class model defined in Nix, generated permission maps improved from typed structure; semantic permission runtime enforcement still missing
- [x] MCP-first enforcement — prompt/test-level only, documented as design intent; structural verifier/runtime enforcement still deferred
- [x] Routing mode runtime state — `phenix-route` persists XDG route state, resolves logical slots deterministically, and the OpenCode wrapper applies the generated overlay at process start; hot switching remains unsupported and requires restart.

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

- [ ] CLI surface stabilization tests
- [x] Task cache — implemented: execution wiring, stable blake3 hashing, cache status/explain CLI commands, and test coverage
- [x] Task prerequisites / requires — implemented
- [x] Requires tests — comprehensive; still needs reporting/profile-policy polish
- [ ] Profile validation enforcement
- [ ] Generated flake: adopt flake-file or mark experimental

## Stitch backlog

- [x] Topology validation: URL vs .gitmodules match, path existence, layer consistency
- [x] Integration status gate
- [ ] Commit safety — deferred (partial: --no-verify flag added)
- [ ] Sync safety — deferred (partial: validation_commands wired)
- [x] Full Stitch → Tend verification in CI (verify --changed --downstream)

## Deferred/deleted items

- Old `.opencode/agents/*.md` files — replaced by generated config from agent harness
- `docs/roadmap.md` — replaced by root ROADMAP.md
- `tend-shell.nix` — legacy, removed
- Changelog/release ceremony — never existed, no need to add
- `phenix-wrappers.nix` — now populated as useful re-export
