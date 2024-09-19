(* A map that can have 'int' as key *)
module IntMap = Map.Make(struct type t = int let compare = compare end)

(* From the provided int list 'il', count the occurence of each integer value
   and record it in a map. For instance, [4; 5; 5] has one 4 and two 5s, so the
   returned map should contain two mappings: 4 -> 1 and 5 -> 2. *)
let rec count_with_map (il: int list) =
  match il with
  | [] -> IntMap.empty
  | head :: tail -> 
  let prev = count_with_map(tail) in
  if IntMap.mem head prev
   then
      let newCount = IntMap.find head prev in
      IntMap.add head (newCount + 1) prev
   else
      IntMap.add head 1 prev
