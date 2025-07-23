let rec my_length lst = (* Usable on any list *)
  match lst with
  | [] -> 0
  | head :: tail -> 1 + (my_length tail)

let rec double_list lst = (* Usable on int list only *)
  match lst with
  | [] -> []
  | head :: tail -> (2 * head) :: (double_list tail)

let il: int list = [1; 2; 3; 4]
let sl: string list = ["OCaml"; "F#"; "scala"]

let len1 = List.length il
let len2 = List.length sl
let b = List.mem 5 il      (* returns false *)
let head_elem = List.hd sl (* returns "OCaml" *)

let _ = Printf.printf "%d %d %b %s\n" len1 len2 b head_elem
let _ = Printf.printf "my_length il = %d\n" (my_length il)
let il' = double_list il
