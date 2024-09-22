open P2

let test inp ans =
  try if eval inp = ans then "O" else "X" with _ -> "E"

let testException inp =
  try (ignore (eval inp); "X") with
  | DivByZero -> "O"
  | _ -> "E"

let e1 = Sub (Num 5, Num 2) // 5 - 2
let e2 = Add (Num 3, Div (Num 7, Num 2)) // 3 + 7 / 2
let e3 = Sub (Add (Num 2, Num 9), Num 6) // (2 + 9) - 6
let e4 = Mul (Num 3, Add (Num 1, Num 2)) // 3 * (1 + 2)
let e5 = Div (Add (Num 2, Num 3), Sub (Num 4, Num 4)) // (2 + 3) / (4 - 4)
let r1 = test e1 3
let r2 = test e2 6
let r3 = test e3 5
let r4 = test e4 9
let r5 = testException e5
let _ = printfn "%s%s%s%s%s" r1 r2 r3 r4 r5
