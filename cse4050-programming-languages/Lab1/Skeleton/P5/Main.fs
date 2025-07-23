open P5

let test lst ans =
  try if digitsToInt lst = ans then "O" else "X" with _ -> "E"

let l1 = [1; 3; 2]
let l2 = [1; 4; 2; 5; 7]
let l3 = [5]
let l4 = []
let l5 = [4; 0; 5; 0]
let r1 = test l1 132
let r2 = test l2 14257
let r3 = test l3 5
let r4 = test l4 0
let r5 = test l5 4050
let _ = printfn "%s%s%s%s%s" r1 r2 r3 r4 r5
