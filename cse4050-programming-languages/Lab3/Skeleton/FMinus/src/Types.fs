namespace Types

open AST

// Raise this exception if the semantics of given program is not defined.
exception UndefinedSemantics

// Variable name that can appear in the program.
type VarName = string

// Value that can appear in this language.
type Val =
  | Int of int
  | Bool of bool
  | Func of VarName * Exp * Env
  | RecFunc of VarName * VarName * Exp * Env

// Environment is a map from variable to value.
and Env = Map<VarName, Val>
