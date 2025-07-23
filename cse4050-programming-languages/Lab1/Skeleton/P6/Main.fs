open P6

let test inp ans =
  try if countMostFrequent inp = ans then "O" else "X" with _ -> "E"

let l1 = [1; 2; 3; 2; 1; 2] // Element '2' appears three times.
let l2 = [3; 3; 2; 5; 7; 7] // Element '3' and '7' appear twice.
let l3 = [(1, 2); (2, 3); (3, 4); (4, 1)] // All elements appear once.
let l4 = ["ABC"; "XYZ"; "XY"; "ABC"] // Element "ABC" appears twice.
let l5 = [] // No element.
let r1 = test l1 3
let r2 = test l2 2
let r3 = test l3 1
let r4 = test l4 2
let r5 = test l5 0
let _ = printfn "%s%s%s%s%s" r1 r2 r3 r4 r5
