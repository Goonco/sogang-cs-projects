open Cond_eval

let check_testcase test_input answer =
  try
    if eval test_input = answer
    then Printf.printf "O"
    else Printf.printf "X"
  with _ -> Printf.printf "E"

let c1 = Not (LessThan (3, 5)) (* ! (3 < 5) *)
let _ = Printf.printf "%b\n" (eval c1) (* Must be false *)

let c2 = And (Equal (2, 2), NotEqual (3, 4)) (* (2 == 2) && (3 != 4) *)
let _ = Printf.printf "%b\n" (eval c2) (* Must be true *)

let c3 = Or (LessThan (8, 4), Equal (6, 7)) (* (8 < 4) || (6 == 7) *)
let _ = Printf.printf "%b\n" (eval c3) (* Must be false *)

let _ = print_endline "================"
let _ = check_testcase c1 false
let _ = check_testcase c2 true
let _ = check_testcase c3 false
let _ = print_newline ()
