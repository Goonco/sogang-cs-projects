open Printf

let reg_num = ref 0

let label_num = ref 0

(* Create a fresh and unique register name. The name starts with '$', so it
 * will never conflict with the name of function arguments. *)
let create_register_name () =
  let reg = sprintf "$r%d" !reg_num in
  let _ = reg_num := !reg_num + 1 in
  reg

(* Create a fresh and unique label name. The name starts with 'L'. *)
let create_label () =
  let label = sprintf "L%d" !label_num in
  let _ = label_num := !label_num + 1 in
  label
