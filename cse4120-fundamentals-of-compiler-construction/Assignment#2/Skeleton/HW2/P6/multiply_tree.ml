(* DO NOT change the definition of this type *)
type tree = Leaf of int | Node of int * tree * tree

(* Return a binary tree with each integer multiplied by 'n'.*)
let rec multiply_tree t n =
  match t with
  | Leaf i -> Leaf 0 (* TODO *)
  | Node (i, t1, t2) -> Leaf 0 (* TODO *)
