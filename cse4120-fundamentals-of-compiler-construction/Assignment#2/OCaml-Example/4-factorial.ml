let rec factorial n =
  if n <= 1 then 1
  else n * factorial (n - 1)   (* ( ) is for priority *)

let x = factorial 5
let _ = Printf.printf "%d\n" x
