(* Filter out (remove) all negative integers from an integer list. Returned list
   must contain only positive integers or zero. *)
let rec filter_negative l =
  match l with
  | [] -> []
  | head :: tail -> [] (* TODO *)
