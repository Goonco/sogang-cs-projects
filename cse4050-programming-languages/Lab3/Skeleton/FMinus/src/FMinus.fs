module FMinus

open AST
open Types

// Evaluate expression into a value, under the given environment.
let rec evalExp (exp: Exp) (env: Env) : Val =
  match exp with
  | Num i -> Int i
  | _ -> Int (-1) // TODO: fill in the remaining cases.

// Note: You may define more functions.

// The program starts execution with an empty environment. Do not fix this code.
let run (prog: Program) : Val =
  evalExp prog Map.empty
