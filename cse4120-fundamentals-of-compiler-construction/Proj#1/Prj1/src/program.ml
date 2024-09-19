open Printf

type exp =
  | ConstBool of bool
  | ConstInt of int
  | Var of string
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
  | CallExp of string * exp list

type ctype = CVoid | CInt | CBool

(* Variable declaration := name * type *)
type decl = ctype * string

type stmt =
  | LocalDecl of decl
  | Assign of string * exp
  | Call of string * exp list
  | Return
  | ReturnValue of exp
  | If of exp * stmt list * stmt list
  | While of exp * stmt list

(* Function := function name * argument declarations * statements *)
type func = string * ctype * decl list * stmt list

(* Program := global variable declarations * function definitions *)
type program = decl list * func list

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
  | CallExp (fname, exps) ->
      let exp_str = List.map exp_to_str exps |> String.concat ", " in
      sprintf "%s(%s)" fname exp_str

let ctype_to_str typ =
  match typ with
  | CVoid -> "void"
  | CInt -> "int"
  | CBool -> "bool"

let rec stmt_to_str indent stmt =
  match stmt with
  | LocalDecl (t, vname) -> sprintf "%s%s %s" indent (ctype_to_str t) vname
  | Assign (vname, e) -> sprintf "%s%s = %s" indent vname (exp_to_str e)
  | Call (fname, exps) ->
      let exp_str = List.map exp_to_str exps |> String.concat ", " in
      sprintf "%s%s(%s)" indent fname exp_str
  | Return -> sprintf "%sreturn" indent
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

let decl_to_str decl =
  let (typ, vname) = decl in
  sprintf "%s %s" (ctype_to_str typ) vname

let func_to_str f =
  let fname, ret_typ, args, stmts = f in
  let ret_str = ctype_to_str ret_typ in
  let arg_str = List.map decl_to_str args |> String.concat ", " in
  let stmt_str = List.map (stmt_to_str "    ") stmts |> String.concat ",\n" in
  sprintf "  %s %s(%s) : [\n%s\n  ]" ret_str fname arg_str stmt_str

let to_str (p: program) : string =
  let (gdecls, funcs) = p in
  let gdecl_str = List.map decl_to_str gdecls |> String.concat ", " in
  let func_str = List.map func_to_str funcs |> String.concat ",\n\n" in
  sprintf "Global variables : [%s]\nFunctions : [\n%s\n]" gdecl_str func_str
