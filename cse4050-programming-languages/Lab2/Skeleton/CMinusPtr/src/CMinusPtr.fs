module CMinusPtr

open AST
open Types

// Evaluate expression into a value, under the given memory.
let rec evalExp (exp: Exp) (mem: Mem) : Val =
  match exp with
  | Num i -> Int i
  | _ -> Int (-1) // TODO: fill in the remaining cases.

// Note: You may define more functions.

// Execute a statement and return the updated memory.
let rec exec (stmt: Stmt) (mem: Mem) : Mem =
  match stmt with
  | NOP -> mem // NOP does not change the memory.
  | _ -> mem // TODO: fill in the remaining cases.

// The program starts execution with an empty memory. Do NOT fix this function.
let run (prog: Program) : Mem =
  exec prog Map.empty
