open Program
open Ir
open Helper

(* The module for symbol table. Carefully think about what should be stored in
 * the symbol table for this IR translation phase. *)
module SymbolMap = Map.Make(String)

(* Let's assume that boolean is 1-byte and integer is 4-byte. *)
let sizeof ctyp =
  match ctyp with
  | CInt -> 4
  | CBool -> 1
  | CIntArr n -> 4 * n
  | CBoolArr n -> n

let rec extract_names args =
  match args with
  | [] -> []
  | (arg_typ, arg_name) :: tail_args -> arg_name :: extract_names tail_args

let run (p: program): ir_code =
  let (fname, ret_type, args, stmts) = p in
  let arg_regs = extract_names args in
  (* Example code for generating IR instructions. *)
  let r = create_register_name () in (* Defined in helper.ml *)
  let set_instr = Set (r, ImmInt 0) in
  let ret_instr = Ret (Reg r) in
  let instrs = [set_instr; ret_instr] in
  (fname, arg_regs, instrs)
