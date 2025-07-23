(* DO NOT change the definition of this type *)
type tree = Leaf of int | Node of int * tree * tree

(* Return the summation of integers stored in binary tree 't'. *)
let rec sum_of_tree t =
  match t with
  | Leaf i -> 1 (* TODO *)
  | Node (i, t1, t2) -> 2 (* TODO *)
