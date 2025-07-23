open Sum_of_tree

let check_testcase test_input answer =
  try
    if sum_of_tree test_input = answer
    then Printf.printf "O"
    else Printf.printf "X"
  with _ -> Printf.printf "E"

let t1 = Leaf 10
let _ = Printf.printf "%d\n" (sum_of_tree t1) (* Must be 10 *)
let t2 = Node (3, Leaf 1, Leaf 2)
let _ = Printf.printf "%d\n" (sum_of_tree t2) (* Must be 6 *)
let t3 = Node (5, Leaf 4, t2)
let _ = Printf.printf "%d\n" (sum_of_tree t3) (* Must be 15 *)

let _ = print_endline "================"
let _ = check_testcase t1 10
let _ = check_testcase t2 6
let _ = check_testcase t3 15
let _ = print_newline ()
