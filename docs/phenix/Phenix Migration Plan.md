# Phenix migration plan

The repository split is complete:

- providers own reusable packages and modules;
- integrations compose provider contracts;
- hosts own concrete system configurations;
- the root owns aggregation and compatibility pinning;
- standalone maintenance remains local;
- Stitch coordinates workspace order without absorbing repository semantics.
