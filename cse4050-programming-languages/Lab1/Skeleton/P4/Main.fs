open P4

let test f a b ans =
  try if sigma f a b = ans then "O" else "X" with _ -> "E"

let r1 = test (fun x -> x) 0 10 55
let r2 = test (fun x -> 2 * x) 0 9 90
let r3 = test (fun x -> 2 * x) 8 5 0
let r4 = test (fun x -> 3 * x + 1) 5 5 16
let r5 = test (fun x -> 3 * x + 1) 5 7 57
let _ = printfn "%s%s%s%s%s" r1 r2 r3 r4 r5
