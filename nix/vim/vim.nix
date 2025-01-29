{ inputs, ... }:
{
  perSystem =
    {
      config,
      pkgs,
      system,
      ...
    }:
    let
      my_plugins = import ./vimplugins/plugins.nix { inherit (pkgs) vimUtils fetchFromGitHub; };
      nvim = inputs.nixvim.legacyPackages.${system}.makeNixvim {
        vimAlias = true;
        plugins = {
          lightline.enable = true;
          conform-nvim = {
            enable = true;
            #logLevel = "debug";
            settings = {
              formatters.treefmt = {
                command = "treefmt";
                args = [
                  "--walk=filesystem" # Without this, treefmt will ignore the temporary file, since it is not found in git index
                  "$FILENAME"
                ];
                stdin = false;
              };
              formatters_by_ft = {
                "*" = [ "treefmt" ];
              };
              format_on_save = {
                timeout_ms = 1000;
                lsp_fallback = false;
              };
            };
          };
        };
        extraConfigVim = builtins.readFile ./vimrc;
        extraPlugins = with pkgs.vimPlugins // my_plugins; [
          colemak
          NeoSolarized
        ];
      };
    in
    {
      packages.mynvim = nvim;
    };
}
