all: resume cletter

resume:
	tectonic resume.tex && mv resume.pdf andrew_huie.pdf

cletter:
	tectonic cletter.tex

clean:
	rm -f *.pdf
