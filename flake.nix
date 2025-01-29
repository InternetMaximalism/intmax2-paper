{
  description = "INTMAX2 Paper";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    flake-parts.url = "github:hercules-ci/flake-parts";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";
    nixvim = {
      url = "github:nix-community/nixvim";
    };
  };
  outputs =
    inputs@{
      self,
      nixpkgs,
      flake-parts,
      nixvim,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        # systems for which you want to build the `perSystem` attributes
        "x86_64-linux"
        # ...
      ];
      imports = [
        inputs.treefmt-nix.flakeModule
        ./nix/modules/formatter.nix
        ./nix/vim/vim.nix
      ];
      perSystem =
        {
          config,
          self',
          inputs',
          pkgs,
          system,
          ...
        }:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          tex = pkgs.texlive.combine {
            inherit (pkgs.texlive)
              scheme-medium
              latex-bin
              footmisc
              latexmk
              biblatex
              llncs
              biber
              comment
              glossaries
              cleveref
              hyperref
              enumitem
              mdframed
              tikz-cd
              zref
              needspace
              latexindent
              multirow
              ;
          };
        in
        rec {
          devShells.default = pkgs.mkShell {
            inputsFrom = [
              config.treefmt.build.devShell
            ];
            buildInputs = with pkgs; [
              pplatex
              tex
              just
              lazygit
              self'.packages.mynvim
            ];
          };
          packages = {
            default = pkgs.stdenvNoCC.mkDerivation rec {
              name = "intmax2-paper";
              src = self;
              buildInputs = [
                pkgs.coreutils
                tex
              ];
              phases = [
                "unpackPhase"
                "buildPhase"
                "installPhase"
              ];
              buildPhase = ''
                export PATH="${pkgs.lib.makeBinPath buildInputs}";
                mkdir -p .cache/texmf-var
                env TEXMFHOME=.cache TEXMFVAR=.cache/texmf-var \
                  SOURCE_DATE_EPOCH=${toString self.lastModified} \
                  latexmk -interaction=nonstopmode -pdf -lualatex \
                  main.tex
              '';
              installPhase = ''
                mkdir -p $out
                cp main.pdf $out/
              '';
            };
          };
        };
    };
}
