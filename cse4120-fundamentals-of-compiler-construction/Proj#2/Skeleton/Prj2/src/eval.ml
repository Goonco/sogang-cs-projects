open Ir
open State

let eval_immediate i =
  match i with
  | ImmInt i -> Int i
  | ImmBool b -> Bool b

let eval_operand oprnd reg_map =
  match oprnd with
  | Imm i -> eval_immediate i
  | Reg r -> RegMap.find r reg_map

let neg_op v =
  match v with
  | Int i -> Int (- i)
  | _ -> raise (RuntimeError "Type mismatch (negation)")

let not_op v =
  match v with
  | Bool b -> Bool (not b)
  | _ -> raise (RuntimeError "Type mismatch (NOT operation)")

let unary_op op_typ v =
  match op_typ with
  | NegOp -> neg_op v
  | NotOp -> not_op v

let add_op v1 v2 =
  match v1, v2 with
  | Int i1, Int i2 -> Int (i1 + i2)
  | Ptr p, Int i | Int i, Ptr p -> Ptr (p + i)
  | _ -> raise (RuntimeError "Type mismatch (addition)")

let sub_op v1 v2 =
  match v1, v2 with
  | Int i1, Int i2 -> Int (i1 - i2)
  | Ptr p, Int i -> Ptr (p - i)
  | _ -> raise (RuntimeError "Type mismatch (subtraction)")

let mul_op v1 v2 =
  match v1, v2 with
  | Int i1, Int i2 -> Int (i1 * i2)
  | _ -> raise (RuntimeError "Type mismatch (multiplication)")

let div_op v1 v2 =
  match v1, v2 with
  | Int i1, Int i2 ->
      if i2 = 0 then raise (RuntimeError "Div-by-zero")
      else Int (i1 / i2)
  | _ -> raise (RuntimeError "Type mismatch (division)")

let eq_op v1 v2 =
  match v1, v2 with
  | Int i1, Int i2 -> Bool (i1 = i2)
  | Bool b1, Bool b2 -> Bool (b1 = b2)
  | Ptr p1, Ptr p2 -> Bool (p1 = p2)
  | _ -> raise (RuntimeError "Type mismatch (comparison)")

let neq_op v1 v2 =
  match v1, v2 with
  | Int i1, Int i2 -> Bool (i1 <> i2)
  | Bool b1, Bool b2 -> Bool (b1 <> b2)
  | Ptr p1, Ptr p2 -> Bool (p1 <> p2)
  | _ -> raise (RuntimeError "Type mismatch (comparison)")

let cmp_op operator v1 v2 =
  match v1, v2 with
  | Int i1, Int i2 -> Bool (operator i1 i2)
  | _ -> raise (RuntimeError "Type mismatch (comparison)")

let binary_op op_typ v1 v2 =
  match op_typ with
  | AddOp -> add_op v1 v2
  | SubOp -> sub_op v1 v2
  | MulOp -> mul_op v1 v2
  | DivOp -> div_op v1 v2
  | EqOp -> eq_op v1 v2
  | NeqOp -> neq_op v1 v2
  | LeqOp -> cmp_op ( <= ) v1 v2
  | LtOp -> cmp_op ( < ) v1 v2
  | GeqOp -> cmp_op ( >= ) v1 v2
  | GtOp -> cmp_op ( > ) v1 v2
