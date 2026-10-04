{
  description = "Minecraft tools web store with Go, Revel and Webix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    nixpkgs-go120.url = "github:NixOS/nixpkgs/nixos-23.11";
    flake-utils.url = "github:numtide/flake-utils";
    git-hooks.url = "github:cachix/git-hooks.nix";
    git-hooks.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    nixpkgs,
    nixpkgs-go120,
    flake-utils,
    git-hooks,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
        pkgs-go120 = nixpkgs-go120.legacyPackages.${system};

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
            pkgs-go120.go_1_20
            pkgs.gopls
            pkgs.delve
            pkgs.gofumpt
            pkgs.goimports-reviser
            pkgs.govulncheck
            pkgs.golangci-lint

            # Frontend
            pkgs.nodejs

            # Git
            pkgs.git

            # Nix
            pkgs.alejandra
            pkgs.statix
            pkgs.deadnix

            # YAML
            pkgs.yamllint
          ];
        };
      }
    );
}
