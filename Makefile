all: resume cletter

resume:
	pdflatex -jobname andrew_huie resume.tex

cletter:
	pdflatex cletter.tex

clean:
	rm -f *.aux *.log *.out

veryclean: clean
	rm -f *.pdf
