module P2

// (Note) Do NOT change the definition of the following type and exception.
type Exp =
    Num of int
  | Add of Exp * Exp
  | Sub of Exp * Exp
  | Mul of Exp * Exp
  | Div of Exp * Exp

exception DivByZero

/// Return the integer value represented by the expression 'e'. If there is any
/// division-by-zero case, raise the 'DivByZero' exception.
let rec eval (e: Exp) : int =
  match e with
  | Num n -> n
  | Add (exp1, exp2) -> (eval exp1) + (eval exp2)
  | Sub (exp1, exp2) -> (eval exp1) - (eval exp2)
  | Mul (exp1, exp2) -> (eval exp1) * (eval exp2)
  | Div (exp1, exp2) -> (
    if (eval exp2) <> 0 then 
      (eval exp1) / (eval exp2)
    else 
      raise DivByZero 
  )
