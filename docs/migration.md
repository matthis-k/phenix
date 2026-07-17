# Current migration state

The workspace now uses standalone devenv maintenance and scoped Stitch coordination.

Legacy task-runner configuration, duplicate tools implementations, lifecycle commands in Stitch, and root implementation wrappers were removed. Their history remains available in Git.

All active inputs point at merged provider branches and the root lock is the final compatibility snapshot.
