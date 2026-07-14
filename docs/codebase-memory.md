---
title: codebase-memory
type: note
permalink: phenix/codebase-memory
---

# Codebase memory

A codebase-memory MCP service may be attached to the Pi runtime to provide a cheap
structural overview before expensive file-by-file exploration.

It is most useful for architecture discovery, dependency analysis, impact analysis,
structural search, and identifying ownership boundaries. Direct file reading remains
preferable for small, local changes.

Planners and architects should use codebase memory for broad changes. Verifiers should
use it when checking dependency direction, public API drift, circular coupling risk, or
whether a final diff remained within the accepted scope.
