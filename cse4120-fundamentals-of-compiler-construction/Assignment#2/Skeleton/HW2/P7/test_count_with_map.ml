open Count_with_map

let check_testcase input_list input_key answer_count =
  try
    let m = count_with_map input_list in
    let c = if IntMap.mem input_key m then IntMap.find input_key m else 0 in
    if c = answer_count
    then Printf.printf "O"
    else Printf.printf "X"
  with _ -> Printf.printf "E"

let l = [1; 3; 1; 2; 1; 5; 2] (* Three '1', two '2', one '3', one '5' *)

let _ = print_endline "================"
let _ = check_testcase l 1 3
let _ = check_testcase l 2 2
let _ = check_testcase l 5 1
let _ = print_newline ()
