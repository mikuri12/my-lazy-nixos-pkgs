{
  description = "My Lazy pkgs waaa";

  nixConfig = {
    extra-substituters = ["https://lazypkgs.cachix.org"];
    extra-trusted-public-keys = ["lazypkgs.cachix.org-1:Mn0OWulKkV//wpMp0bKHLdYstCa+L8Vh+W6ccQuHNPM="];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    systems.url = "github:nix-systems/default";
  };

  outputs = {
    self,
    nixpkgs,
    systems,
    ...
  }: let
    inherit (nixpkgs) lib;

    pkgsDir = builtins.readDir ./pkgs;
    dirs = builtins.filter (
      name:
        pkgsDir.${name}
        == "directory"
        && builtins.hasAttr "package.nix" (builtins.readDir (./pkgs/${name}))
    ) (builtins.attrNames pkgsDir);

    buildPackages = pkgs:
      lib.genAttrs dirs (name: pkgs.callPackage (./pkgs/${name}/package.nix) {});

    eachSystem = fn:
      lib.genAttrs (import systems) (
        system:
          fn (import nixpkgs {
            inherit system;
            config = {
              allowUnfreePredicate = pkg:
                builtins.elem (pkg.pname or "") [
                  "spotiflac"
                  "easytether"
                  "helium"
                ];
              permittedInsecurePackages = [
                "openssl-1.1.1w"
              ];
            };
          })
      );
  in {
    overlays.default = final: prev: buildPackages prev;

    nixosModules = {
      easytether = import ./modules/easytether.nix self;
      default = {imports = [self.nixosModules.easytether];};
    };

    packages = eachSystem buildPackages;

    formatter = eachSystem (pkgs: pkgs.alejandra);

    devShells = eachSystem (pkgs: {
      default = pkgs.mkShell {
        buildInputs = [pkgs.alejandra pkgs.git];
      };
    });
  };
}
