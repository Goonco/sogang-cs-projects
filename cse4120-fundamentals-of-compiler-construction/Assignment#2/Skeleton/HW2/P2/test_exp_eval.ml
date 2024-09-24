open Exp_eval

let check_testcase test_input answer =
  try
    if eval test_input = answer
    then Printf.printf "O"
    else Printf.printf "X"
  with _ -> Printf.printf "E"

let e1 = Add (Num 3, Div (Num 7, Num 2)) (* 3 + 7 / 2 *)
let _ = Printf.printf "%d\n" (eval e1) (* Must be 6 *)

let e2 = Sub (Add (Num 2, Num 9), Num 6) (* (2 + 9) - 6 *)
let _ = Printf.printf "%d\n" (eval e2) (* Must be 5 *)

let e3 = Mul (Num 3, (Add (Num 1, Num 2))) (* 3 X (1 + 2) *)
let _ = Printf.printf "%d\n" (eval e3) (* Must be 9 *)

let _ = print_endline "================"
let _ = check_testcase e1 6
let _ = check_testcase e2 5
let _ = check_testcase e3 9
let _ = print_newline ()
