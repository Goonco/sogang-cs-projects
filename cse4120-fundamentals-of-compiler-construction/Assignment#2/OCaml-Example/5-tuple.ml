let x = (1, "abc")  (* x is a tuple of int and string *)
let (a, b) = x  (* a = 1, b = "abc" *)
let _ = Printf.printf "%d %s\n" a b

(* You can also annotate tuple type like this *)
let y: (int * bool * string) = (1, false, "A")
