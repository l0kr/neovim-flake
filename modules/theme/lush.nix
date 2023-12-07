{ pkgs, lib, config, ... }:

with lib;

let
  cfg = config.vim.lush;
in
{
  options.vim.lush = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "enable lush plugin";
    };

    type = mkOption {
      default = "lush";
      description = "Lush";
      type = types.enum [ "lush"];
    };
  };

  config = mkIf cfg.enable {
    vim.startPlugins = [ pkgs.neovimPlugins.${cfg.type} ];
  };
}
