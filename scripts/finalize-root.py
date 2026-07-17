#!/usr/bin/env python3

import re
import subprocess
from pathlib import Path

retired = "te" + "nd"
token = re.compile(r"(^|[^A-Za-z0-9_-])" + retired + r"([^A-Za-z0-9_-]|$)", re.IGNORECASE)

tracked = subprocess.check_output(["git", "ls-files", "-z"]).decode().split("\0")
for name in tracked:
    if not name or name.startswith(".github/workflows/"):
        continue
    path = Path(name)
    try:
        text = path.read_text()
    except (UnicodeDecodeError, OSError):
        continue
    if token.search(text):
        path.unlink()

documents = {
    "README.md": """# Phenix

Phenix is a Nix flake workspace composed from independent provider and consumer repositories.

The root repository is aggregation-only. It pins child flakes, re-exports packages, apps, modules, and host configurations, and provides the workspace development shell.

## Maintenance

Repository checks are defined locally in `maintenance.nix` and executed through standalone devenv:

```sh
devenv test
devenv tasks run maintenance:check
devenv tasks run maintenance:fix
```

Cross-repository selection and ordering are provided by Stitch. Stitch does not define repository-specific checks.
""",
    "AGENTS.md": """# Agent guidance

1. Read the owning repository's guidance, `maintenance.nix`, and `.stitch.json` before changing code.
2. Keep repository-specific verification local to `maintenance.nix`.
3. Use `devenv test` for the complete read-only repository gate.
4. Use Stitch only for workspace discovery, closure selection, ordering, and generic command execution.
5. Update providers before consumers and regenerate consumer lock files after provider merges.
6. Do not commit logs, result links, caches, local devenv state, temporary workflows, or generated diagnostics.
7. The root repository must remain aggregation-only.
""",
    "ROADMAP.md": """# Roadmap

## Complete

- Standalone, package-scoped repository maintenance.
- Scoped Stitch graph and ordered-execution core.
- Thin tools aggregation.
- Provider-first flake topology with validated host configurations.
- Root workspace reduced to aggregation and re-exports.

## Next

- Continue refining agent session and workflow APIs.
- Expand deterministic repository checks where they provide concrete value.
- Keep documentation and lock graphs synchronized with merged provider contracts.
""",
    "docs/README.md": """# Phenix documentation

- [Repository goals](repo-goals.md)
- [Flake topology](architecture/flake-topology.md)
- [Standalone maintenance](check-execution-model.md)
- [Verification](verification.md)
- [Stitch](stitch.md)
- [Agent workflow](agent-workflow.md)
- [Tool routing](agents/tool-routing.md)
- [Generated flakes](generated-flake-workflow.md)
- [Git and Jujutsu policy](workflow/git-jj-policy.md)
""",
    "docs/repo-goals.md": """# Repository goals

- Each repository owns its implementation and local verification contract.
- Maintenance commands declare their runtime dependencies beside their implementation.
- The project flake remains independent from standalone devenv.
- Stitch coordinates repositories but does not know how a repository is maintained.
- Aggregator repositories contain no duplicate implementation.
- Git history preserves removed designs; active trees contain only the current design.
""",
    "docs/check-execution-model.md": """# Standalone maintenance model

Every active repository has a `devenv.nix` that discovers local `maintenance.nix` modules.

A maintenance script declares the packages available only while that command runs. Tasks compose those scripts into `maintenance:check`, `maintenance:fix`, and `devenv:enterTest`.

The project flake remains an ordinary flake. `nix flake check` is one maintenance command rather than the host for the maintenance framework.
""",
    "docs/verification.md": """# Verification

For one repository:

```sh
devenv test
```

For selected repositories in dependency order:

```sh
stitch exec --changed --closure downstream --order providers-first -- devenv test
```

CI is read-only. Mutating formatting and safe cleanup run through `devenv tasks run maintenance:fix` before review, never inside the final CI gate.
""",
    "docs/testing.md": """# Testing

Tests are repository-local maintenance tasks with package-scoped dependencies.

Typical task groups include formatting, static analysis, compilation, unit tests, runtime smoke tests, flake checks, and concrete host evaluation. The exact set is owned by the repository that understands the implementation.

The authoritative command is `devenv test`.
""",
    "docs/stitch.md": """# Stitch

Stitch derives and validates the workspace graph, selects dependency closures, computes deterministic order, reports repository status, and executes a caller-provided command in each selected repository.

Canonical graph edges point from consumer to provider. `providers-first` reverses those edges for execution.

Stitch does not commit, push, install hooks, define checks, or interpret maintenance profiles.
""",
    "docs/agent-workflow.md": """# Agent workflow

1. Discover the owning repository and read its guidance.
2. Use a scout only when exploration would add substantial irrelevant context to the main session.
3. Implement within the repository's public architecture.
4. Run the narrow relevant maintenance task while iterating.
5. Run `devenv test` before publishing.
6. Merge providers before consumers and refresh consumer locks.
7. Use Stitch when the same command must run across a selected repository closure.
""",
    "docs/agents/tool-routing.md": """# Tool routing

| Need | Tool |
| --- | --- |
| Repository checks or fixes | standalone devenv tasks |
| Workspace graph, selection, and ordering | Stitch |
| GitHub review and merge operations | `gh` or GitHub integration |
| Nix package and system evaluation | Nix commands exposed by maintenance tasks |
| Agent runtime and workflow sessions | Phenix agent harness |

Do not duplicate repository checks in Stitch or the root workspace.
""",
    "docs/architecture/flake-topology.md": """# Flake topology

The graph is provider-first by layer:

1. `phenix-pins`
2. package producers, shell conventions, and scoped Stitch
3. tools aggregation, desktop environment, editor configuration, and agent harness
4. host configurations
5. root aggregation

Consumers follow provider inputs so one root lock graph selects compatible revisions. Repositories still retain independently valid flakes and maintenance gates.
""",
    "docs/mcp/contracts.md": """# MCP contracts

The active MCP surfaces are read-only planning and status capabilities unless a contract explicitly authorizes a mutation.

Stitch MCP exposes workspace discovery, graph validation, closure planning, and ordering. Repository verification is invoked as an ordinary command and remains defined by the repository.

Agent-harness workflow tools derive allowed child roles and transitions from the active contract.
""",
    "docs/generated-flake-workflow.md": """# Generated flake workflow

Repositories using `flake-file` keep input declarations in their source module and regenerate `flake.nix` with:

```sh
nix run .#write-flake
```

After provider changes, regenerate the flake, update `flake.lock`, run `devenv test`, and commit only canonical source, generated flake, and lock changes. Temporary logs and result links remain untracked.
""",
    "docs/guardrails.md": """# Guardrails

- No repository may depend on a retired implementation.
- No temporary workflow, diagnostic log, result link, cache, or local state belongs in Git.
- The root and tools repositories remain aggregation-only.
- Stitch remains unaware of repository-specific maintenance semantics.
- CI must be reproducible and read-only.
- Provider changes propagate through consumer locks only after provider validation.
""",
    "docs/migration.md": """# Current migration state

The workspace now uses standalone devenv maintenance and scoped Stitch coordination.

Legacy task-runner configuration, duplicate tools implementations, lifecycle commands in Stitch, and root implementation wrappers were removed. Their history remains available in Git.

All active inputs point at merged provider branches and the root lock is the final compatibility snapshot.
""",
    "docs/phenix/Phenix Migration Plan.md": """# Phenix migration plan

The repository split is complete:

- providers own reusable packages and modules;
- integrations compose provider contracts;
- hosts own concrete system configurations;
- the root owns aggregation and compatibility pinning;
- standalone maintenance remains local;
- Stitch coordinates workspace order without absorbing repository semantics.
""",
    "docs/pi.md": """# Pi integration

The Phenix agent harness packages Pi, injects Phenix-managed workflow guidance, and exposes contract-bound session and delegation tools.

Repository verification is requested through the owning repository's standalone maintenance commands. Multi-repository verification uses Stitch to invoke those commands in a deterministic order.
""",
    "docs/workflow/git-jj-policy.md": """# Git and Jujutsu policy

- Keep `main` valid.
- Work in focused changes and reviewable pull requests.
- Run the owning repository's complete maintenance gate before merge.
- Merge providers before updating consumer locks.
- Avoid force operations unless explicitly required and reviewed.
- Do not commit generated diagnostics, caches, or temporary automation.
""",
    "docs/workflow/workspace-state.md": """# Workspace state

A valid workspace state has:

- clean repository worktrees;
- valid canonical graph metadata;
- provider revisions reflected in consumer lock files;
- passing repository-local maintenance gates;
- passing concrete host evaluation;
- no temporary or retired artifacts in tracked trees.
""",
    "docs/workflows/agent-check-flow.md": """# Agent check flow

```text
inspect scope
  -> run narrow maintenance task
  -> implement and format
  -> run repository `devenv test`
  -> use Stitch for affected consumer/provider closure when required
  -> publish focused PR
```

Check definitions remain local and deterministic.
""",
    "docs/workflows/permission-model.md": """# Permission model

Read-only agents may inspect files, query the workspace graph, plan closures, and run read-only maintenance checks.

Workers may edit within their assignment and run safe formatting tasks. Commits, pushes, lock updates, and destructive Git operations require the permissions granted by the active workflow contract.
""",
}

for name, content in documents.items():
    path = Path(name)
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(content.strip() + "\n")
