{
  description = "INTMAX2 Paper";
  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-24.11;
    flake-utils.url = github:numtide/flake-utils;
  };
  outputs = { self, nixpkgs, flake-utils }:
    with flake-utils.lib; eachSystem allSystems (system:
    let
      pkgs = nixpkgs.legacyPackages.${system};
      tex = pkgs.texlive.combine {
        inherit (pkgs.texlive)
        scheme-medium
        latex-bin
        footmisc
        latexmk
        biblatex
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
        multirow;
      };
    in rec {
      devShell = pkgs.mkShell { 
        buildInputs = with pkgs; [ 
          tex
          just
        ]; 
      };
      packages = {
        document = pkgs.stdenvNoCC.mkDerivation rec {
          name = "intmax2-paper";
          src = self;
          buildInputs = [ pkgs.coreutils tex ];
          phases = ["unpackPhase" "buildPhase" "installPhase"];
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
      defaultPackage = packages.document;
    });
}
