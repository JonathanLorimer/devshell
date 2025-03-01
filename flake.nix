{
  description = "devshell";
  # To update all inputs:
  # $ nix flake update --recreate-lock-file
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = inputs:
    inputs.flake-utils.lib.eachSystem [
      "aarch64-darwin"
      "aarch64-linux"
      "i686-linux"
      "x86_64-darwin"
      "x86_64-linux"
    ] (system:
      let
        pkgs = import inputs.self {
          inherit system;
          inputs = null;
          nixpkgs = inputs.nixpkgs.legacyPackages.${system};
        };
      in
      {
        defaultPackage = pkgs.cli;
        legacyPackages = pkgs;
        devShell = pkgs.fromTOML ./devshell.toml;
      }
    ) // {
      defaultTemplate.path = ./template;
      defaultTemplate.description = "nix flake new 'github:numtide/devshell'";
      # Import this overlay into your instance of nixpkgs
      overlay = import ./overlay.nix;
      lib = {
        importTOML = import ./nix/importTOML.nix;
        mkShell = (import ./. { inherit inputs system; }).mkShell;
      };
    };
}
