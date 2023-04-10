{
  description = "Build requirements for resume";

  inputs.nixpkgs.url = "nixpkgs/22.11";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        tex = pkgs.texlive.combine {
          inherit (pkgs.texlive) scheme-small latex-bin latexmk bold-extra titlesec titling
            changepage datetime2 tracklang;
        };
        mkTeXDrvForDoc = doc: prettyName:
          (pkgs.stdenvNoCC.mkDerivation {
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

        coverLetterDateScript = pkgs.writeShellScriptBin "compileCoverLetterWithDate.sh" ''
          export PATH="${pkgs.lib.makeBinPath [ pkgs.coreutils tex ]}";
          mkdir -p .cache/texmf-var
          env SOURCE_DATE_EPOCH=$(date -d "$1" +%s) LC_ALL=C LANG=en_US \
            TEXMFHOME=.cache TEXMFVAR=.cache/texmf-var \
            latexmk -interaction=nonstopmode -pdf -lualatex -gg \
            cletter.tex

          cp cletter.pdf cover_letter.pdf
          latexmk -C cletter.tex
        '';
      in
      {
        packages = rec {
          resume = mkTeXDrvForDoc "resume" "andrew_huie";
          cover-letter = mkTeXDrvForDoc "cletter" "cover_letter";
          default = resume;
        };

        apps = {
          cover-letter = {
            type = "app";
            program = "${coverLetterDateScript}/bin/compileCoverLetterWithDate.sh";
          };
        };

        formatter = pkgs.nixpkgs-fmt;
      });
}
