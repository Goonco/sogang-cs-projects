open Program
open Ir

(* Example code to illustrate how to define your own custom type and define a
 * Set to store them. *)

(* Reaching definition (you can fix the following definition, of course). *)
type rdef = instr

(* Now you can define "set of reaching definition" as follow. *)
module RDSet = Set.Make(struct
  type t = rdef
  let compare = Pervasives.compare
end)

module AESet = Set.Make(struct
  type t = rdef
  let compare = Pervasives.compare
end)

module DCSet = Set.Make(String)

(* --------------------- Helper Functions --------------------- *)

let print_single_RD rd_set =
  let rd_str = RDSet.fold (fun elem acc -> acc ^ instr_to_str elem ^ "; ") rd_set "" in
  Printf.printf "# %s\n" rd_str

let print_single_AE rd_set =
  let rd_str = AESet.fold (fun elem acc -> acc ^ instr_to_str elem ^ "; ") rd_set "" in
  Printf.printf "# %s\n" rd_str

let print_single_DC rd_set =
  let rd_str = DCSet.fold (fun elem acc -> if acc = "" then elem else acc ^ "; " ^ elem) rd_set "" in
  Printf.printf "# %s\n" rd_str

let rec printRD rdlist =
  match rdlist with
  | [] -> Printf.printf "------------------------\n"
  | curRD :: nextRDs -> (
    let _ = print_single_RD curRD in
    printRD nextRDs
  )

let rec printAE rdlist =
  match rdlist with
  | [] -> Printf.printf "------------------------\n"
  | curRD :: nextRDs -> (
    let _ = print_single_AE curRD in
    printAE nextRDs
  )

let rec printDC rdlist =
  match rdlist with
  | [] -> Printf.printf "------------------------\n"
  | curRD :: nextRDs -> (
    let _ = print_single_DC curRD in
    printDC nextRDs
  )

let test () =
  let x = RDSet.empty in
  let y = RDSet.add (Set ("r", ImmInt 0)) x in
  let union = RDSet.union x y in
  let is_subset = RDSet.subset x union in
  Printf.printf "is_subset: %b\n" is_subset

let calculateNums optyp i1 i2 =
  match optyp with
  | AddOp -> i1 + i2
  | SubOp -> i1 - i2
  | MulOp -> i1 * i2
  | DivOp -> i1 / i2
  | _ -> (
    let _ = Printf.printf "Error : calculateNums\n" in
    -1
  )
  
let calculateBools optyp i1 i2 =
  match optyp with
  | LeqOp -> i1 <= i2
  | LtOp -> i1 < i2
  | GeqOp -> i1 >= i2
  | GtOp -> i1 > i2
  | _ -> (
    let _ = Printf.printf "Error : calculateBools\n" in
    false
  )
  
let calculateMix optyp imm1 imm2 =
  match imm1, imm2 with
  | ImmInt i1, ImmInt i2 -> (
    match optyp with
    | EqOp -> i1 = i2
    | NeqOp -> i1 <> i2
    | _ -> (
    let _ = Printf.printf "Error : calculateMix\n" in
    false
  )
  )
  | ImmBool i1, ImmBool i2 -> (
    match optyp with
    | EqOp -> i1 = i2
    | NeqOp -> i1 <> i2
    | _ -> (
    let _ = Printf.printf "Error : calculateMix\n" in
    false
  )
  )
  | _, _ -> (
    let _ = Printf.printf "Error : calculateMix\n" in
    false
  )

let calculateBinOp optyp imm1 imm2 =
  match optyp with
  | AddOp | SubOp | MulOp | DivOp ->
    let i1, i2 = match imm1, imm2 with ImmInt i1, ImmInt i2 -> i1, i2 | _, _ -> 0, 0 in
    Imm (ImmInt (calculateNums optyp i1 i2))
  | LeqOp | LtOp | GeqOp | GtOp ->
    let i1, i2 = match imm1, imm2 with ImmInt i1, ImmInt i2 -> i1, i2 | _, _ -> 0, 0 in
    Imm (ImmBool (calculateBools optyp i1 i2))
  | EqOp | NeqOp -> Imm (ImmBool (calculateMix optyp imm1 imm2))

let rec reverseList lst acc =
  match lst with
  | [] -> acc
  | hd :: tl -> reverseList tl (hd :: acc)

(* --------------------- Copy Propogation & Common Subexpression Elimination --------------------- *)

(* let checkCornerCase currentInstr filteredAE =
  match currentInstr with
  | UnOp (reg1, _, Reg reg2) -> (
    if reg1 = reg2 then filteredAE
    else AESet.add currentInstr filteredAE
  )
  | BinOp (reg, _, Reg r1, Reg r2) -> (
    if r1 = reg || r2 = reg then filteredAE
    else AESet.add currentInstr filteredAE
  )
  | BinOp (reg1, _, Reg reg2, _) | BinOp (reg1, _, _, Reg reg2) -> (
    if reg1 = reg2 then filteredAE
    else AESet.add currentInstr filteredAE
  )
  | _ -> AESet.add currentInstr filteredAE

let transferAE currentInstr prevAE =
  match currentInstr with
  | Set (reg, _) | Copy (_, reg) | UnOp (reg, _, _) | BinOp (reg, _, _, _) -> (
      let filteredAE = AESet.filter (function
        | Copy (r, _) | UnOp (_, _, Reg r) | BinOp (_, _, Reg r, _) | BinOp (_, _, _, Reg r) when r = reg -> false
        | _ -> true
      ) prevAE in
      
      checkCornerCase currentInstr filteredAE
    )
  | _ -> prevAE

let rec initAETable instrList prevAE listAE = 
  match instrList with
  | [] -> listAE
  | curInstr :: nextInstrs -> (
      let nextAE = transferAE curInstr prevAE in
      initAETable nextInstrs nextAE (listAE @ [nextAE])
    ) *)

(* --------------------- Deadcode Elmination --------------------- *)

let transferDC currentInstr prevDC =
  match currentInstr with
  | Ret opr -> (
    match opr with
    | Reg regR -> DCSet.add regR prevDC
    | Imm _ -> prevDC
  )
  | Set (reg, _) -> (
    let filteredDC = DCSet.filter (fun elem -> elem <> reg) prevDC in
    filteredDC
  )
  | Load (regL, regR) | Copy (regR, regL) -> (
    let filteredDC = DCSet.filter (fun elem -> elem <> regL) prevDC in
    DCSet.add regR filteredDC
  )
 | UnOp (reg, _, opr) -> (
    let filteredDC = DCSet.filter (fun elem -> elem <> reg) prevDC in
    match opr with
    | Reg regR -> DCSet.add regR filteredDC
    | Imm _ -> filteredDC
  )
  | BinOp (reg,_, opr1, opr2) -> (
    let filteredDC = DCSet.filter (fun elem -> elem <> reg) prevDC in
    match opr1, opr2 with
    | Reg rg1, Reg rg2 -> (
      let tmp = DCSet.add rg1 filteredDC in
      DCSet.add rg2 tmp
    )
    | Reg rg1, Imm im1 | Imm im1, Reg rg1 -> DCSet.add rg1 filteredDC
    | Imm imm1, imm2 -> filteredDC
  )
  | GotoIf (reg, _) | GotoIfNot (reg, _) -> DCSet.add reg prevDC
  | Store (opr, reg) -> (
    let filteredDC = DCSet.add reg prevDC in
    match opr with
    | Reg regR -> DCSet.add regR filteredDC
    | Imm _ -> filteredDC
  )
  | _ -> prevDC

(* 거꾸로된 instList 받고 똑바로된 DClist *)
let rec initDCTable reversedList prevDC listDC =
  match reversedList with
  | [] -> listDC
  | curInstr :: nextInstrs -> (
      let nextDC = transferDC curInstr prevDC in
      initDCTable nextInstrs nextDC (listDC @ [nextDC])
    )

let rec handleDCJump instrList originDCList newDCList feedbackDC labelName afterLabel =
  match instrList, originDCList with
  | [], [] -> newDCList
  | curInstr :: nextInstrs, curDC :: nextDCs -> (
    if afterLabel then
      let newDC = transferDC curInstr (DCSet.union feedbackDC curDC) in
      handleDCJump nextInstrs nextDCs (newDCList @ [newDC]) feedbackDC labelName true
    else
      match curInstr with
      | Goto (lb) | GotoIf (_, lb) | GotoIfNot (_, lb) -> (
        if lb = labelName then (
          let newDC = transferDC curInstr (DCSet.union feedbackDC curDC) in
          handleDCJump nextInstrs nextDCs (newDCList @ [newDC]) feedbackDC labelName true
        )
        else handleDCJump nextInstrs nextDCs (newDCList @ [curDC]) feedbackDC labelName false
      )
      | _ -> handleDCJump nextInstrs nextDCs (newDCList @ [curDC]) feedbackDC labelName false
  )

(* 거꾸로된 instList 거꾸로된 DCList 올바른 DC List *)
let rec feedbackDCTable totalInst instrList totalDC dcList =
  match instrList, dcList with
  | [], [] -> totalDC
  | curInstr :: nextInstrs, curDC :: nextDCs -> (
    match curInstr with
    | Label (label) ->
      feedbackDCTable totalInst nextInstrs (handleDCJump totalInst totalDC [] curDC label false) nextDCs
    | _ -> feedbackDCTable totalInst nextInstrs totalDC nextDCs
  )

let findRegInDC targetDC regName =
  DCSet.exists (fun elem -> elem = regName) targetDC
  
let rec deadcodeEliminate originInsts optInsts prevDC dcList changed =
  match originInsts, dcList with
  | [], [] -> (optInsts, changed)
  | curInst :: nextInsts, curDC :: nextDCs -> (
    match curInst with
    | Set (reg, _) | Copy (_, reg) | UnOp (reg, _, _) | BinOp (reg, _, _, _) -> (
      let flag = findRegInDC prevDC reg in

      if not flag then 
        deadcodeEliminate nextInsts optInsts curDC nextDCs true
      else 
        deadcodeEliminate nextInsts ([curInst] @ optInsts) curDC nextDCs changed
    )
    | _ -> deadcodeEliminate nextInsts ([curInst] @ optInsts) curDC nextDCs changed
  )

(* --------------------- Constant Propogation & Constant Folding --------------------- *)

let findRegInRD curRD regName =
  let filteredRD = RDSet.filter (function
        | Set (r, _) | Copy (_, r) | BinOp (r, _, _, _) when r = regName -> true
        | _ -> false
      ) curRD in
  
  if RDSet.cardinal filteredRD = 1 then (
    match RDSet.choose filteredRD with
    | Set (reg, imm) -> (imm, true)
    | _ -> (ImmInt (-1), false)
  )
  else  (ImmInt (-1), false)

let rec constPropAndFold originInsts optInsts rdList changed =
  match originInsts, rdList with
  | [], [] -> (optInsts, changed)
  | curInst :: nextInsts, curRD :: nextRDs -> (
    match curInst with
    | Copy (regRight, regLeft) -> (
      let (imm, flag) = findRegInRD curRD regRight in

      if flag then
          constPropAndFold nextInsts (optInsts @ [Set (regLeft, imm)]) nextRDs true
      else
        constPropAndFold nextInsts (optInsts @ [curInst]) nextRDs changed
    )
    | UnOp (regLeft, optType, opr) -> (
      match opr with
      | Reg regRight -> (
        let (imm, flag) = findRegInRD curRD regRight in

        if flag then
          constPropAndFold nextInsts (optInsts @ [UnOp (regLeft, optType,Imm (imm))]) nextRDs true
        else
          constPropAndFold nextInsts (optInsts @ [curInst]) nextRDs changed
      )
      | Imm immRight ->(
        match optType, immRight with
        | NegOp, ImmInt num -> constPropAndFold nextInsts (optInsts @ [Set (regLeft, ImmInt (-num))]) nextRDs true
        | NotOp, ImmBool flag -> constPropAndFold nextInsts (optInsts @ [Set (regLeft, ImmBool (not flag))]) nextRDs true
        | _, _ -> (
          let _ = Printf.printf "Somethings Wrong\n" in
          constPropAndFold nextInsts (optInsts @ [curInst]) nextRDs changed
        )
      )
    )
    | BinOp (regLeft, optType, oprLeft, oprRight) -> (
      match (oprLeft, oprRight) with
      | (Reg regL, Reg regR) -> (
        let (imm1, flag1) = findRegInRD curRD regL in
        let (imm2, flag2) = findRegInRD curRD regR in
        
        if flag1 && flag2 then
          constPropAndFold nextInsts (optInsts @ [BinOp (regLeft, optType,Imm (imm1),Imm (imm2))]) nextRDs true
        else if flag1 then
          constPropAndFold nextInsts (optInsts @ [BinOp (regLeft, optType,Imm (imm1),oprRight)]) nextRDs true
        else if flag2 then
          constPropAndFold nextInsts (optInsts @ [BinOp (regLeft, optType,oprLeft,Imm (imm2))]) nextRDs true
        else
          constPropAndFold nextInsts (optInsts @ [curInst]) nextRDs changed
      )
      | (Reg regL, Imm immR) -> (
        let (imm1, flag1) = findRegInRD curRD regL in
        
        if flag1 then
          constPropAndFold nextInsts (optInsts @ [BinOp (regLeft, optType,Imm (imm1),oprRight)]) nextRDs true
        else
          constPropAndFold nextInsts (optInsts @ [curInst]) nextRDs changed
      )
      | (Imm immL, Reg regR) -> (
        let (imm2, flag2) = findRegInRD curRD regR in
        
        if flag2 then
          constPropAndFold nextInsts (optInsts @ [BinOp (regLeft, optType,oprLeft,Imm (imm2))]) nextRDs true
        else
          constPropAndFold nextInsts (optInsts @ [curInst]) nextRDs changed
      )
      | (Imm immL, Imm immR) -> (
        let Imm (foldingRes) = calculateBinOp optType immL immR in
        constPropAndFold nextInsts (optInsts @ [Set (regLeft, foldingRes)]) nextRDs true
      )
    )
    | _ -> constPropAndFold nextInsts (optInsts @ [curInst]) nextRDs changed
  )

let transferRD currentInstr prevRD =
  match currentInstr with
  | Set (reg, _) | Copy (_, reg) | UnOp (reg, _, _) | BinOp (reg, _, _, _) -> (
      let filteredRD = RDSet.filter (function
        | Set (r, _) | Copy (_, r) | UnOp (r, _, _) | BinOp (r, _, _, _) when r = reg -> false
        | _ -> true
      ) prevRD in
      RDSet.add currentInstr filteredRD
    )
  | _ -> prevRD

let rec initRDTable instrList prevRD listRD = 
  match instrList with
  | [] -> listRD
  | curInstr :: nextInstrs -> (
      let nextRD = transferRD curInstr prevRD in
      initRDTable nextInstrs nextRD (listRD @ [nextRD])
    )

let rec handleRDJump instrList originRDList newRDList feedbackRD labelName afterLabel =
  match instrList, originRDList with
  | [], [] -> newRDList
  | curInstr :: nextInstrs, curRD :: nextRDs -> (
    if afterLabel then
      let newRD = transferRD curInstr (RDSet.union feedbackRD curRD) in
      handleRDJump nextInstrs nextRDs (newRDList @ [newRD]) feedbackRD labelName true
    else
      match curInstr with
      | Label (lb) -> (
        if lb = labelName then handleRDJump nextInstrs nextRDs (newRDList @ [curRD]) feedbackRD labelName true
        else handleRDJump nextInstrs nextRDs (newRDList @ [curRD]) feedbackRD labelName false
      )
      | _ -> handleRDJump nextInstrs nextRDs (newRDList @ [curRD]) feedbackRD labelName false
  )

let rec feedbackRDTable totalInst instrList totalRD rdList =
  match instrList, rdList with
  | [], [] -> totalRD
  | curInstr :: nextInstrs, curRD :: nextRDs -> (
    match curInstr with
    | Goto (label) | GotoIfNot (_, label) | GotoIf (_, label) -> 
      feedbackRDTable totalInst nextInstrs (handleRDJump totalInst totalRD [] curRD label false) nextRDs
    | _ -> feedbackRDTable totalInst nextInstrs totalRD nextRDs
  )

let rec runUntilNoChange instrList = 
  let initRD = initRDTable instrList RDSet.empty [] in
  let fbRD = feedbackRDTable instrList instrList initRD initRD in
  let (optimizedInst, isChanged) = constPropAndFold instrList [] fbRD false in

  let revOpt = (reverseList optimizedInst []) in
  let initDC = initDCTable revOpt DCSet.empty [] in
  let fbDC = feedbackDCTable revOpt revOpt initDC initDC in
  let (optimizedInst2, isChanged2) = deadcodeEliminate revOpt [] DCSet.empty fbDC isChanged in

  if isChanged then 
    runUntilNoChange optimizedInst2
  else 
    optimizedInst2

let run (ir: ir_code): ir_code =
  let (fname, args, instrList) = ir in
  let optimizedInst = runUntilNoChange instrList in
  (fname, args, optimizedInst)
