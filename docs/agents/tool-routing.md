# Tool routing

| Need | Tool |
| --- | --- |
| Repository checks or fixes | standalone devenv tasks |
| Workspace graph, selection, and ordering | Stitch |
| GitHub review and merge operations | `gh` or GitHub integration |
| Nix package and system evaluation | Nix commands exposed by maintenance tasks |
| Agent runtime and workflow sessions | Phenix agent harness |

Do not duplicate repository checks in Stitch or the root workspace.
