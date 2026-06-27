self: {
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.easytether;
in {
  options.services.easytether = {
    enable = lib.mkEnableOption "EasyTether USB tethering (auto-arranca al conectar el teléfono por USB)";

    package = lib.mkOption {
      type = lib.types.package;
      default = self.packages.${pkgs.stdenv.hostPlatform.system}.easytether;
      defaultText = lib.literalExpression "mlnp.packages.\${system}.easytether";
      description = "Paquete easytether a usar.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [cfg.package];

    services.udev.packages = [cfg.package];

    systemd.packages = [cfg.package];
  };
}
