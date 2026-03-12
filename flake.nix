{
  description = "My Lazy pkgs waaa";

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
    eachSystem = fn:
      nixpkgs.lib.genAttrs
      (import systems)
      (system: fn (import nixpkgs {
        inherit system;
        config.allowUnfreePredicate = pkg: builtins.elem (pkg.pname or "") [
          "spotiflac"
          "easytether"
        ];
         permittedInsecurePackages = [
            "openssl-1.1.1w"
        ];
      }));

    pkgsDir = builtins.readDir ./pkgs;
    dirs = builtins.filter (
      name:
        pkgsDir.${name} == "directory"
        && builtins.hasAttr "package.nix" (builtins.readDir (./pkgs/${name}))
    ) (builtins.attrNames pkgsDir);
  in {
    packages =
      eachSystem (pkgs:
        pkgs.lib.genAttrs dirs (name:
          pkgs.callPackage (./pkgs/${name}/package.nix) {}));

    formatter = eachSystem (pkgs: pkgs.alejandra);

    devShells = eachSystem (pkgs: {
      default = pkgs.mkShell {
        buildInputs = [pkgs.alejandra pkgs.git];
      };
    });
  };
}
