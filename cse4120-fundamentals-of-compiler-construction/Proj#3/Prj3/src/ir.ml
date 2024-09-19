open Printf

type register = string

type label = string

(* 'Immediate' means a constant in low-level languages. *)
type immediate = ImmInt of int | ImmBool of bool

(* An operand can be either register or immediate. *)
type operand = Reg of register | Imm of immediate

(* Kinds of unary operation *)
type unary_optype = NegOp | NotOp

(* Kinds of binary operation. Note that AndOp and OrOp are not needed. *)
type binary_optype =
    AddOp | SubOp | MulOp | DivOp (* Arithmetic operations *)
  | EqOp | NeqOp (* Equal and not-equal operations *)
  | LeqOp | LtOp (* Less-or-equal and less-than operations *)
  | GeqOp | GtOp (* Greater-or-equal and greater-than operations *)

type instr =
    Set of register * immediate (* Set (r, i) means "r = i" *)
  | Copy of register * register (* Copy (r1, r2) means "r2 = r1" (COMMENT FIXED) *)
  | LocalAlloc of register * int (* LocalAlloc (r, n) means "r = alloc(n)" *)
  | UnOp of register * unary_optype * operand (* Unary operation *)
  | BinOp of register * binary_optype * operand * operand (* Binary operation *)
  | Load of register * register (* Load (r1, r2) means "r1 = *r2" *)
  | Store of operand * register (* Store (v, r) means "*r = v" *)
  | Goto of label (* Jump to the target label *)
  | GotoIf of register * label (* Jump if the register value is true *)
  | GotoIfNot of register * label (* Jump if the register value is false *)
  | Label of label (* No operation. Used only to mark the position of label *)
  | Ret of operand (* Return a value *)

(* IR-level function := function name * arguments as registers * instructions *)
type ir_function = string * register list * instr list

(* This phase assumes that a program consists of only one function *)
type ir_code = ir_function

(**************************************************************************
 * Start of functions for converting IR code into string. You don't have to
 * understand the code below.
 * ************************************************************************)
let imm_to_str imm =
  match imm with
  | ImmInt i -> string_of_int i
  | ImmBool b -> string_of_bool b

let oprnd_to_str oprnd =
  match oprnd with
  | Reg r -> r
  | Imm imm -> imm_to_str imm

let unop_to_str optyp =
  match optyp with
  | NegOp -> "-"
  | NotOp -> "!"

let binop_to_str optyp =
  match optyp with
  | AddOp -> "+"
  | SubOp -> "-"
  | MulOp -> "*"
  | DivOp -> "/"
  | EqOp -> "=="
  | NeqOp -> "!="
  | LeqOp -> "<="
  | LtOp -> "<"
  | GeqOp -> ">="
  | GtOp -> ">"

let instr_to_str instr =
  match instr with
  | Set (r, i) -> sprintf "%s = %s" r (imm_to_str i)
  | Copy (r1, r2) -> sprintf "%s = %s" r2 r1 (* FIXED THE ORDER *)
  | LocalAlloc (r, sz) -> sprintf "%s = alloc(%d)" r sz
  | UnOp (r, op, v) -> sprintf "%s = %s %s" r (unop_to_str op) (oprnd_to_str v)
  | BinOp (r, op, v1, v2) ->
      let left_str = oprnd_to_str v1 in
      let binop_str = binop_to_str op in
      let right_str = oprnd_to_str v2 in
      sprintf "%s = %s %s %s" r left_str binop_str right_str
  | Load (r1, r2) -> sprintf "%s = load %s" r1 r2
  | Store (v, r) -> sprintf "store %s, %s" (oprnd_to_str v) r
  | Goto l -> sprintf "goto %s" l
  | GotoIf (r, l) -> sprintf "if %s then goto %s" r l
  | GotoIfNot (r, l) -> sprintf "ifnot %s then goto %s" r l
  | Label l -> sprintf "label %s" l
  | Ret v -> sprintf "ret %s" (oprnd_to_str v)

let to_str (ir: ir_code): string =
  let (fname, args, instrs) = ir in
  let arg_str = String.concat ", " args in
  let instr_str = List.map instr_to_str instrs |> String.concat ",\n  " in
  sprintf "%s(%s) : [\n  %s\n]" fname arg_str instr_str
