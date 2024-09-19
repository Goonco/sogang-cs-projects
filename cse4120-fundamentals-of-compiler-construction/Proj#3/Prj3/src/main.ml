open Printf

let usage () =
  let _ = printf "<Usage>\n" in
  let _ = printf "[*]%s print-ast <source file>\n" Sys.argv.(0) in
  let _ = printf "[*]%s print-ir <source file>\n" Sys.argv.(0) in
  let _ = printf "[*]%s run-ir <source file> <input file>\n" Sys.argv.(0) in
  let _ = printf "[*]%s print-opt <source file>\n" Sys.argv.(0) in
  let _ = printf "[*]%s run-opt <source file> <input file>\n" Sys.argv.(0) in
  exit 1

let check_args argv =
  let argc = Array.length Sys.argv in
  if argc < 3 then false
  else
    match Sys.argv.(1) with
    | "print-ast" -> argc = 3
    | "print-ir" -> argc = 3
    | "run-ir" -> argc = 4
    | "print-opt" -> argc = 3
    | "run-opt" -> argc = 4
    | _ -> false

let run_with_input_file ir input_filepath =
  let channel = open_in input_filepath in
  let rec repeat_run () =
    try
      let line = input_line channel in
      let args = Str.split (Str.regexp " +") line in
      let _ = Executor.run ir args in
      repeat_run ()
    with End_of_file -> close_in channel
  in
  repeat_run ()

let main () =
  let _ = if not (check_args Sys.argv) then usage () in
  let channel = open_in Sys.argv.(2) in
  let lexbuf = Lexing.from_channel channel in
  let prog = Parser.program Lexer.token lexbuf in
  match Sys.argv.(1) with
  | "print-ast" -> print_endline (Program.to_str prog)
  | "print-ir" -> print_endline (Ir.to_str (Translate.run prog))
  | "run-ir" -> run_with_input_file (Translate.run prog) Sys.argv.(3)
  | "print-opt" ->
      let ir = Translate.run prog in
      let optimized = Optimize.run ir in
      print_endline (Ir.to_str optimized)
  | "run-opt" ->
      let ir = Translate.run prog in
      let optimized = Optimize.run ir in
      run_with_input_file optimized Sys.argv.(3)
  | s -> usage ()

let _ = main ()
