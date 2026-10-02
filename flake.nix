{
  description = "Minecraft tools web store with Go, Revel and Webix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    git-hooks.url = "github:cachix/git-hooks.nix";
    git-hooks.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    nixpkgs,
    flake-utils,
    git-hooks,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};

        offlineHooks = {
          alejandra.enable = true;

          statix.enable = true;

          deadnix.enable = true;

          yamllint = {
            enable = true;
            settings.configPath = "./.yamllint.yml";
          };

          golangci-lint.enable = true;
        };

        preCommit = git-hooks.lib.${system}.run {
          src = ./.;
          hooks = offlineHooks;
        };
      in {
        checks = {
          pre-commit-check = preCommit;
        };

        devShells.default = pkgs.mkShell {
          inherit (preCommit) shellHook;

          packages = with pkgs; [
            # Go
            go_1_27
            gopls
            delve
            gofumpt
            goimports-reviser
            govulncheck
            golangci-lint

            # Frontend
            nodejs

            # Git
            git

            # Nix
            alejandra
            statix
            deadnix

            # YAML
            yamllint
          ];
        };
      }
    );
}
