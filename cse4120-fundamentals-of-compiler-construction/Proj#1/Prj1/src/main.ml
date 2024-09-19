open Printf

let rec print_error_list errors =
  match errors with
  | [] -> ()
  | head_error :: tail_errors ->
      let _ = Printf.printf "%s\n" (Error.to_str head_error) in
      print_error_list tail_errors

let main () =
  let _ =
    if Array.length Sys.argv <> 3 then
      (Printf.printf "Usage: %s print|check <prog>\n" Sys.argv.(0); exit 1)
  in
  let input_channel = open_in Sys.argv.(2) in
  let lexbuf = Lexing.from_channel input_channel in
  let prog = Parser.program Lexer.token lexbuf in
  match Sys.argv.(1) with
  | "print" -> print_endline (Program.to_str prog)
  | "check" -> print_error_list (TypeCheck.run prog)
  | s -> Printf.printf "Unsupported action %s\n" s

let _ = main ()
