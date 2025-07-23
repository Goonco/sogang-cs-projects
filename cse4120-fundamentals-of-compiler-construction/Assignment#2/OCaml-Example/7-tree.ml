type tree = Leaf of int | Node of int * tree * tree

let t1: tree = Node (3, Leaf 1, Leaf 2)
let t2: tree = Node (5, Leaf 4, t1)
