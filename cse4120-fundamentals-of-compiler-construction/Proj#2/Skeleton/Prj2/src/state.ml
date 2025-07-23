open Ir

module StrMap = Map.Make(String)
module IntMap = Map.Make(struct type t = int let compare = compare end)

exception RuntimeError of string

let mem_brk = ref 0

let initialize () =
  mem_brk := 0

(* Possible kind of values in IR-level model *)
type value =
  | Int of int
  | Bool of bool
  | Ptr of int

(* Mapping from register name to value *)
module RegMap = StrMap
type register_map = value RegMap.t

(* Mapping from address to value *)
module Memory = IntMap
type memory = value IntMap.t

(* Mapping from code address to IR *)
module IRMap = IntMap

(* Mapping from label to code address *)
module LabelMap = StrMap

type code_addr = int

type state = register_map * memory * code_addr

type code_map = instr IRMap.t * code_addr LabelMap.t

type step_result =
  | Finished of value (* Program (function) successfully returned a value *)
  | Running of state (* Successful execution of one instruction *)

let string_of_value v =
  match v with
  | Bool b -> string_of_bool b
  | Int i -> string_of_int i
  | Ptr p -> "[Warning: Trying to print pointer value] " ^ string_of_int p

let value_of_string s =
  match s with
  | "true" -> Bool true
  | "false" -> Bool false
  | _ -> (try Int (int_of_string s) with _ -> failwith ("Invalid value: " ^ s))

let allocate size =
  let addr = !mem_brk in
  let _ = mem_brk := !mem_brk + size in
  Ptr addr

let load_from_memory addr mem =
  match addr with
  | Ptr p ->
    if p < 0 ||  p >= !mem_brk || not (Memory.mem p mem)
    then raise (RuntimeError "Invalid memory access")
    else Memory.find p mem
  | _ -> raise (RuntimeError "Type error (not pointer)")

let store_to_memory addr v mem =
  match addr with
  | Ptr p ->
    if p < 0 || p >= !mem_brk
    then raise (RuntimeError "Invalid memory access")
    else Memory.add p v mem
  | _ -> raise (RuntimeError "Type error (not pointer)")
