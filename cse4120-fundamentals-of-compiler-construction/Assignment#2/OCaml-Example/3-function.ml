let add x y = x + y

let square_add x y =
  let s1 = x * x in
  let s2 = y * y in
  s1 + s2

let print_msg () = (* No argument *)
  Printf.printf "Hello\n"

let a = add 2 3
let b = square_add 4 5
let _ = print_msg () (* Parentheses ared only used here *)
