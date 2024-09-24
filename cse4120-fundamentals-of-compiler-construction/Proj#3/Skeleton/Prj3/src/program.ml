open Printf

type exp =
  | ConstBool of bool
  | ConstInt of int
  | Var of string
  | Arr of string * exp (* Arr (x, e) means x[e] *)
  | Add of exp * exp
  | Sub of exp * exp
  | Mul of exp * exp
  | Div of exp * exp
  | Neg of exp
  | Equal of exp * exp
  | NotEq of exp * exp
  | LessEq of exp * exp
  | LessThan of exp * exp
  | GreaterEq of exp * exp
  | GreaterThan of exp * exp
  | And of exp * exp
  | Or of exp * exp
  | Not of exp

type ctype = CInt | CBool | CIntArr of int | CBoolArr of int

(* Variable declaration := name * type *)
type decl = ctype * string

(* L-value means expression that can come at the left side of an assignment *)
type lvalue =
    LVar of string
  | LArr of string * exp

type stmt =
    LocalDecl of decl
  | Assign of lvalue * exp
  | ReturnValue of exp
  | If of exp * stmt list * stmt list
  | While of exp * stmt list

(* Function := function name * argument declarations * statements *)
type func = string * ctype * decl list * stmt list

(* This phase assumes that a program consists of only one function *)
type program = func

(**********************************************************************
 * Start of functions for converting AST into string. You don't have to
 * understand the code below.
 * ********************************************************************)

let rec exp_to_str exp =
  match exp with
  | ConstBool true -> "true"
  | ConstBool false -> "false"
  | ConstInt i -> string_of_int i
  | Var vname -> vname
  | Arr (vname, e_idx) -> sprintf "%s[%s]" vname (exp_to_str e_idx)
  | Add (e1, e2) -> sprintf "(%s + %s)" (exp_to_str e1) (exp_to_str e2)
  | Sub (e1, e2) -> sprintf "(%s - %s)" (exp_to_str e1) (exp_to_str e2)
  | Mul (e1, e2) -> sprintf "(%s * %s)" (exp_to_str e1) (exp_to_str e2)
  | Div (e1, e2) -> sprintf "(%s / %s)" (exp_to_str e1) (exp_to_str e2)
  | Neg e -> sprintf "-%s" (exp_to_str e)
  | Equal (e1, e2) -> sprintf "(%s == %s)" (exp_to_str e1) (exp_to_str e2)
  | NotEq (e1, e2) -> sprintf "(%s != %s)" (exp_to_str e1) (exp_to_str e2)
  | LessEq (e1, e2) -> sprintf "(%s <= %s)" (exp_to_str e1) (exp_to_str e2)
  | LessThan (e1, e2) -> sprintf "(%s < %s)" (exp_to_str e1) (exp_to_str e2)
  | GreaterEq (e1, e2) -> sprintf "(%s >= %s)" (exp_to_str e1) (exp_to_str e2)
  | GreaterThan (e1, e2) -> sprintf "(%s > %s)" (exp_to_str e1) (exp_to_str e2)
  | And (e1, e2) -> sprintf "(%s && %s)" (exp_to_str e1) (exp_to_str e2)
  | Or (e1, e2) -> sprintf "(%s || %s)" (exp_to_str e1) (exp_to_str e2)
  | Not e -> sprintf "!%s" (exp_to_str e)

let ctype_to_str typ =
  match typ with
  | CInt -> "int"
  | CBool -> "bool"
  | CIntArr n -> sprintf "int[%d]" n
  | CBoolArr n -> sprintf "bool[%d]" n

let decl_to_str decl =
  let (typ, vname) = decl in
  match typ with
  | CInt -> sprintf "int %s" vname
  | CBool -> sprintf "bool %s" vname
  | CIntArr n -> sprintf "int %s[%d]" vname n
  | CBoolArr n -> sprintf "bool %s[%d]" vname n

let lval_to_str lv =
  match lv with
  | LVar v -> v
  | LArr (v, e) -> sprintf "%s[%s]" v (exp_to_str e)

let rec stmt_to_str indent stmt =
  match stmt with
  | LocalDecl decl -> sprintf "%s%s" indent (decl_to_str decl)
  | Assign (lv, e) -> sprintf "%s%s = %s" indent (lval_to_str lv) (exp_to_str e)
  | ReturnValue e -> sprintf "%sreturn %s" indent (exp_to_str e)
  | If (e, s1, s2) ->
      let e_str = exp_to_str e in
      let s1_lines = List.map (stmt_to_str (indent ^ "  ")) s1 in
      let s1_str = String.concat ",\n" s1_lines in
      let s2_lines = List.map (stmt_to_str (indent ^ "  ")) s2 in
      let s2_str = String.concat ",\n" s2_lines in
      sprintf "%sif (%s) [\n%s\n%s] else [\n%s\n%s]"
        indent e_str s1_str indent s2_str indent
  | While (e, s) ->
      let e_str = exp_to_str e in
      let s_lines = List.map (stmt_to_str (indent ^ "  ")) s in
      let s_str = String.concat ",\n" s_lines in
      sprintf "%swhile (%s) [\n%s\n%s]" indent e_str s_str indent

let func_to_str f =
  let fname, ret_typ, args, stmts = f in
  let ret_str = ctype_to_str ret_typ in
  let arg_str = List.map decl_to_str args |> String.concat ", " in
  let stmt_str = List.map (stmt_to_str "  ") stmts |> String.concat ",\n" in
  sprintf "%s %s(%s) : [\n%s\n]" ret_str fname arg_str stmt_str

let to_str (p: program) : string = func_to_str p
