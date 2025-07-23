open P3

let test inp ans =
  try if unzip inp = ans then "O" else "X" with _ -> "E"

let l1 = [ (1, 10); (2, 20); (3, 30) ]
let l2 = [ (1, 'a'); (2, 'b'); (3, 'c') ]
let l3 = [ ("ABC", 'a'); ("XYZ", 'b'); ("QWER", 'c') ]
let l4 = [ (10, false) ]
let l5 = [ (7, 8) ]
let r1 = test l1 ([1; 2; 3], [10; 20; 30])
let r2 = test l2 ([1; 2; 3], ['a'; 'b'; 'c'])
let r3 = test l3 (["ABC"; "XYZ"; "QWER"], ['a'; 'b'; 'c'])
let r4 = test l4 ([10], [false])
let r5 = test l5 ([7], [8])
let _ = printfn "%s%s%s%s%s" r1 r2 r3 r4 r5
