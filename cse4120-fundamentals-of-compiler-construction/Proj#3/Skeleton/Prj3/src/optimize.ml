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

let test () =
  (* Represents an empty reaching definition set *)
  let x = RDSet.empty in
  (* Set with 'r=0' as element *)
  let y = RDSet.add (Set ("r", ImmInt 0)) x in
  (* You can also compute union, intersection, or difference with RDSet.union,
   * RDSet.inter, and RDSet.diff. Read the OCaml document for more functions. *)
  let union = RDSet.union x y in
  (* Is x subset of union? *)
  let is_subset = RDSet.subset x union in
  Printf.printf "is_subset: %b\n" is_subset

let run (ir: ir_code): ir_code =
  (* Currently, run() returns the input IR code without any optimization. *)
  ir
