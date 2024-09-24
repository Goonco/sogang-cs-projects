open Ir

let measure instr =
  match instr with
  | Set _ -> 1
  | Copy _ -> 3
  | LocalAlloc _ -> 0
  | UnOp _ | BinOp _ -> 5
  | Load _ | Store _ -> 5
  | Goto _ -> 3
  | GotoIf _ | GotoIfNot _ -> 5
  | Label _ -> 0
  | Ret _ -> 2
