{
  description = "LA-Mesh - LoRa mesh network infrastructure for southern Maine";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    flake-utils.url = "github:numtide/flake-utils";

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, treefmt-nix }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };

        treefmtEval = treefmt-nix.lib.evalModule pkgs {
          projectRootFile = "flake.nix";
          programs = {
            nixpkgs-fmt.enable = true;
            prettier.enable = true;
            shfmt.enable = true;
          };
        };

        bazelWrapper = pkgs.writeShellScriptBin "bazel" ''
          exec ${pkgs.bazelisk}/bin/bazelisk "$@"
        '';

        meshtasticPython = pkgs.python3.withPackages (ps: with ps; [
          meshtastic
          packaging
          pyserial
          protobuf
          pyyaml
          requests
          tabulate
        ]);

        devTools = with pkgs; [
          # Meshtastic / LoRa
          meshtasticPython
          esptool

          # SDR / RF Analysis
          hackrf
          rtl-sdr

          # Build Tooling
          bazel-buildtools
          bazelisk
          bazelWrapper
          just
          git-cliff

          # Node.js / SvelteKit
          nodejs_22
          nodePackages.pnpm

          # Nix Tooling
          nixpkgs-fmt
          statix
          deadnix

          # Development Utilities
          jq
          yq-go
          direnv
          nix-direnv
          git
          gh
        ];

      in
      {
        devShells.default = pkgs.mkShell {
          name = "la-mesh-dev";
          packages = devTools;

          shellHook = ''
            echo "LA-Mesh Development Environment"
            echo "================================"
            echo ""
            echo "Available tools:"
            echo "  meshtastic         - Meshtastic CLI"
            echo "  esptool            - ESP32 flash tool"
            echo "  hackrf_transfer    - HackRF tools"
            echo "  just               - Task runner (run 'just' for commands)"
            echo "  bazel              - Build system (via bazelisk)"
            echo ""

            if command -v direnv &> /dev/null; then
              eval "$(direnv hook bash 2>/dev/null || direnv hook zsh 2>/dev/null || true)"
            fi
          '';
        };

        devShells.ci = pkgs.mkShell {
          name = "la-mesh-ci";
          packages = with pkgs; [
            bazel-buildtools
            bazelisk
            bazelWrapper
            nodejs_22
            nodePackages.pnpm
            just
            git
          ];
        };

        checks = {
          formatting = treefmtEval.config.build.check self;
        };

        formatter = treefmtEval.config.build.wrapper;
      }
    );
}
