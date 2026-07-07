# Phenix workspace

This repository is the root Phenix workspace and pure flake integration repo. It
aggregates Phenix subflakes through locked flake inputs, not active Git
submodules or gitlinks.

Phenix commit terminology and workflow glossary terms are baked into the OpenCode configuration and available in any repository.

Root-level actions are workspace actions. They may inspect, verify, commit, push,
or synchronize multiple local repos together through Stitch. Do not treat the
root repository as an isolated flake.

Local mutable repo checkouts live under gitignored `/repos/`. Stitch derives the
workspace DAG from flake inputs and locks, optionally mapping locked repos to
local `/repos/` worktrees for developer operations. No Git submodules or gitlinks
are part of the active final architecture.

Before committing or pushing from the root, verification must account for:

- root files,
- changed locked flake input revisions,
- dirty or staged files inside local `/repos/` worktrees,
- affected downstream DAG nodes,
- each affected repo's own verification contract.

Use `tend` for verification and planning. Use `stitch` for coordinated multi-repo
Git operations. Avoid ad hoc multi-repo Git sequences when an equivalent
`tend`/`stitch` workflow exists.

Direct work inside a local workspace repo must still pass that repo's local verification.
Do not remove verification just because architecture changes; verification should
target syntax, formatting, linting, compile/eval checks, and behavior-level checks
rather than brittle file-existence assertions.

## Agent guidelines

- Prefer `stitch` for coordinated multi-repo Git operations (status, diff, commit,
  push, sync). Do not use raw `git commit`/`git push` across repos.
- Prefer `tend` for verification/planning (plan, run, explain, status). Do not use
  hand-written ad hoc command sequences when `tend`/`stitch` equivalents exist.
- Before proposing a root commit that updates locked flake input revisions, run
  `tend plan --mode changed` and/or `tend plan --mode staged` to understand the
  verification scope.
- When working inside a local workspace repo, operate from that repo's directory and
  run its own verification (`tend run` or its shell hooks) before committing.
- Use `--affected-dag` on `tend check` / `tend run` where available to scope checks to downstream nodes.
  Ensure any verification workflow that can affect multiple DAG nodes passes this
  flag so that downstream consumers are verified too.

## Agent workflow

The Phenix workspace uses a structured agent workflow:

```text
request
  -> planner
  -> architect plan check
  -> implementer
  -> verifier
      -> mechanical verification
      -> plan-conformance verification
      -> architectural verification
  -> done if all pass
```

On failure:

```text
verifier failed
  -> failure-analyzer
  -> planner
  -> architect if plan/design/test strategy changes
  -> implementer
  -> verifier again
```

Architecture is checked twice: as **design admission control** before implementation, and as **final repo integrity verification** after implementation. The final verifier also checks plan conformance — whether the implementation matches the accepted plan and change list.

## Workflow prompts and commands

The workflow agent prompts and commands are packaged in the `phenix-agent-harness` wrapper. They are available automatically when using the wrapped opencode binary from the Nix dev shell.

These prompts are generic — they discover project-specific contracts from `AGENTS.md`, `docs/*`, `CLAUDE.md`, or `knowledge/` at runtime rather than hardcoding them.

## Codebase memory MCP

This workspace configures `codebase-memory-mcp` as a local OpenCode MCP server via the Nix flake.

Use it for cheap structural codebase context (architecture overview, module discovery, call graphs, impact analysis, dead-code checks) before expensive file-by-file exploration.

The planner, architect, verifier, and failure-analyzer agents have access to `codebase_memory_*` tools. The implementer may use them for navigation only when explicitly approved.

## Model routing

The Phenix agent harness supports a structured model-routing system that maps tasks
to different model/provider classes based on routing mode, task difficulty, secrecy,
and change kind.

### Routing modes

| Mode | Description |
|------|-------------|
| `mixed` | Default. Routes planner/verifier to GPT Plus slots, implementer to Go slots. |
| `go` | Routes all roles to OpenCode Go slots. Stronger Go slots for planner/verifier at D2/D3. |
| `plus` | Routes all roles to GPT Plus slots. Stronger GPT slots for planner/verifier at D2/D3. |
| `free` | Routes all roles to free/cheap model slots. Hard-guarded: deny private/secret/D2+/security. |
| `manual` | Uses user-configured model slots. Still enforces hard safety/privacy denials. |

### Difficulty classes

| Class | Description |
|-------|-------------|
| `D0` | Trivial/mechanical — typo fixes, trivial renames. Planner may be skipped or cheap. |
| `D1` | Repo-aware but bounded — single-file or localized edits with clear intent. |
| `D2` | Architectural or multi-file — cross-module changes, new abstractions. |
| `D3` | High-risk, ambiguous, broad, cross-module, or main-sensitive. |

### Ctrl+T keybinding

`Ctrl+T` cycles the active routing mode: `mixed → go → plus → free → manual → mixed`.
If `free` is unsafe (private/secret/security-sensitive task), it is skipped silently.

### External-plan acceptance

The planner can detect whether the user prompt is already a usable plan. If the
prompt contains explicit steps, file paths, constraints, and validation expectations
(`CompletePlan`), it is preserved with minimal normalization. If it has a clear
objective but missing fields (`PartialPlan`), missing contract fields are added. If
it is not a plan (`NotAPlan`), normal internal planning runs.

All plans are normalized into a standard **Planner Contract** format before being
passed to the implementer.

### Configuration

Routing configuration is exposed through `phenix.agentRouting` in the OpenCode config:

```nix
{
  phenix.agentRouting = {
    enable = true;
    defaultMode = "mixed";
    keybindings.cycleRoutingMode = "ctrl+t";
    modes = { ... };
    slots = {
      planner.normal = "gpt-plus/medium";
      planner.strong = "gpt-plus/high";
      implementer.cheap = "opencode-go/cheap";
      implementer.normal = "opencode-go/coding";
      implementer.strong = "opencode-go/strong";
      verifier.cheap = "opencode-go/different-cheap";
      verifier.strong = "gpt-plus/high";
      free.publicOnly = "zen-free/default";
    };
    freeMode = {
      denyPrivate = true;
      denySecret = true;
      denyDifficulties = [ "D2" "D3" ];
      denyChangeKinds = [ "Secrets" "Auth" "Ci" "RepoArchitecture" ];
    };
    externalPlans = {
      enable = true;
      normalizePartialPlans = true;
      preserveCompletePlans = true;
      requireArchitectureCompliance = true;
    };
  };
}
```

### CLI flags

The `/flow` command accepts:
- `--routing-mode mixed|go|plus|free|manual` (default: mixed)
- `--difficulty auto|D0|D1|D2|D3` (default: auto)
- `--target-state scratch|dev-wallet|main-bound` (default: dev-wallet)
- `--external-plan auto|force|off` (default: auto)

### References

Detailed routing documentation is in the agent harness prompts:
- `prompts/workflow.md` — routing policy, Ctrl+T, mode resolution
- `prompts/planner.md` — external-plan acceptance, plan classification, contract format
- `prompts/verifier.md` — routing policy verification
- `prompts/implementer.md` — routing scope constraints
- `prompts/architecture-verifier.md` — routing invariants
- `commands/route.md` — cycle-routing-mode command
- `knowledge/glossary.md` — routing terminology
