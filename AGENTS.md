# Phenix workspace

This repository is the root Phenix workspace. It aggregates the Phenix subflakes
as Git submodules under `flakes/**`.

Phenix commit terminology and workflow glossary terms are baked into the OpenCode configuration and available in any repository.

Root-level actions are workspace actions. They may inspect, verify, commit, push,
or synchronize multiple submodules together. Do not treat the root repository as
an isolated flake.

Root commits may update submodule gitlinks.

Before committing or pushing from the root, verification must account for:

- root files,
- changed submodule gitlinks,
- dirty or staged files inside submodules,
- affected downstream DAG nodes,
- each affected submodule's own verification contract.

Use `tend` for verification and planning. Use `stitch` for coordinated multi-repo
Git operations. Avoid ad hoc multi-repo Git sequences when an equivalent
`tend`/`stitch` workflow exists.

Direct work inside a submodule must still pass that submodule's local verification.
Do not remove verification just because architecture changes; verification should
target syntax, formatting, linting, compile/eval checks, and behavior-level checks
rather than brittle file-existence assertions.

## Agent guidelines

- Prefer `stitch` for coordinated multi-repo Git operations (status, diff, commit,
  push, sync). Do not use raw `git commit`/`git push` across repos.
- Prefer `tend` for verification/planning (plan, run, explain, status). Do not use
  hand-written ad hoc command sequences when `tend`/`stitch` equivalents exist.
- Before proposing a root commit that touches submodule gitlinks, run
  `tend plan --mode changed` and/or `tend plan --mode staged` to understand the
  verification scope.
- When working inside a submodule, operate from that submodule's directory and
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

The workflow agent prompts and commands are packaged in the `phenix-opencode` submodule wrapper (`flakes/03-integrations/phenix-opencode/`). They are available automatically when using the wrapped opencode binary from the Nix dev shell.

These prompts are generic — they discover project-specific contracts from `AGENTS.md`, `docs/*`, `CLAUDE.md`, or `knowledge/` at runtime rather than hardcoding them.

## Codebase memory MCP

This workspace configures `codebase-memory-mcp` as a local OpenCode MCP server via the Nix flake.

Use it for cheap structural codebase context (architecture overview, module discovery, call graphs, impact analysis, dead-code checks) before expensive file-by-file exploration.

The planner, architect, verifier, and failure-analyzer agents have access to `codebase_memory_*` tools. The implementer may use them for navigation only when explicitly approved.
