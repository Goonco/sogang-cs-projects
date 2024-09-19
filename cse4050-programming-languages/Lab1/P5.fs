module P5

/// For int list 'l' that contains decimal digits (0~9), return the integer that
/// is represented by this list. For example, "digitsToInt [1; 3; 2]" must
/// return 132 as a result. When the input list is empty, just return 0.
let rec subFunc (l: int list) : string = 
  match l with
  | [] -> "0"
  | [x] -> string x
  | head::tail -> (
    let strHead = string head in
    let strTail = (subFunc tail) in
    strHead + strTail
  )

let digitsToInt (l: int list) : int =
  int (subFunc l)