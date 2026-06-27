# Codebase Memory MCP

This repository configures `codebase-memory-mcp` as a local OpenCode MCP server.

## Purpose

Use it to give agents a cheap structural overview of the codebase before they do expensive or noisy file-by-file exploration.

It is especially useful for:

- architecture overview
- module/package discovery
- call graph and dependency investigation
- impact analysis of uncommitted diffs
- dead-code checks
- structural search
- cross-file relationship discovery
- finding likely ownership boundaries

## Usage rules

Agents should use `codebase_memory` tools when:

- planning a change that touches multiple modules;
- checking whether a plan preserves architecture;
- verifying whether a final diff matches the accepted plan;
- diagnosing failures that may be caused by cross-module interactions;
- looking for entry points, boundaries, or dependency direction.

Agents should not use it when:

- the task is a tiny one-file edit;
- direct file reading is cheaper;
- the answer is already explicit in the provided context.

## Required agent behavior

The planner should use codebase memory before creating a broad implementation plan.

The architect should use codebase memory when checking dependency direction, module boundaries, architecture consistency, or impact radius.

The verifier should use codebase memory for post-implementation architecture verification.

The failure analyzer should use codebase memory when failures imply cross-module or architectural causes.

The implementer may use codebase memory for navigation, but must not use it as permission to broaden scope.

## Architecture verification checklist

The verifier should use codebase memory, git diff, and repo docs to check:

- Did the implementation stay within the accepted plan?
- Did dependency direction remain valid?
- Were new edges introduced between layers/modules?
- Were public APIs changed intentionally and documented?
- Did the diff create circular coupling risk?
- Did the implementation bypass intended provider/consumer boundaries?
- Did tests/docs drift from implementation?
- Did it add brittle tests that freeze incidental layout?
- Did it remove useful verification?
