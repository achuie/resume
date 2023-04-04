{
  description = "Build requirements for resume";

  inputs.nixpkgs.url = "nixpkgs/22.11";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        tex = pkgs.texlive.combine {
          inherit (pkgs.texlive)
            scheme-small latex-bin latexmk xcolor titlesec titling bold-extra
            changepage parskip etoolbox datetime2 tracklang xkeyval;
        };
        mkTeXDrvForDoc = doc: prettyName: (pkgs.stdenvNoCC.mkDerivation {
          name = prettyName;

          src = self;
          buildPhase = ''
            export PATH="${pkgs.lib.makeBinPath [ pkgs.coreutils tex ]}";
            mkdir -p .cache/texmf-var
            env TEXMFHOME=.cache TEXMFVAR=.cache/texmf-var \
              latexmk -interaction=nonstopmode -pdf -lualatex \
              ${doc}.tex
          '';
          installPhase = ''
            mkdir $out
            cp ${doc}.pdf $out/${prettyName}.pdf
          '';
          fixupPhase = "true";
        });
      in rec {
        packages = rec {
          resume = mkTeXDrvForDoc "resume" "andrew_huie";
          cover-letter = mkTeXDrvForDoc "cletter" "cover_letter";

          default = resume;
        };

        formatter = pkgs.nixfmt;
      });
}
