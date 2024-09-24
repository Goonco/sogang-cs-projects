open Multiply_tree

let check_testcase input_tree input_int answer =
  try
    if multiply_tree input_tree input_int = answer
    then Printf.printf "O"
    else Printf.printf "X"
  with _ -> Printf.printf "E"

let t1 = Leaf 10
let t2 = Node (3, Leaf 1, Leaf 2)
let t3 = Node (5, Leaf 4, t2)
let ans1 = Leaf 20
let ans2 = Node (-3, Leaf (-1), Leaf (-2))
let ans3 = Node (15, Leaf 12, Node (9, Leaf 3, Leaf 6))

let _ = print_endline "================"
let _ = check_testcase t1 2 ans1
let _ = check_testcase t2 (-1) ans2
let _ = check_testcase t3 3 ans3
let _ = print_newline ()
