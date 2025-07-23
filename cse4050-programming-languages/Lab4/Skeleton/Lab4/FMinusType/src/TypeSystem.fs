namespace FMinus

open AST

// Type.infer() must raise this if the input program seems to have a type error.
exception TypeError

// The types available in our F- language.
type Type =
  | Int
  | Bool
  | TyVar of string
  | Func of Type * Type

type TypeEnv = Map<string, Type>

module Type =

  // Convert the given 'Type' to a string.
  let rec toString (typ: Type): string =
    match typ with
    | Int -> "int"
    | Bool -> "bool"
    | TyVar s -> s
    | Func (t1, t2) -> sprintf "(%s) -> (%s)" (toString t1) (toString t2)

  // Return the inferred type of the input program.
  let infer (prog: Program) : Type =
    Func (Int, Bool) (* TODO *)
