open FSharp.Text.Lexing
open AST
open Types

let makeBuf (file: string): LexBuffer<_> =
  try
    let streamReader = new System.IO.StreamReader(file)
    let lexbuf = LexBuffer<_>.FromTextReader streamReader
    lexbuf.EndPos <- { lexbuf.EndPos with pos_lnum = 1 }
    lexbuf
  with :? System.IO.IOException ->
    printfn "[*] Failed to open file '%s'" file
    exit 1

let parse (lexbuf: LexBuffer<_>) : Program =
  try Parser.prog Lexer.token lexbuf
  with _ ->
    printfn "[*] Parsing error at line %d" (lexbuf.EndPos.Line)
    exit 1

let valToStr (v: Val): string =
  match v with
  | Int i -> sprintf "%d" i
  | Bool b -> sprintf "%b" b
  | Loc vname -> vname

let printMem (mem: Mem): unit =
  printfn "{"
  Map.iter (fun k v -> printfn "  %s -> %s" k (valToStr v)) mem
  printfn "}"

[<EntryPoint>]
let main argv =
  if Array.length argv <> 1 then
    printfn "[*] (Usage)"
    printfn "[*] ./CMinusPtr <source file>"
    exit 1
  let lexbuf = makeBuf argv[0]
  let prog = parse lexbuf
  let _ =
    try printMem (CMinusPtr.run prog) with
    | UndefinedSemantics -> printfn "Undefined semantics"
  0
