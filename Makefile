all:
	pdflatex main.tex

mostlyclean:
	rm -r main.aux main.log main.out

clean: mostlyclean
	rm -f main.pdf
