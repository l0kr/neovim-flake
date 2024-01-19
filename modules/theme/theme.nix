{ pkgs, config, lib, ... }:

with lib;
with builtins;

let
  cfg = config.vim.theme;

  enum' = name: flavors: other:
    if (cfg.name == name) then types.enum flavors else other;
in
{
  options.vim.theme = {
    enable = mkOption {
      type = types.bool;
      description = "Enable Theme";
    };

    name = mkOption {
      type = types.enum [ "catppuccin" "nightfox" "onedark" "rose-pine" "tokyonight" ];
      default = "onedark";
      description = ''Name of theme to use: "catppuccin" "nightfox" "onedark" "rose-pine" "tokyonight"'';
    };

    style = mkOption {
      type =
        let
          tn = enum' "tokyonight" [ "day" "night" "storm" ];
          od = enum' "onedark" [ "dark" "darker" "cool" "deep" "warm" "warmer" ];
          nf = enum' "nightfox" [ "nightfox" "carbonfox" "duskfox" "terafox" "nordfox" ];
          rp = enum' "rose-pine" [ "main" "moon" "dawn" ];
          cp = types.enum [ "frappe" "latte" "macchiato" "mocha" ];
        in
        tn (od (nf (rp cp)));
      description = ''Theme style: "storm", darker variant "night", and "day"'';
    };

    transparency = mkOption {
      type = types.bool;
      description = "Background transparency";
    };
  };

  config = mkIf cfg.enable (
    let
      transparency = builtins.toString cfg.transparency;
    in
    {
      vim.configRC = mkIf (cfg.name == "nightfox") ''
        " need to set style before colorscheme to apply
        " let g:monotone_color = [120, 100, 70] " Sets theme color to bright green
        let g:monotone_secondary_hue_offset = 320 " Offset secondary colors by 200 degrees
        let g:monotone_emphasize_comments = 1 " Emphasize comments
      '';

      vim.startPlugins = with pkgs.neovimPlugins; (
        (withPlugins (cfg.name == "nightfox") [ nightfox monotone]) ++
        (withPlugins (cfg.name == "onedark") [ onedark ]) ++
        (withPlugins (cfg.name == "tokyonight") [ tokyonight ]) ++
        (withPlugins (cfg.name == "rose-pine") [ rosepine ]) ++
        (withPlugins (cfg.name == "catppuccin") [ catppuccin ])
      );

      vim.luaConfigRC = ''
        ${writeIf (cfg.name == "nightfox") ''
          -- nightfox theme
          require('nightfox').setup {
            options = {
              style = "${cfg.style}",
              transparent = "${transparency}",
            }
          }
          vim.cmd("colorscheme ${cfg.style}")
        ''
        }

        ${writeIf (cfg.name == "onedark") ''
          -- OneDark theme
          require('onedark').setup {
            style = "${cfg.style}",
            transparent = "${transparency}",
          }
          require('onedark').load()
        ''
        }

        ${writeIf (cfg.name == "tokyonight") ''
          vim.cmd("colorscheme ${cfg.style}")
        ''
        }


        ${writeIf (cfg.name == "catppuccin") ''
          vim.g.catppuccin_flavour = "${cfg.style}"
          require("catppuccin").setup({
            transparent_background = ${if cfg.transparency then "true" else "false"},
          })
          vim.cmd [[colorscheme retrobox]]
        ''
        }

        ${writeIf (cfg.name == "rose-pine") ''
          -- Rose Pine theme
          require('rose-pine').setup {
            darkvariant = "${cfg.style}",
            dim_nc_background = "${transparency}",
          }
          vim.cmd [[colorscheme rose-pine]]
        ''
        }
      '';
    }
  );
}
