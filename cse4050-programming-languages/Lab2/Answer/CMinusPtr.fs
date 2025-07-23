module CMinusPtr

open AST
open Types

// Evaluate expression into a value, under the given memory.

let rec evalExp (expType: Exp) (mem: Mem) : Val =
  match expType with
  | Num i -> Int i
  | True -> Bool true
  | False -> Bool false

  | AddrOf varname -> Loc (VarName varname)
  | LV lval -> 
    let varname = evalLVal lval mem in
    if Map.containsKey varname mem then
      Map.find varname mem
    else raise UndefinedSemantics 
  
  | Add (exp1, exp2) | Sub (exp1, exp2)
  | LessThan (exp1, exp2) | GreaterThan (exp1, exp2) ->
    let val1 = (evalExp exp1 mem) in
    let val2 = (evalExp exp2 mem) in
    
    match val1, val2, expType with
    | Int n1, Int n2, Add _ -> Int (n1 + n2)
    | Int n1, Int n2, Sub _ -> Int (n1 - n2)
    | Int n1, Int n2, LessThan _ -> Bool (n1 < n2)
    | Int n1, Int n2, GreaterThan _ -> Bool (n1 > n2)
    | _ -> raise UndefinedSemantics

  | Equal (exp1, exp2) | NotEq (exp1, exp2) ->
    let val1 = evalExp exp1 mem in
    let val2 = evalExp exp2 mem in
    
    match val1, val2, expType with
    | Int n1, Int n2, Equal _ -> Bool (n1 = n2)
    | Int n1, Int n2, NotEq _ -> Bool (n1 <> n2)
    | Bool b1, Bool b2, Equal _ -> Bool (b1 = b2)
    | Bool b1, Bool b2, NotEq _ -> Bool (b1 <> b2)
    | Loc l1, Loc l2, Equal _ -> Bool (l1 = l2)
    | Loc l1, Loc l2, NotEq _ -> Bool (l1 <> l2)
    | _ -> raise UndefinedSemantics

and evalLVal lval mem : VarName = 
  match lval with
  | Var varname -> VarName varname
  | Deref exp ->
    let res = evalExp exp mem in
    match res with
    | Loc varname -> varname
    | _ -> raise UndefinedSemantics

let checkCondition (condExp : Exp) (mem : Mem) : bool =
  let condition = (evalExp condExp mem) in
  match condition with
  | Bool cond -> cond
  | _ -> raise UndefinedSemantics

let rec evalStmt (stmt: Stmt) (originMem: Mem) : Mem =
  match stmt with
  | NOP -> originMem
  
  | Assign (lval, exp) ->
    let lvalRes = (evalLVal lval originMem) in
    let expRes = (evalExp exp originMem) in
    Map.add lvalRes expRes originMem
  
  | If (condExp, tStmt, fStmt) -> 
    if (checkCondition condExp originMem) then
      (evalStmt tStmt originMem)
    else
      (evalStmt fStmt originMem)
  
  | While (condExp, stmt) -> 
    if (checkCondition condExp originMem) then
      let updateMem = (evalStmt stmt originMem) in
      evalStmt (While (condExp, stmt)) updateMem
    else
      originMem
  
  | Seq (stmt1, stmt2) -> 
    let intermediateMem = (evalStmt stmt1 originMem) in
    evalStmt stmt2 intermediateMem

// The program starts execution with an empty memory. Do NOT fix this function.
let run (prog: Program) : Mem =
  evalStmt prog Map.empty
