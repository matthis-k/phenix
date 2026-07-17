# Flake topology

The graph is provider-first by layer:

1. `phenix-pins`
2. package producers, shell conventions, and scoped Stitch
3. tools aggregation, desktop environment, editor configuration, and agent harness
4. host configurations
5. root aggregation

Consumers follow provider inputs so one root lock graph selects compatible revisions. Repositories still retain independently valid flakes and maintenance gates.
