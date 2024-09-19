open Program
open Error

(* SymbolTable은 string - ctype_entry 연결 *)
(* type ctype = CVoid | CInt | CBool *)
type ctype_entry =
  | VarType of ctype
  | FuncType of ctype * ctype list

(* !!!!!!! SymbolTable !!!!!!! *)
module SymbolMap = Map.Make(String)

(* ------------------------------------ ctype 과 typ ------------------------------------ *)
(* During the semantic analysis, this type can be helpful. Why do we need this
 * even though 'ctype' is already defined? If you encounter a wrong expression
 * during the semantic analysis (for example "1 + true"), you cannot decide its
 * type but still may have to return something. *)

 (* ctype은 실제 타입 typ은 동적 타입 (Unknown 집중!) *)

type typ = Void | Int | Bool | Unknown

let ctyp_to_typ ctyp =
  match ctyp with
  | CVoid -> Void
  | CInt -> Int
  | CBool -> Bool

let typ_to_ctyp ctyp =
  match ctyp with
  | Void -> CVoid
  | Int -> CInt
  | Bool -> CBool
  | Unknown -> (* Raise exception *)
      failwith "Not allowed (You should not call this in such situation)"
(* -------------------------------------------------------------------------------------- *)

(* ------------------------------------ collect_vars ------------------------------------ *)
(* Record the type of variables into the symbol table *)
(* @Input : decl list * sym_tab *)
(* @Output : sym_tab *)

let rec collect_vars decls sym_tab =
  match decls with
  | [] -> sym_tab
  | (ctyp, vname) :: tail_decls ->

      (* vname(string) - VarType ctyp(ctype_entry) *)
      let next_sym_tab = SymbolMap.add vname (VarType ctyp) sym_tab in
      collect_vars tail_decls next_sym_tab

(* -------------------------------------------------------------------------------------- *)

(* ------------------------------------ collect_functionss ------------------------------------ *)
(* Record the type of functions into the symbol table *)

let rec filter_decls_to_ctyps decls =
  match decls with
  | [] -> []
  | (ctyp, vname) :: tails -> 
    ctyp :: filter_decls_to_ctyps tails

let rec collect_functions funcs sym_tab =
  match funcs with
  | [] -> sym_tab
  | (fname, retType, decls, stmts) :: tail_funcs ->
    (* fname(string) - FuncType retType ctypList(ctype_entry) *)
    let ctypList = filter_decls_to_ctyps decls in
    let next_sym_tab = SymbolMap.add fname (FuncType (retType , ctypList)) sym_tab in
    collect_functions tail_funcs next_sym_tab

(* -------------------------------------------------------------------------------------- *)

(* ------------------------------------ check_exp ------------------------------------ *)

(* Check expression 'e' and return detected semantic errors, along with the
 * decided type of 'e'. If the type of expression cannot be decided due to
 * semantic error, return 'Unknown' as its type. *)
let rec check_exp sym_tab e =
  match e with
  | ConstBool b -> ([], Bool)

  | ConstInt i -> ([], Int)

  | Var vName -> (
    let notInSymTab = not (SymbolMap.mem vName sym_tab) in
    
    if notInSymTab then
      ([UndefinedName vName], Unknown)
    else
      let varOrFunc = SymbolMap.find vName sym_tab in
      match varOrFunc with
      | FuncType (_, _) -> ([UsingFunctionAsVar vName], Unknown)
      | VarType ctyp -> ([], ctyp_to_typ ctyp)      
  )

  | Add (exp1, exp2)
  | Sub (exp1, exp2)
  | Mul (exp1, exp2)
  | Div (exp1, exp2) -> (
    let (err1, typ1) = check_exp sym_tab exp1 in
    let (err2, typ2) = check_exp sym_tab exp2 in
    
    if typ1 = Unknown then (err1, Unknown)
    else if typ2 = Unknown then (err2, Unknown)
    else if typ1 = Int && typ2 = Int then ([], Int)
    else ([OperandMismatch], Unknown)
  )

  | Neg exp -> (
    let (err, typ) = check_exp sym_tab exp in
    
    if typ = Unknown then (err, Unknown)
    else if typ = Int then ([], Int)
    else ([OperandMismatch], Unknown)
  )

  | LessEq (exp1, exp2)
  | LessThan (exp1, exp2)
  | GreaterEq (exp1, exp2)
  | GreaterThan (exp1, exp2) -> (
    let (err1, typ1) = check_exp sym_tab exp1 in
    let (err2, typ2) = check_exp sym_tab exp2 in
    
    if typ1 = Unknown then (err1, Unknown)
    else if typ2 = Unknown then (err2, Unknown)
    else if typ1 = Int && typ2 = Int then ([], Bool)
    else ([OperandMismatch], Unknown)
  )

  | And (exp1, exp2)
  | Or (exp1, exp2) -> (
    let (err1, typ1) = check_exp sym_tab exp1 in
    let (err2, typ2) = check_exp sym_tab exp2 in
    
    if typ1 = Unknown then (err1, Unknown)
    else if typ2 = Unknown then (err2, Unknown)
    else if typ1 = Bool && typ2 = Bool then ([], Bool)
    else ([OperandMismatch], Unknown)
  )

  | Not exp -> (
    let (err, typ) = check_exp sym_tab exp in
    
    if typ = Unknown then (err, Unknown)
    else if typ = Bool then ([], Bool)
    else ([OperandMismatch], Unknown)
  )

  | Equal (exp1, exp2)
  | NotEq (exp1, exp2) -> (
    let (err1, typ1) = check_exp sym_tab exp1 in
    let (err2, typ2) = check_exp sym_tab exp2 in
    
    if typ1 = Unknown then (err1, Unknown)
    else if typ2 = Unknown then (err2, Unknown)
    else if typ1 = typ2 then(
      if typ1 = Void then ([OperandMismatch], Unknown)
      else ([], Bool)
    )
    else ([OperandMismatch], Unknown)
  )

  | CallExp (fName, tryArgs) -> (
    let notInSymTab = not (SymbolMap.mem fName sym_tab) in
    
    if notInSymTab then
      ([UndefinedName fName], Unknown)
    else
      let varOrFunc = SymbolMap.find fName sym_tab in
      match varOrFunc with
      | VarType _ -> ([CallingVariable fName], Unknown)
      
      | FuncType (retType, answerArgs) -> (
        let len1 = List.length answerArgs in
        let len2 = List.length tryArgs in
        if len1 <> len2 then
          ([ArgNumMismatch], Unknown)
        else 
          check_function_call retType answerArgs tryArgs sym_tab
      )
  )

and
(* ctypList와 expList의 길이는 같다는 보증하에 *)
check_function_call retType answerArgs tryArgs sym_tab =
  match (answerArgs, tryArgs) with
  | ([], []) -> ([], ctyp_to_typ retType)
  | (headAnswer :: tailAnswers, headTry :: tailTrys) -> (
    let (err, tryTyp) = check_exp sym_tab headTry in
    
    if tryTyp = Unknown then (err, Unknown)
    else
      let tryTyp = typ_to_ctyp tryTyp in
      if tryTyp = headAnswer then
        check_function_call retType tailAnswers tailTrys sym_tab
      else 
        ([ArgTypeMismatch (headAnswer,tryTyp)], Unknown)
  )
  | (_::_, []) 
  | ([], _::_) -> ( 
    let _ = Printf.printf("Somethings Super Wrong") in
    ([],Unknown)
  ) 

(* ------------------------------------ check_functions ------------------------------------ *)

(* function에 대한 symbol table 받아 error 체크 후 errList 반환 *)
let rec check_statements sym_tab retType stmts errList =
  (* 변경없을 경우 호출 - check_statements sym_tab retType tail_stmts errList *)
  match stmts with
  | [] -> errList
  | LocalDecl (ctyp, vName) :: tail_stmts -> (
    let next_sym_tab = SymbolMap.add vName (VarType ctyp) sym_tab in
    check_statements next_sym_tab retType tail_stmts errList
  )

  | Assign (lhsName, exp) :: tail_stmts -> (
    let (err, rhsTyp) = check_exp sym_tab exp in
    if rhsTyp = Unknown then
      check_statements sym_tab retType tail_stmts (errList @ err)
    
    else
      let notInSymTab = not (SymbolMap.mem lhsName sym_tab) in
      
      if notInSymTab then
        check_statements sym_tab retType tail_stmts (errList @ [UndefinedName lhsName])
      else
        let varOrFunc = SymbolMap.find lhsName sym_tab in
        match varOrFunc with
        | FuncType (_, _) -> 
            check_statements sym_tab retType tail_stmts (errList @ [UsingFunctionAsVar lhsName])

        | VarType lhsCTyp ->
          let rhsCTyp = typ_to_ctyp rhsTyp in
          if lhsCTyp <> rhsCTyp then 
            check_statements sym_tab retType tail_stmts (errList @ [AssignMismatch (lhsCTyp, rhsCTyp)])
          else
            check_statements sym_tab retType tail_stmts errList
  )

  | Call (calledFname, expList) :: tail_stmts  -> (
    let (err, typ) = check_exp sym_tab (CallExp (calledFname, expList)) in
    if typ = Unknown then
      check_statements sym_tab retType tail_stmts (errList @ err)
    else
      check_statements sym_tab retType tail_stmts errList
  )

  | Return :: tail_stmts  -> (
    match retType with
    | CVoid -> check_statements sym_tab retType tail_stmts errList
    | CInt
    | CBool -> 
      check_statements sym_tab retType tail_stmts (errList @ [ReturnMismatch (retType, CVoid)])
  )

  | ReturnValue exp :: tail_stmts  -> (
    let (err, rhsTyp) = check_exp sym_tab exp in
    if rhsTyp = Unknown then
      check_statements sym_tab retType tail_stmts (errList @ err)
    
    else
      let rhsCTyp = typ_to_ctyp rhsTyp in
      if rhsCTyp <> retType then
        check_statements sym_tab retType tail_stmts (errList @ [ReturnMismatch (retType, rhsCTyp)])
      else
        check_statements sym_tab retType tail_stmts errList     
  )

  | If (cond, true_branch, false_branch) :: tail_stmts -> (
    let (err, typ) = check_exp sym_tab cond in
    let nextErrList =
      if typ = Unknown then errList @ err
      else if typ <> Bool then errList @ [OperandMismatch]
      else errList
    in
    let nextErrList2 = check_statements sym_tab retType true_branch nextErrList in
    let nextErrList3 = check_statements sym_tab retType false_branch nextErrList2 in
    check_statements sym_tab retType tail_stmts nextErrList3
  )
  | While (cond, body) :: tail_stmts -> (
    let (err, typ) = check_exp sym_tab cond in
    let nextErrList =
      if typ = Unknown then errList @ err
      else if typ <> Bool then errList @ [OperandMismatch]
      else errList
    in
    let nextErrList2 = check_statements sym_tab retType body nextErrList in
    check_statements sym_tab retType tail_stmts nextErrList2
  )

(* ------------------------------------------------------------------------------ *)

let rec set_func_tab global_sym_tab arguments = 
  collect_vars arguments global_sym_tab

let rec check_functions global_sym_tab funcs prevErrs =
  match funcs with
  | [] -> prevErrs
  | (fname, retType, arguments, stmts) :: tail_funcs ->  
    let func_sym_tab = set_func_tab global_sym_tab arguments in
    let nextErrs = check_statements func_sym_tab retType stmts prevErrs in
    check_functions global_sym_tab tail_funcs nextErrs

(* ------------------------------------ run ------------------------------------ *)

(* @Input : program *)
(* @Output : error list *)
let run (p: program) : error list =

  (* 0. 구조 분해 할당 type program = decl list * func list *)
  let (gdecls, funcs) = p in

  (* 1. Global 돌면서 Symboltable 채우기 *)
  let sym_tab = collect_vars gdecls SymbolMap.empty in

  (* 2. Function 돌면서 Symboltable 채우기 *)
  let global_sym_tab = collect_functions funcs sym_tab in

  (* 3. 에러 체크 *)
  check_functions global_sym_tab funcs []

(* let (ctyp, vname) = decl in
    let hasVName = SymbolMap.mem vname sym_tab in
    if hasVName then
        let whatType = SymbolMap.find vname sym_tab in
        match whatType with
        | FuncType (_, _) -> 
            let nextErrList = errList @ [UsingFunctionAsVar vname] in
            check_statements sym_tab fname tail_stmts nextErrList
        | VarType _ -> 
          let next_sym_tab = SymbolMap.add vname (VarType ctyp) sym_tab in
          check_statements next_sym_tab fname tail_stmts errList
    else
      let next_sym_tab = SymbolMap.add vname (VarType ctyp) sym_tab in
      check_statements next_sym_tab fname tail_stmts errList *)