type exp =
    Num of int
  | Var of string
  | Add of exp * exp
  | Sub of exp * exp
  | Mul of exp * exp
  | Div of exp * exp

let e = Mul (Num 3, (Add (Var "x", Num 1)))
