all:
	pdflatex main.tex

mostlyclean:
	rm -f main.aux main.log main.out

clean: mostlyclean
	rm -f main.pdf
