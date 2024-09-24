open Sum_to_n

let check_testcase test_input answer =
  try
    if sum_to_n test_input = answer
    then Printf.printf "O"
    else Printf.printf "X"
  with _ -> Printf.printf "E"

let _ = Printf.printf "%d\n" (sum_to_n 2) (* Must be 3 *)
let _ = Printf.printf "%d\n" (sum_to_n 5) (* Must be 15 *)
let _ = Printf.printf "%d\n" (sum_to_n 9) (* Must be 45 *)
let _ = Printf.printf "%d\n" (sum_to_n 0) (* Must be 0 *)

let _ = print_endline "================"
let _ = check_testcase 2 3
let _ = check_testcase 5 15
let _ = check_testcase 9 45
let _ = check_testcase 0 0
let _ = print_newline ()
