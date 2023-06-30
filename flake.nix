{
  description = "Build requirements for resume";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

  outputs = { self, nixpkgs }:
    let
      forAllSystems = f: nixpkgs.lib.genAttrs [ "x86_64-linux" ] (system:
        f { pkgs = nixpkgs.legacyPackages.${system}; this = self.packages.${system}; });
    in
    {
      packages = forAllSystems (pset:
        with pset; let
          mkTeXDrvForDoc = doc: prettyName:
            (pkgs.stdenvNoCC.mkDerivation {
              name = prettyName;
              src = self;
              buildPhase = ''
                export PATH="${pkgs.lib.makeBinPath [ pkgs.coreutils this.tex ]}";
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
        in
        {
          tex = pkgs.texlive.combine {
            inherit (pkgs.texlive) scheme-small latex-bin latexmk bold-extra titlesec titling
              changepage datetime2 tracklang;
          };
          resume = mkTeXDrvForDoc "resume" "andrew_huie";
          cover-letter = mkTeXDrvForDoc "cletter" "cover_letter";
          default = this.resume;
        });

      apps = forAllSystems (pset:
        let
          coverLetterDateScript = pset.pkgs.writeShellScriptBin "compileCoverLetterWithDate.sh" ''
            export PATH="${pset.pkgs.lib.makeBinPath [ pset.pkgs.coreutils pset.this.tex ]}";
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
          cover-letter = {
            type = "app";
            program = "${coverLetterDateScript}/bin/compileCoverLetterWithDate.sh";
          };
        });

      formatter = forAllSystems (pset: pset.pkgs.nixpkgs-fmt);
    };
}
