namespace AST

type Exp =
  | Num of int
  | True
  | False
  | Var of string
  | Add of Exp * Exp // E + E
  | Sub of Exp * Exp // E - E
  | LessThan of Exp * Exp // E < E
  | GreaterThan of Exp * Exp // E > E
  | Equal of Exp * Exp // E == E
  | NotEq of Exp * Exp // E != E

type Stmt =
  | NOP // No-operation
  | Assign of string * Exp // x = E
  | Seq of Stmt * Stmt // S; S
  | If of Exp * Stmt * Stmt // if (E) { S } else { S }
  | While of Exp * Stmt // while (E) { S }

type Program = Stmt
