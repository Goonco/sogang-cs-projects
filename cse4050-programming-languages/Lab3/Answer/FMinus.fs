module FMinus

open AST
open Types

let checkNumber (value: Val) : int =
  match value with
  | Int n -> n
  | _ -> raise UndefinedSemantics

let checkBoolean (value: Val) : bool =
  match value with
  | Bool b -> b
  | _ -> raise UndefinedSemantics

let checkSame (value1: Val) (value2: Val) : bool =
  match value1, value2 with
  | (Int n1, Int n2) -> n1 = n2
  | (Bool b1, Bool b2) -> b1 = b2
  | _ -> raise UndefinedSemantics

let rec evalExp (globExp: Exp) (globEnv: Env) : Val =
  match globExp with
  | Num n -> Int n // ✅
  | True -> Bool true // ✅
  | False -> Bool false // ✅
  | Var varname -> // ✅
    match Map.tryFind varname globEnv with
    | Some value -> value
    | None -> raise UndefinedSemantics
  | Neg exp ->  // ✅
    let number = checkNumber (evalExp exp globEnv) in
      Int -number

  // ✅
  | Add (exp1, exp2) | Sub (exp1, exp2) | LessThan (exp1, exp2) | GreaterThan (exp1, exp2) ->
    let number1 = checkNumber (evalExp exp1 globEnv) in
    let number2 = checkNumber (evalExp exp2 globEnv) in
    match globExp with
    | Add _ -> Int (number1 + number2)
    | Sub _ -> Int (number1 - number2)
    | LessThan _ -> Bool (number1 < number2)
    | GreaterThan _ -> Bool (number1 > number2)
    | _ -> raise UndefinedSemantics

  // ✅
  | Equal (exp1, exp2) | NotEq (exp1, exp2) ->
    let compareResult = checkSame (evalExp exp1 globEnv) (evalExp exp2 globEnv) in
    match globExp with
    | Equal _ -> Bool (compareResult)
    | NotEq _ -> Bool (not compareResult)
    | _ -> raise UndefinedSemantics

  // ✅
  | IfThenElse (condExp, trueExp, falseExp) ->
    let conditionResult = checkBoolean (evalExp condExp globEnv) in
    if conditionResult then (evalExp trueExp globEnv)
    else (evalExp falseExp globEnv)

  // ✅
  | LetIn (newVarname, assignExp, nextExp) ->
    let assignValue = evalExp assignExp globEnv in
    let newEnv = Map.add newVarname assignValue globEnv in
    evalExp nextExp newEnv

  // ✅
  | LetFunIn (funcname, varname, assignExp, nextExp) ->
    let newEnv = Map.add funcname (Func (varname, assignExp, globEnv)) globEnv in
    evalExp nextExp newEnv
  | LetRecIn (funcname, varname, assignExp, nextExp) ->
    let newEnv = Map.add funcname (RecFunc (funcname, varname, assignExp, globEnv)) globEnv in
    evalExp nextExp newEnv
  | Fun (varname, exp) -> Func (varname, exp, globEnv)

  // ✅
  | App (funcnameexp: Exp, varname) ->
    let Varg = evalExp varname globEnv in
    
    match (evalExp funcnameexp globEnv) with
    | Func (x: VarName, eb: Exp, envPrime) -> 
      let nextEnv = Map.add x Varg envPrime in
      evalExp eb nextEnv
    
    | RecFunc (recFuncName, x, eb: Exp, envPrime) ->
      let nextEnv = Map.add x Varg envPrime in
      let nextEnv2 = Map.add recFuncName (RecFunc (recFuncName, x, eb, envPrime)) nextEnv in
      evalExp eb nextEnv2
    
    | _ -> raise UndefinedSemantics

// The program starts execution with an empty environment. Do not fix this code.
let run (prog: Program) : Val =
  evalExp prog Map.empty
