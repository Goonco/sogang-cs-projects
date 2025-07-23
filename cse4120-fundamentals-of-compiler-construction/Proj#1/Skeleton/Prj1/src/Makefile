all: program.ml parser.mly lexer.mll error.ml typeCheck.ml main.ml
	ocamlc -c program.ml
	ocamlyacc parser.mly
	ocamlc -c parser.mli
	ocamllex lexer.mll
	ocamlc -c error.ml
	ocamlc -g program.cmo parser.ml lexer.ml error.ml typeCheck.ml main.ml \
		-o ../main.bin

clean:
	rm -f *.cmo *.cmi lexer.ml parser.ml parser.mli ../main.bin
