{
  description = "Build requirements for resume";

  inputs.nixpkgs.url = "nixpkgs/22.11";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        tex = pkgs.texlive.combine {
          inherit (pkgs.texlive) scheme-minimal latex-bin latexmk;
        };
      in rec {
        packages = rec {
          resume = pkgs.stdenvNoCC.mkDerivation {
            name = "resume";

            src = self;
            buildPhase = ''
              export PATH="${pkgs.lib.makeBinPath [ pkgs.coreutils tex ]}";
              mkdir -p .cache/texmf-var
              env TEXMFHOME=.cache TEXMFVAR=.cache/texmf-var \
                latexmk -interaction=nonstopmode -pdf -lualatex \
                resume.tex
            '';
            installPhase = ''
              mkdir $out
              cp resume.pdf $out/andrew_huie.pdf
            '';
          };
          default = resume;
        };

        formatter = pkgs.nixfmt;
      });
}
