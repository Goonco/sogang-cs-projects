open P7

let test bst ans =
  if BST.traverse bst = ans then "O" else "X"

let b0 = BST.create 3
let b1 = try BST.add 2 b0 with _ -> b0
let b2 = try BST.add 5 b1 with _ -> b1
let b3 = try BST.add 4 b2 with _ -> b2
let b4 = try BST.add 6 b3 with _ -> b3
let b5 = try BST.add 1 b4 with _ -> b4
let r1 = test b1 [2; 3]
let r2 = test b2 [2; 3; 5]
let r3 = test b3 [2; 3; 4; 5]
let r4 = test b4 [2; 3; 4; 5; 6]
let r5 = test b5 [1; 2; 3; 4; 5; 6]
let _ = printfn "%s%s%s%s%s" r1 r2 r3 r4 r5
