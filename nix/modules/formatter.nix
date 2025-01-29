{ inputs, ... }:
{
  imports = [
    inputs.treefmt-nix.flakeModule
  ];
  perSystem =
    { config, pkgs, ... }:
    {
      # Auto formatters. This also adds a flake check to ensure that the
      # source tree was auto formatted.
      treefmt.config = {
        projectRootFile = "flake.nix";

        programs.nixfmt.enable = true;
        programs.latexindent.enable = true;
      };

    };
}
