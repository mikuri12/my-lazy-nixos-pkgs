# my-lazy-nixos-pkgs

A small personal collection of Nix packages for NixOS, exposed as a flake.
Mostly AppImages and prebuilt binaries wrapped properly for NixOS, plus a few
things built from source.

The flake provides:

- `packages.<system>.*` - every package, buildable directly
- `overlays.default` - adds all packages to `pkgs`
- `nixosModules.easytether` - a service module for EasyTether
- `formatter.<system>` - `alejandra`
- `devShells.<system>.default` - shell with `alejandra` and `git`

Supported system: `x86_64-linux` (some packages are Linux/x86_64 only).

## Packages

| Attribute             | License   | Description |
|-----------------------|-----------|-------------|
| `cmuspp`              | MIT       | Small, fast C++17 terminal music player (built from source) |
| `meowfetch`           | MIT       | Minimal system information fetcher written in Go |
| `hayase`              | GPL-3.0   | Torrent streaming client for anime (AppImage) |
| `helium`              | unfree    | Private web browser based on Chromium (AppImage) |
| `eden-emu`            | GPL-3.0+  | Nintendo Switch emulator, stable build (AppImage) |
| `eden-emu-nightly`    | GPL-3.0+  | Nintendo Switch emulator, nightly PGO build (AppImage) |
| `spotiflac`           | unfree    | Download Spotify tracks in FLAC format (AppImage) |
| `easytether`          | unfree    | Share an Android internet connection over USB or Bluetooth |
| `hatsune-miku-cursor` | free      | Hatsune Miku X11 cursor theme |

Unfree packages: `helium`, `spotiflac`, `easytether`.
`easytether` also needs the insecure `openssl-1.1.1w` allowed (see below).

## Try a package without installing

```sh
nix run github:mikuri12/my-lazy-nixos-pkgs#meowfetch
nix shell github:mikuri12/my-lazy-nixos-pkgs#cmuspp
```

For unfree packages you need to allow unfree first:

```sh
NIXPKGS_ALLOW_UNFREE=1 nix run --impure github:mikuri12/my-lazy-nixos-pkgs#helium
```

## Use it in your NixOS configuration

Add the flake as an input.

```nix
# flake.nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    mlnp.url = "github:mikuri12/my-lazy-nixos-pkgs";
  };

  outputs = { nixpkgs, mlnp, ... }: {
    nixosConfigurations.myhost = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ ./configuration.nix ];
      specialArgs = { inherit mlnp; };
    };
  };
}
```

### Option A: the overlay (recommended)

Adds every package to `pkgs`, so you use them like any other package.

```nix
# configuration.nix
{ pkgs, mlnp, ... }:
{
  nixpkgs.overlays = [ mlnp.overlays.default ];

  environment.systemPackages = [
    pkgs.meowfetch
    pkgs.hayase
    pkgs.eden-emu
  ];
}
```

### Option B: reference packages directly

Without the overlay, pull packages from the flake output.

```nix
# configuration.nix
{ mlnp, pkgs, ... }:
{
  environment.systemPackages = [
    mlnp.packages.${pkgs.system}.meowfetch
  ];
}
```

### Allowing unfree and insecure packages

If you use any unfree package, or `easytether`:

```nix
{
  nixpkgs.config.allowUnfree = true;
  # Only needed for easytether:
  nixpkgs.config.permittedInsecurePackages = [ "openssl-1.1.1w" ];
}
```

## EasyTether service

EasyTether is wrapped as a NixOS module so you do not configure ports or run
the daemon by hand. With the module enabled, plugging the phone in over USB
(with USB tethering turned on in Android) starts the daemon automatically
through a udev rule.

```nix
# configuration.nix
{ mlnp, ... }:
{
  imports = [ mlnp.nixosModules.easytether ];

  services.easytether.enable = true;
  nixpkgs.config.permittedInsecurePackages = [ "openssl-1.1.1w" ];
}
```

After the phone is connected, the daemon creates a network interface
(usually `tap-easytether`). You still need to get an IP on it, for example
with DHCP, depending on your network setup.

Options:

- `services.easytether.enable` - enable the service.
- `services.easytether.package` - the package to use (defaults to this
  flake's `easytether`).

## Updating

Most packages update automatically through GitHub Actions:

- `.github/workflows/update.yml` runs weekly. It uses `nix-update` on the
  packages whose versions can be discovered from GitHub (`cmuspp`,
  `meowfetch`, `helium`, `spotiflac`) and opens a pull request with the bumps.
- `.github/workflows/update-rolling.yml` runs daily for the rolling sources
  whose host only serves the latest version (`eden-emu-nightly` and `hayase`).
  Eden's nightly URL changes on every build, and Hayase's download host drops
  old versions, so `nix-update` cannot follow them. The scripts
  `scripts/update-eden-nightly.sh` and `scripts/update-hayase.sh` read the
  latest version, rebuild the download URL and refresh the hash, then open a
  pull request.

For the pull requests to be created, the repository must allow GitHub Actions
to open them: Settings -> Actions -> General -> Workflow permissions ->
"Read and write permissions" and "Allow GitHub Actions to create and approve
pull requests".

You can also run the nightly updater locally:

```sh
bash scripts/update-eden-nightly.sh
```

The remaining packages (`eden-emu` stable, `easytether`,
`hatsune-miku-cursor`) use their own hosting and are updated by hand.

## Binary cache

Some packages are built from source (`cmuspp`, `meowfetch`). To avoid
rebuilding them on every machine, CI builds every package and pushes the
results to a [Cachix](https://cachix.org) binary cache.

The flake declares the cache in `nixConfig`, so when you use this flake as an
input the cache is offered automatically (you may be asked to accept it, or
pass `--accept-flake-config`).

The cache is `lazypkgs` and both `flake.nix` and
`.github/workflows/build.yml` are already configured for it.

The only remaining step is the push token: in the cache settings on
cachix.org create an auth token, then add it to the repository as a secret
named `CACHIX_AUTH_TOKEN` (Settings -> Secrets and variables -> Actions).

After that, every push to `main` builds the packages and uploads them.

### Using the cache without the flake input

If you install a package with `nix run`/`nix profile` instead of as a flake
input, add the cache manually:

```nix
{
  nix.settings = {
    substituters = [ "https://lazypkgs.cachix.org" ];
    trusted-public-keys = [ "lazypkgs.cachix.org-1:Mn0OWulKkV//wpMp0bKHLdYstCa+L8Vh+W6ccQuHNPM=" ];
  };
}
```

## Development

```sh
nix develop          # shell with alejandra and git
nix fmt              # format all Nix files with alejandra
nix flake show       # list all outputs
nix build .#cmuspp   # build a single package
```

Nix code is formatted with [alejandra](https://github.com/kamadorueda/alejandra).
Comments in the package files are in Spanish.

## Repository layout

```
flake.nix                       Flake inputs and outputs
lib/appimage-extras.nix         Shared helper: installs icons and .desktop
                                entries from extracted AppImages
modules/easytether.nix          NixOS service module for EasyTether
pkgs/<name>/package.nix         One directory per package
scripts/                        Updaters for rolling sources (eden-nightly, hayase)
.github/workflows/              Auto-update and build-and-cache workflows
```

## Notes

- The Eden AppImages use `uruntime` with a `dwarfs` filesystem instead of
  squashfs, so the usual `appimageTools.wrapType2` cannot extract them. They
  are unpacked with `dwarfsextract` and then wrapped with
  `appimageTools.wrapAppImage`.
- These are personal packages with no stability guarantees.
