all: q1

q1: mca_hw_dantas.tex q1.tex
	pdflatex --jobname="mca_hw_dantas" -output-directory Out mca_hw_dantas

clean:
	cd Out/
	rm -f *.lof *.lot *.toc *.aux *.out *.log
