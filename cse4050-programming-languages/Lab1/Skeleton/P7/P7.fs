namespace P7

// (Note) Do NOT touch anything other than the 'add' function below.

/// Binary search tree for integers.
type BST =
  | Node of int * BST * BST // A node has an item and its left/right subtrees.
  | Empty // Leaf node must have this 'Empty' tree as its subtrees.

module BST =

  /// Return a BST that contains 'i' in the root node.
  let create i = Node (i, Empty, Empty)

  /// In-order traverse to retrieve the integers from the BST.
  let rec traverse (bst: BST) : int list =
    match bst with
    | Node (i, ltree, rtree) -> traverse ltree @ [i] @ traverse rtree
    | Empty -> []

  /// Add integer 'i' to 'bst' and return the resulting BST. If 'bst' already
  /// contains 'i' in one of its nodes, just return the same BST.
  let rec add (i: int) (bst: BST) : BST =
    bst // TODO
