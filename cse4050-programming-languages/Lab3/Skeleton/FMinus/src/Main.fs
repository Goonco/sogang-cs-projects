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

let printVal (v: Val) : unit =
  match v with
  | Int i -> printfn "%d" i
  | Bool b -> printfn "%b" b
  | Func (x, e, _)  -> printfn "fun %s -> %A" x e
  | RecFunc (_, x, e, _)  -> printfn "(rec) fun %s -> %A" x e

[<EntryPoint>]
let main argv =
  if Array.length argv <> 1 then
    printfn "[*] (Usage)"
    printfn "[*] ./FMinus <source file>"
    exit 1
  let lexbuf = makeBuf argv[0]
  let prog = parse lexbuf
  let _ =
    try printVal (FMinus.run prog) with
    | UndefinedSemantics -> printfn "Undefined semantics"
  0
