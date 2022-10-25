all: resume cletter

resume:
	tectonic resume.tex && mv resume.pdf andrew_huie.pdf

cletter:
	tectonic cletter.tex && mv cletter.pdf cover_letter.pdf

clean:
	rm -f *.pdf
