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
  | IntOrBool

type TypeEnv = Map<string, Type>
type TypeEq = Type * Type
type TypeEqList = TypeEq list

type Substitution = Map<string, Type>

module Type =
  // @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ Helper Fuctions
  let typnum = ref 0
  let create_typevar () =
    let typvar = sprintf "$t%d" typnum.Value in
    typnum.Value <- typnum.Value + 1
    TyVar typvar

  // Ensure TyVar to be left
  let swapEq (equation : TypeEq) : TypeEq =
    let (t1, t2) = equation in
    match t1 with
    | Int | Bool | IntOrBool | Func _-> (t2, t1)
    | TyVar _ -> equation
  
  let rec toString (typ: Type): string =
    match typ with
    | Int -> "int"
    | Bool -> "bool"
    | IntOrBool -> "int or bool"
    | TyVar s -> s
    | Func (t1, t2) -> sprintf "(%s) -> (%s)" (toString t1) (toString t2)
  
  and printTypeEqList (l : TypeEq list) : _ =
    match l with
    | [] -> ()
    | (typ1, typ2) :: tailL -> 
      let _ = printTypeEqList tailL in
      let printthis = sprintf "### (%s) = (%s)" (toString typ1) (toString typ2) in
      printfn "%s" printthis

  and printSubstitution (keylist) (substitution) =
    // let _ = printfn "@@@@@@ Map size: %d @@@@@@" (Map.count substitution) in
    match keylist with
    | [] -> ()
    | key :: tail ->
      let _ = printSubstitution tail substitution in
      let printthis = sprintf "--- (%s) -> (%s)" (key) (toString (Map.find key substitution)) in
      printfn "%s" printthis

  let getKeyList (substitution : Substitution) : string list =
    substitution |> Map.keys |> Seq.toList in

  // @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ Main Fuctions

  let rec GEN (originEnv : TypeEnv) (originExp : Exp) (originType : Type) : TypeEqList = 
    match originExp with
      | Num _ -> [(originType, Int)]
      | True | False -> [(originType, Bool)]
      
      | Var varname -> 
        match Map.tryFind varname originEnv with
        | Some typ -> [(originType, typ)]
        | None -> raise TypeError

      | Neg exp -> 
        [(originType, Int)] @ (GEN originEnv exp Int)

      | Add (exp1, exp2) | Sub (exp1, exp2) ->
        [(originType, Int)] @ (GEN originEnv exp1 Int) @ (GEN originEnv exp2 Int)

      | LessThan (exp1, exp2) | GreaterThan (exp1, exp2) ->
        [(originType, Bool)] @ (GEN originEnv exp1 Int) @ (GEN originEnv exp2 Int)

      | IfThenElse (condition, trueExp, falseExp) ->
        (GEN originEnv condition Bool) @ (GEN originEnv trueExp originType) @ (GEN originEnv falseExp originType)

      | LetIn (varName, assignExp, contentExp) ->
        let assignExpTV = create_typevar() in
        let assignEnv = Map.add varName assignExpTV originEnv in
        GEN assignEnv contentExp originType @ GEN originEnv assignExp assignExpTV

      | LetFunIn (funcName, argName, assignExp, contentExp) ->
        let argTV = create_typevar() in
        let returnTV = create_typevar() in

        let argEnv = Map.add argName argTV originEnv in
        let funcEnv = Map.add funcName (Func (argTV, returnTV)) originEnv in
        GEN argEnv assignExp returnTV @ GEN funcEnv contentExp originType 

      | LetRecIn (funcName, argName, assignExp, contentExp) ->
        let argTV = create_typevar() in
        let returnTV = create_typevar() in

        let argEnv = Map.add argName argTV originEnv in
        let recArgEnv = Map.add funcName (Func (argTV, returnTV)) argEnv in 
        let funcEnv = Map.add funcName (Func (argTV, returnTV)) originEnv in
        GEN recArgEnv assignExp returnTV @ GEN funcEnv contentExp originType
      
      | Fun (argName, assignExp) ->
        let argTV = create_typevar() in
        let returnTV = create_typevar() in
        let argEnv = Map.add argName argTV originEnv in
        [(originType, Func (argTV, returnTV))] @ GEN argEnv assignExp returnTV

      | App (fName, argExp) ->
        let argTV = create_typevar() in
        GEN originEnv fName (Func (argTV, originType)) @ GEN originEnv argExp argTV

      // Need AdHoc Overloading !!!
      | Equal (exp1, exp2) | NotEq (exp1, exp2) ->
        let ibTV = create_typevar() in
        [(originType, Bool)] @ GEN originEnv exp1 ibTV @ GEN originEnv exp2 ibTV @ [(ibTV, IntOrBool)]
  
  let rec APPLY (orgS : Substitution) (targetType : Type) : Type =
    match targetType with
    | Int | Bool | IntOrBool -> targetType
    | TyVar varname ->
      match Map.tryFind varname orgS with
        | Some typ -> typ
        | None -> targetType
    | Func (t1, t2) -> Func((APPLY orgS t1), (APPLY orgS t2))

  let rec EXTEND (equation : TypeEq) (orgS : Substitution) : Substitution =
    match (swapEq equation) with
    | (Int, Int) | (Bool, Bool) -> orgS
    | (Int, IntOrBool) | (Bool, IntOrBool) -> orgS
    | (IntOrBool, Int) | (IntOrBool, Bool) -> orgS

    | (TyVar tv1, rt) ->
      match rt with
      | Int | Bool | IntOrBool -> addToSubstitution (getKeyList orgS) tv1 rt orgS
      | TyVar tv2 ->
        if tv1 = tv2 then orgS 
        else addToSubstitution (getKeyList orgS) tv1 rt orgS
      | Func (t1,t2) ->
        if (isTAinTB (TyVar tv1) t1) then raise TypeError
        else if (isTAinTB (TyVar tv1) t2) then raise TypeError
        else 
          addToSubstitution (getKeyList orgS) tv1 rt orgS

    | (Func (lt1, lt2), Func(rt1, rt2)) ->
      let typeEq1 : TypeEq = (lt1, rt1) in
      let typeEq2 : TypeEq = (lt2, rt2) in
      UNIFY typeEq1 (EXTEND typeEq2 orgS)
    | _ -> 
      // let _ = printTypeEqList [swapEq equation] in
      raise TypeError

  and UNIFY (equation : TypeEq) (mainS : Substitution) : TypeEnv =
    let (t1, t2) = equation in
    let newEq : TypeEq = ((APPLY mainS t1), (APPLY mainS t2)) in
    EXTEND newEq mainS
  
  and addToSubstitution (keys) (addedTV : string) (convertT : Type) (mainS: Substitution) : Substitution =
    match keys with
    | [] -> Map.add addedTV convertT mainS
    | key :: tail ->
      let originT = Map.find key mainS in
      let newT = changeAllEq originT addedTV convertT in
      let newS = Map.add key newT mainS in
      addToSubstitution tail addedTV convertT newS
      
  and changeAllEq (originT : Type) (addedTV : string) (convertT : Type) : Type =
    match originT with
    | TyVar cmpVar ->
      if cmpVar = addedTV then convertT else originT
    | Func (t1, t2) -> Func((changeAllEq t1 addedTV convertT), (changeAllEq t2 addedTV convertT))
    | _ -> originT

  and isTAinTB (TA) (TB) : bool =
    match TB with
    | Int | Bool | IntOrBool -> false
    | TyVar _ -> TA = TB
    | Func (t1, t2) ->
      if (isTAinTB TA t1) then true
      else if (isTAinTB TA t2) then true
      else false

  let rec iterateEqList (typeEqList) (substitution) =
    match typeEqList with
    | [] -> substitution
    | eq :: tail -> 
      iterateEqList tail (UNIFY eq substitution)

  // Return the inferred type of the input program.
  let infer (prog: Program) : Type =
    let (TyVar programTypeStr) = create_typevar () in
    
    let generatedEqList = GEN Map.empty prog (TyVar programTypeStr) in
    let generatedSubstitution = iterateEqList generatedEqList Map.empty in
    
    // @@@@@@@ Debug
    // let _ = printTypeEqList generatedEqList in
    // let keysList = generatedSubstitution |> Map.keys |> Seq.toList in
    // let _ = printSubstitution (getKeyList generatedSubstitution) generatedSubstitution in
    
    Map.find programTypeStr generatedSubstitution