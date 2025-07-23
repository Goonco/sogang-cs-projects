open Filter_list

let check_testcase test_input answer =
  try
    if filter_negative test_input = answer
    then Printf.printf "O"
    else Printf.printf "X"
  with _ -> Printf.printf "E"

let l1 = [1; -2; 3; -4; 5]
let l2 = [-2; 0; 4; -9; 7]
let l3 = [0; 0; 3; -2; -6]

let _ = print_endline "================"
let _ = check_testcase l1 [1; 3; 5]
let _ = check_testcase l2 [0; 4; 7]
let _ = check_testcase l3 [0; 0; 3]
let _ = print_newline ()
