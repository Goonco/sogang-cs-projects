namespace AST

type Exp =
  | Num of int
  | True
  | False
  | Var of string
  | Neg of Exp // - E
  | Add of Exp * Exp // E + E
  | Sub of Exp * Exp // E - E
  | LessThan of Exp * Exp // E < E
  | GreaterThan of Exp * Exp // E > E
  | Equal of Exp * Exp // E == E
  | NotEq of Exp * Exp // E != E
  | IfThenElse of Exp * Exp * Exp // If E then E else E
  | LetIn of string * Exp * Exp // let x = E in E
  | LetFunIn of string * string * Exp * Exp // let f x = E in E
  | LetRecIn of string * string * Exp * Exp // let rec f x = E in E
  | Fun of string * Exp // fun x -> E
  | App of Exp * Exp // E E (function application)

type Program = Exp
