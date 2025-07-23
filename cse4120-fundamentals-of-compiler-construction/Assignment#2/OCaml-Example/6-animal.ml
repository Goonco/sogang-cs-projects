type animal = Dog | Cat | Duck | Sparrow

let count_leg a =
  match a with
  | Dog -> 4
  | Cat -> 4
  | Duck -> 2
  | Sparrow -> 2

let a1 = Dog (* Type of 'a1' is 'animal' *)
let a2 = Sparrow (* Type of 'a2' is also 'animal' *)
let _ = Printf.printf "Are they same? %b\n" (a1 = a2)
let _ = Printf.printf "a1 has %d legs\n" (count_leg a1)
