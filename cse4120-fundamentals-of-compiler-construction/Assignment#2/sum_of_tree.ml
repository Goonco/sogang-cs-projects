(* DO NOT change the definition of this type *)
type tree = Leaf of int | Node of int * tree * tree

(* Return the summation of integers stored in binary tree 't'. *)
let rec sum_of_tree t =
  match t with
  | Leaf i -> i 
  | Node (i, t1, t2) -> i + sum_of_tree(t1) + sum_of_tree(t2)
