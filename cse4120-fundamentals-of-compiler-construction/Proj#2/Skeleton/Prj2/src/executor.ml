open Printf
open Ir
open State
open Eval

let check_true v =
  match v with
  | Bool b -> b
  | _ -> raise (RuntimeError "Type error (not boolean)")

let exec_instr label_map instr reg_map mem pc =
  match instr with
  | Set (r, i) ->
      Running (RegMap.add r (eval_immediate i) reg_map, mem, pc + 1)
  | Copy (r1, r2) ->
      Running (RegMap.add r2 (RegMap.find r1 reg_map) reg_map, mem, pc + 1)
  | LocalAlloc (r, n) ->
      Running (RegMap.add r (allocate n) reg_map, mem, pc + 1)
  | UnOp (r, op_typ, oprnd) ->
      let v = eval_operand oprnd reg_map in
      Running (RegMap.add r (unary_op op_typ v) reg_map, mem, pc + 1)
  | BinOp (r, op_typ, oprnd1, oprnd2) ->
      let v1 = eval_operand oprnd1 reg_map in
      let v2 = eval_operand oprnd2 reg_map in
      Running (RegMap.add r (binary_op op_typ v1 v2) reg_map, mem, pc + 1)
  | Load (r1, r2) ->
      let addr = RegMap.find r2 reg_map in
      let loaded_v = load_from_memory addr mem in
      Running (RegMap.add r1 loaded_v reg_map, mem, pc + 1)
  | Store (oprnd, r) ->
      let v = eval_operand oprnd reg_map in
      let addr = RegMap.find r reg_map in
      Running (reg_map, store_to_memory addr v mem, pc + 1)
  | Goto l -> Running (reg_map, mem, LabelMap.find l label_map)
  | GotoIf (r, l) ->
      let v = RegMap.find r reg_map in
      let jmp_addr = LabelMap.find l label_map in
      if check_true v then Running (reg_map, mem, jmp_addr)
      else Running (reg_map, mem, pc + 1)
  | GotoIfNot (r, l) ->
      let v = RegMap.find r reg_map in
      let jmp_addr = LabelMap.find l label_map in
      if not (check_true v) then Running (reg_map, mem, jmp_addr)
      else Running (reg_map, mem, pc + 1)
  | Label _ -> Running (reg_map, mem, pc + 1)
  | Ret oprnd -> Finished (eval_operand oprnd reg_map)

let rec step ir_map label_map reg_map mem pc =
  let instr = IRMap.find pc ir_map in
  match exec_instr label_map instr reg_map mem pc with
  | Finished v -> print_endline (string_of_value v)
  | Running (reg_map', mem', pc') -> step ir_map label_map reg_map' mem' pc'

let rec gen_code_map instrs (ir_map, label_map) idx =
  match instrs with
  | [] -> (ir_map, label_map)
  | head_instr :: tail_instrs ->
      let ir_map = IRMap.add idx head_instr ir_map in
      let label_map =
        match head_instr with
        | Label l -> LabelMap.add l idx label_map
        | _ -> label_map
      in
      gen_code_map tail_instrs (ir_map, label_map) (idx + 1)

let rec initialize_regs arg_regs arg_strs reg_map =
  match arg_regs, arg_strs with
  | [], [] -> reg_map
  | [], _ | _, [] -> failwith "Invalid number of argument provided"
  | head_reg :: tail_regs, head_str :: tail_strs ->
      let reg_map = RegMap.add head_reg (value_of_string head_str) reg_map in
      initialize_regs tail_regs tail_strs reg_map

let run (ir: ir_code) (arg_strs: string list): unit =
  let _ = State.initialize () in
  let (_, arg_regs, instrs) = ir in
  let ir_map, label_map = gen_code_map instrs (IRMap.empty, LabelMap.empty) 0 in
  let reg_map = initialize_regs arg_regs arg_strs RegMap.empty in
  step ir_map label_map reg_map Memory.empty 0
