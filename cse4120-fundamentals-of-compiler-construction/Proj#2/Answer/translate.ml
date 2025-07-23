open Program
open Ir
open Helper

(* The module for symbol table. Carefully think about what should be stored in
 * the symbol table for this IR translation phase. *)
(* Map : string - reg *)
module SymbolMap = Map.Make(String)

(* Let's assume that boolean is 1-byte and integer is 4-byte. *)
let sizeof ctyp =
  match ctyp with
  | CInt -> 4
  | CBool -> 1
  | CIntArr n -> 4 * n
  | CBoolArr n -> n

(* args는 decl list이며 decl = ctype * string *)
(* Returns string list *)
let rec extract_names args =
  match args with
  | [] -> []
  | (arg_typ, arg_name) :: tail_args -> arg_name :: extract_names tail_args

type typ = Int | Bool | IntArr | BoolArr

let ctyp_to_typ ctyp =
  match ctyp with
  | CInt -> Int
  | CBool -> Bool
  | CIntArr _ -> IntArr
  | CBoolArr _ -> BoolArr

let typ_to_ctyp myTyp num =
  match myTyp with
  | IntArr -> CIntArr num
  | BoolArr -> CBoolArr num
  | Int -> CInt
  | Bool -> CBool

(* ------------------------------------------------------------------------------------- *)

(* Return : InstList, operand *)
let rec trans_exp exp symbolMap =
  match exp with
  | ConstBool b  -> ([], Imm(ImmBool b))
  | ConstInt i -> ([], Imm(ImmInt i)
  )
  | Var vName -> (
    let (regName, _) = SymbolMap.find vName symbolMap in
    let r = create_register_name() in
    ([Load (r, regName)], Reg r)
  )

  | Arr (varName, exp) -> (
    let (movedInst, movedReg) = calculateArr symbolMap varName exp in
    let result = create_register_name() in
    (movedInst @ [Load (result, movedReg)], Reg result)
  )

  | Add (expr1, expr2) -> handle_two_exp expr1 expr2 symbolMap AddOp
  | Sub (expr1, expr2) -> handle_two_exp expr1 expr2 symbolMap SubOp
  | Mul (expr1, expr2) -> handle_two_exp expr1 expr2 symbolMap MulOp
  | Div (expr1, expr2) -> handle_two_exp expr1 expr2 symbolMap DivOp
  | Neg expr -> handle_one_exp expr symbolMap NegOp
  | Equal (expr1, expr2) -> handle_two_exp expr1 expr2 symbolMap EqOp
  | NotEq (expr1, expr2) -> handle_two_exp expr1 expr2 symbolMap NeqOp
  | LessEq (expr1, expr2) -> handle_two_exp expr1 expr2 symbolMap LeqOp
  | LessThan (expr1, expr2) -> handle_two_exp expr1 expr2 symbolMap LtOp
  | GreaterEq (expr1, expr2) -> handle_two_exp expr1 expr2 symbolMap GeqOp
  | GreaterThan (expr1, expr2) -> handle_two_exp expr1 expr2 symbolMap GtOp
  | Not expr -> handle_one_exp expr symbolMap NotOp

  | And (expr1, expr2) -> (
    let (il1, opr1) = trans_exp expr1 symbolMap in
    let (il2, opr2) = trans_exp expr2 symbolMap in
    
    let label1 = create_label() in
    match opr1 with
    | Imm im1 -> (
      let retReg = create_register_name() in
      let ilRes = il1 @ [Set (retReg, im1); GotoIfNot (retReg, label1)] @ il2 in
      match opr2 with
      (* 1번이 true면 2번으로 결정 *)
      | Imm im2 -> (ilRes @ [Set (retReg, im2); Label label1], Reg retReg)
      | Reg rg2 -> (ilRes @ [Copy (rg2, retReg); Label label1], Reg retReg)
    )
    | Reg retReg -> (
      let ilRes = il1 @ [GotoIfNot (retReg, label1)] @ il2 in
      match opr2 with
      | Imm im2 -> (ilRes @ [Set (retReg, im2); Label label1], Reg retReg)
      | Reg rg2 -> (ilRes @ [Copy (rg2, retReg); Label label1], Reg retReg)
    )
  )
  | Or (expr1, expr2) -> (
    let (il1, opr1) = trans_exp expr1 symbolMap in
    let (il2, opr2) = trans_exp expr2 symbolMap in
    let label1 = create_label() in

    match opr1 with
    | Imm im1 -> (
      let retReg = create_register_name() in
      let ilRes = il1 @ [Set (retReg, im1); GotoIf (retReg, label1)] @ il2 in
      match opr2 with
      | Imm im2 -> (ilRes @ [Set (retReg, im2); Label label1], Reg retReg)
      | Reg rg2 -> (ilRes @ [Copy (rg2, retReg); Label label1], Reg retReg)
    )
    | Reg retReg -> (
      let ilRes = il1 @ [GotoIf (retReg, label1)] @ il2 in
      match opr2 with
      | Imm im2 -> (ilRes @ [Set (retReg, im2); Label label1], Reg retReg)
      | Reg rg2 -> (ilRes @ [Copy (rg2, retReg); Label label1], Reg retReg)
    )
  )

and handle_two_exp exp1 exp2 symbolMap binOp =
  let (il1, opr1) = trans_exp exp1 symbolMap in
  let (il2, opr2) = trans_exp exp2 symbolMap in
  let r = create_register_name() in
  ((il1 @ il2 @ [BinOp (r, binOp, opr1, opr2)]), Reg r)

and handle_one_exp expr symbolMap unOp =
  let (il, opr) = trans_exp expr symbolMap in
  let r = create_register_name() in
  ((il @ [UnOp (r, unOp, opr)]), Reg r)

and calculateArr symbolMap varName exp =
  (* register 반환 (Load해야됨) *)
  let (numInst, numOpr) = trans_exp exp symbolMap in
  let (lhsReg, varTyp) = SymbolMap.find varName symbolMap in
  
  match numOpr with
  | Imm (ImmInt num) -> (
    let ctypSize = typ_to_ctyp varTyp num in
    let movedReg = create_register_name() in
    let movedInst = [BinOp (movedReg, AddOp, Reg lhsReg, Imm(ImmInt(sizeof ctypSize)))] in
    (movedInst, movedReg)
  )
  | Reg rg -> (
    let multiply = create_register_name() in
    let movedReg = create_register_name() in
    let result = create_register_name() in
    match varTyp with
    | IntArr -> (
      let movedInst = [BinOp (multiply, MulOp, Reg rg, Imm(ImmInt 4)); BinOp (movedReg, AddOp, Reg lhsReg, Reg multiply)] in
      (numInst @ movedInst, movedReg)
    )
    | BoolArr -> (
      let movedInst = [BinOp (multiply, MulOp, Reg rg, Imm(ImmInt 1)); BinOp (movedReg, AddOp, Reg lhsReg, Reg multiply)] in
      (numInst @ movedInst, movedReg)
    )
    | Int | Bool -> (
      let _ = Printf.printf("Somethings Wrong #1\n") in
      ([], "SomethingsWrong")
    )
  )    
  | Imm (ImmBool b) -> (
    let _ = Printf.printf("Somethings Wrong #2\n") in
    ([], "SomethingsWrong")
  )


(* ------------------------------------------------------------------------------ *)

let rec trans_stmt stmt symbolMap  =  
  match stmt with
  | LocalDecl (ctyp, vName) -> (
    let r = create_register_name () in 
    let nextSM = SymbolMap.add vName (r,ctyp_to_typ ctyp) symbolMap in
    (nextSM, [LocalAlloc(r, sizeof ctyp)])
  )
  
  | Assign (lhsName, exp) -> (
    let (instrs, rhsOpr) = trans_exp exp symbolMap in
    
    match lhsName with
    | LVar lVarName -> (
      let (lhsReg, _) = SymbolMap.find lVarName symbolMap in
      match rhsOpr with
      | Imm im -> (symbolMap, instrs @ [Store (Imm im, lhsReg)])
      | Reg rg -> (symbolMap, instrs @ [Store (Reg rg, lhsReg)])
    )
    | LArr (varName, exp) -> (
      let (movedInst, movedReg) = calculateArr symbolMap varName exp in
      match rhsOpr with
      | Imm im -> (symbolMap, instrs @ movedInst @ [Store (Imm im, movedReg)])
      | Reg rg -> (symbolMap, instrs @ movedInst @ [Store (Reg rg, movedReg)])
    )
  )
  
  | If (condExp, true_branch, false_branch) -> (
    let (instrs, condOpr) = trans_exp condExp symbolMap in
    let label1 = create_label()in
    let label2 = create_label()in

    let trueBranchInst = trans_stmtList true_branch symbolMap [] in
    let falseBranchInst = trans_stmtList false_branch symbolMap [] in
    let integrateInst = trueBranchInst @ [Goto label2; Label label1] @ falseBranchInst @ [Label label2] in
    
    match condOpr with
    | Imm im -> (
      let rg = create_register_name() in
      let nextIL = instrs @ [Set (rg, im); GotoIfNot (rg, label1)] in
      (symbolMap, nextIL @ integrateInst)
    )
    | Reg rg -> (
      let nextIL = instrs @ [GotoIfNot (rg, label1)] in
      (symbolMap, nextIL @ integrateInst)
    )
  )
  
  | While (condExp, branch) ->  (
    let (instrs, condOpr) = trans_exp condExp symbolMap in
    let label1 = create_label()in
    let label2 = create_label()in

    let startLoopInst = [Label label1] @ instrs in
    let loopProcessInst = trans_stmtList branch symbolMap [] in
    let endLoopInst = [Goto label1; Label label2] in
    match condOpr with
    | Imm im -> (
      let rg = create_register_name() in
      let nextIL = startLoopInst @ [Set (rg, im); GotoIfNot (rg, label2)] in
      (symbolMap, nextIL @ loopProcessInst @ endLoopInst)
    )
    | Reg rg -> (
      let nextIL = startLoopInst @ [GotoIfNot (rg, label2)] in
      (symbolMap, nextIL @ loopProcessInst @ endLoopInst)
    )
  )

  | ReturnValue exp -> (
    let (instrs, retVal) = trans_exp exp symbolMap in
    match retVal with
      | Imm im -> (symbolMap, instrs @ [Ret (Imm im)])
      | Reg rg -> (symbolMap, instrs @ [Ret (Reg rg)])
  )

  (* Return 결과 instrList *)
and trans_stmtList stmts symbolMap instrList  =
  match stmts with
  | [] -> (instrList)
  | stmt :: stmtList -> (
    let (resSM, resIL) = trans_stmt stmt symbolMap in
    trans_stmtList stmtList resSM (instrList @ resIL)
  )

(* ------------------------------------------------------------------------------ *)

let rec allocate_args args symbolMap instrList =
  match args with
  | [] -> (symbolMap, instrList)
  | (varType, varName) :: nextArgs -> (
    let r = create_register_name () in 
    let nextSM = SymbolMap.add varName (r, ctyp_to_typ varType) symbolMap in
    let nextIL = instrList @ [LocalAlloc(r, sizeof varType); Store(Reg varName, r)] in
    allocate_args nextArgs nextSM nextIL
  )

(* ir_function = string * register list * instr list *)
let run (p: program): ir_code =
  let (fname, ret_type, args, stmts) = p in

  let (symbolMap, instrList) = allocate_args args SymbolMap.empty [] in
  let ansInstrList = trans_stmtList stmts symbolMap instrList in

  (fname, extract_names args, ansInstrList)

(* -------------------------------- *)

    (* let (numInst, numOpr) = trans_exp exp symbolMap in
    let (lhsReg, varTyp) = SymbolMap.find varName symbolMap in
    
    match numOpr with
    | Imm (ImmInt num) -> (
      let ctypSize = typ_to_ctyp varTyp num in
      let movedReg = create_register_name() in
      let movedInst = [BinOp (movedReg, AddOp, Reg lhsReg, Imm(ImmInt(sizeof ctypSize)))] in

      let result = create_register_name() in
      (numInst @ movedInst @ [Load (result, movedReg)], Reg result)
    )
    | Reg rg -> (
      let multiply = create_register_name() in
      let movedReg = create_register_name() in
      let result = create_register_name() in
      match varTyp with
      | IntArr -> (
        let movedInst = [BinOp (multiply, MulOp, Reg rg, Imm(ImmInt 4)); BinOp (movedReg, AddOp, Reg lhsReg, Reg multiply)] in
        (numInst @ movedInst @ [Load (result, movedReg)], Reg result)
      )
      | BoolArr -> (
        let movedInst = [BinOp (multiply, MulOp, Reg rg, Imm(ImmInt 1)); BinOp (movedReg, AddOp, Reg lhsReg, Reg multiply)] in
        (numInst @ movedInst @[Load (result, movedReg)], Reg result)
      )
      | Int | Bool -> (
        let _ = Printf.printf("Somethings Wrong #1\n") in
        ([], Reg result)
      )
    )    
    | Imm (ImmBool b) -> (
      let _ = Printf.printf("Somethings Wrong #2\n") in
      ([], Imm(ImmBool b))
    ) *)