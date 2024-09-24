../main.bin: program.ml parser.mly lexer.mll ir.ml state.ml eval.ml executor.ml helper.ml translate.ml main.ml
	ocamlc -c program.ml
	ocamlyacc parser.mly
	ocamlc -c parser.mli
	ocamllex lexer.mll
	ocamlc -g program.cmo parser.ml lexer.ml ir.ml state.ml eval.ml executor.ml \
		helper.ml translate.ml str.cma main.ml -o ../main.bin

clean:
	rm -f *.cmo *.cmi lexer.ml parser.ml parser.mli ../main.bin
