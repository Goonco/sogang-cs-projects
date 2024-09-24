(* DO NOT change the definition of this type *)
type exp =
    Num of int
  | Add of exp * exp
  | Sub of exp * exp
  | Mul of exp * exp
  | Div of exp * exp

(* Return the integer value represented by the expression 'e'. *)
let rec eval e =
  match e with
  | Num i -> 1        (* TODO *)
  | Add (e1, e2) -> 2 (* TODO *)
  | Sub (e1, e2) -> 3 (* TODO *)
  | Mul (e1, e2) -> 4 (* TODO *)
  | Div (e1, e2) -> 5 (* TODO *)
