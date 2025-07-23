open Program
open Error

(* Our symbol table will be a mapping from 'string' to 'ctype_entry'. *)
type ctype_entry =
  | VarType of ctype
  | FuncType of ctype * ctype list (* return type * argument type list *)

(* Define a module for symbol table *)
module SymbolMap = Map.Make(String)

(* During the semantic analysis, this type can be helpful. Why do we need this
 * even though 'ctype' is already defined? If you encounter a wrong expression
 * during the semantic analysis (for example "1 + true"), you cannot decide its
 * type but still may have to return something. *)
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

(* Record the type of variables into the symbol table *)
let rec collect_vars decls sym_tab =
  match decls with
  | [] -> sym_tab
  | head_decl :: tail_decls ->
      let (ctyp, vname) = head_decl in
      let sym_tab = SymbolMap.add vname (VarType ctyp) sym_tab in
      collect_vars tail_decls sym_tab

(* Record the type of functions into the symbol table *)
let rec collect_functions funcs sym_tab =
  sym_tab (* TODO *)

(* Check expression 'e' and return detected semantic errors, along with the
 * decided type of 'e'. If the type of expression cannot be decided due to
 * semantic error, return 'Unknown' as its type. *)
let rec check_exp sym_tab e =
  match e with
  | ConstBool b -> ([], Bool)
  | ConstInt i -> ([], Int)
  (* TODO: Fill in the remaining cases below *)
  | _ -> ([], Unknown)

(******************************************************************
 * And of course, you will need many more functions between here. *
 * ****************************************************************)

(* Check functions and return detected semantic errors. *)
let rec check_functions sym_tab funcs =
  [] (* TODO *)

(* Check a program and return detected semantic errors. *)
let run (p: program) : error list =
  let (gdecls, funcs) = p in
  let sym_tab = collect_vars gdecls SymbolMap.empty in
  let sym_tab = collect_functions funcs sym_tab in
  (* At this point, 'sym_tab' must contain global variables & functions *)
  check_functions sym_tab funcs
