{ lib, inputs, ... }: let
  inherit (lib) types;
  compose = lib.foldr lib.composeExtensions (self: super: { });
in {
  perSystem = { config, pkgs, system, ... }: {
    options.phenix = {
      overlays = lib.mkOption {
        type = types.listOf types.raw;
        default = [];
        description = "List of overlays contributed by phenix subflakes";
      };

      mcp = {
        useDevBinaries = lib.mkOption {
          type = types.bool;
          default = false;
          description = ''
            Use local debug binaries for MCP servers instead of Nix store paths.
            When true, commands point to ./phenix-tools/target/debug/ binaries.
            When false (default), commands point to Nix store paths.
          '';
        };
      };
    };

    config = let
      merged = pkgs.extend (compose config.phenix.overlays);

      phenixToolsPkgs = inputs.phenix-tools.packages.${system};

      mkMcpServer = name: pkgAttr: {
        type = "local";
        command = if config.phenix.mcp.useDevBinaries
          then [ "./phenix-tools/target/debug/${name}" ]
          else [ "${phenixToolsPkgs."${pkgAttr}"}/bin/${name}" ];
        enabled = true;
      };

      mcpConfigJson = builtins.toJSON {
        "$schema" = "https://opencode.ai/config.json";
        mcp = {
          "tend-mcp" = mkMcpServer "tend-mcp" "tend-mcp";
          "stitch-mcp" = mkMcpServer "stitch-mcp" "stitch-mcp";
        };
      };

      mcpConfigFile = pkgs.writeText "opencode.json" mcpConfigJson;
    in {
      _module.args.phenixPackages = merged;

      packages = (lib.mapAttrs' (name: value: {
        name = "phenix-${name}";
        value = value;
      }) (merged.phenix or { })) // {
        mcp-config = mcpConfigFile;
      };

      checks = lib.optionalAttrs (!config.phenix.mcp.useDevBinaries) {
        mcp-config-check = pkgs.runCommand "mcp-config-check" {
          nativeBuildInputs = [ pkgs.jq ];
          mcpConfig = mcpConfigFile;
        } ''
          configContent=$(cat "$mcpConfig")

          # Check 1: stitch-mcp command contains /nix/store/
          echo "$configContent" | jq -e '.mcp["stitch-mcp"].command[0] | contains("/nix/store/")' > /dev/null || {
            echo "FAIL [1/5]: stitch-mcp command must contain /nix/store/"
            echo "  got: $(echo "$configContent" | jq -r '.mcp["stitch-mcp"].command[0]')"
            exit 1
          }

          # Check 2: tend-mcp command contains /nix/store/
          echo "$configContent" | jq -e '.mcp["tend-mcp"].command[0] | contains("/nix/store/")' > /dev/null || {
            echo "FAIL [2/5]: tend-mcp command must contain /nix/store/"
            echo "  got: $(echo "$configContent" | jq -r '.mcp["tend-mcp"].command[0]')"
            exit 1
          }

          # Check 3: neither command contains target/debug
          echo "$configContent" | jq -e '.mcp["stitch-mcp"].command[0] | contains("target/debug") | not' > /dev/null || {
            echo "FAIL [3/5]: stitch-mcp command must not contain target/debug"
            exit 1
          }
          echo "$configContent" | jq -e '.mcp["tend-mcp"].command[0] | contains("target/debug") | not' > /dev/null || {
            echo "FAIL [3/5]: tend-mcp command must not contain target/debug"
            exit 1
          }

          # Check 4: neither command starts with ./
          echo "$configContent" | jq -e '.mcp["stitch-mcp"].command[0] | startswith("./") | not' > /dev/null || {
            echo "FAIL [4/5]: stitch-mcp command must not start with ./"
            exit 1
          }
          echo "$configContent" | jq -e '.mcp["tend-mcp"].command[0] | startswith("./") | not' > /dev/null || {
            echo "FAIL [4/5]: tend-mcp command must not start with ./"
            exit 1
          }

          # Check 5: both referenced binaries exist in the built closure
          stitchMcpCmd=$(echo "$configContent" | jq -r '.mcp["stitch-mcp"].command[0]')
          tendMcpCmd=$(echo "$configContent" | jq -r '.mcp["tend-mcp"].command[0]')

          test -x "$stitchMcpCmd" || {
            echo "FAIL [5/5]: stitch-mcp binary not found at $stitchMcpCmd"
            exit 1
          }
          test -x "$tendMcpCmd" || {
            echo "FAIL [5/5]: tend-mcp binary not found at $tendMcpCmd"
            exit 1
          }

          echo "PASS: All 5 MCP config checks passed"
          echo "  stitch-mcp: $stitchMcpCmd"
          echo "  tend-mcp:   $tendMcpCmd"
          cp "$mcpConfig" "$out"
        '';
      };
    };
  };
}
