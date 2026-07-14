---
title: repo-goals
type: note
permalink: phenix/repo-goals
---

# Repo Goals

## Primary purpose

This repository is the root Phenix workspace. It aggregates Phenix flakes as remote locked inputs and may map them to local developer checkouts via Stitch workspace state.

Root-level actions are workspace actions. They may inspect, verify, commit, push, or synchronize multiple repos together through Stitch.

## Architecture invariants

1. Submodules are consumed through flake inputs with pinned follow dependencies.
2. Root-level verification uses `tend` (not ad hoc scripts).
3. Multi-repo Git operations use `stitch` (not raw `git commit`/`git push` across repos).
4. Verification must account for root files, dirty/staged files inside local workspace repos, and affected downstream DAG nodes.
5. Direct work inside a workspace repo must pass that repo's local verification.

## Agent workflow goals

- All implementation follows a structured plan approved by architecture review.
- All changes pass both mechanical and architectural verification before completion.
- Architecture is checked both pre-implementation (plan review) and post-implementation (diff review).
- Codebase memory tools provide cheap structural context to reduce brute-force file reading.
