#!/usr/bin/env bash
set -euo pipefail

nix flake lock --update-input phenix-agent-harness
nix profile add nixpkgs#devenv
devenv test

rm -f \
  .github/workflows/propagate-pi.yml \
  scripts/propagate-pi-0.80.10.sh

git config user.name github-actions[bot]
git config user.email 41898282+github-actions[bot]@users.noreply.github.com
git add -A
git commit -m "fix: propagate Pi 0.80.10 runtime"
git push origin HEAD:fix/propagate-pi-0.80.10
