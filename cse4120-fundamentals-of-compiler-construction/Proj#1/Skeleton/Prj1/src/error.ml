open Printf
open Program

type error =
    UndefinedName of string (* Name of undefined variable/function *)
  | AssignMismatch of ctype * ctype (* LHS variable type, RHS value type *)
  | ReturnMismatch of ctype * ctype (* Expected type, actual type returned *)
  | CallingVariable of string (* Name of variable trying to be called *)
  | UsingFunctionAsVar of string (* Name of function trying to be used *)
  | ArgTypeMismatch of ctype * ctype (* Expected arg type, passed arg type *)
  | ArgNumMismatch
  | OperandMismatch

let to_str (e: error) =
  match e with
  | UndefinedName s -> sprintf "Undefined name %s" s
  | AssignMismatch (t1, t2) ->
      sprintf "Variable is %s type, but assigning %s type value"
        (ctype_to_str t1) (ctype_to_str t2)
  | ReturnMismatch (t1, t2) ->
      sprintf "Function must return %s type, but statement is returning %s type"
        (ctype_to_str t1) (ctype_to_str t2)
  | CallingVariable s -> sprintf "Trying to call variable %s like function" s
  | UsingFunctionAsVar s -> sprintf "Trying to use function %s like variable" s
  | ArgTypeMismatch (t1, t2) ->
      sprintf "Expecting %s type argument, but %s type is passed"
        (ctype_to_str t1) (ctype_to_str t2)
  | ArgNumMismatch -> "Mismatch of argument numbers (no detailed information)"
  | OperandMismatch -> "Operand type mismatch (no detailed information)"
