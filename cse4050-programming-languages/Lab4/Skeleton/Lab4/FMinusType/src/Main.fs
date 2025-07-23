open FSharp.Text.Lexing
open AST
open FMinus

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

[<EntryPoint>]
let main argv =
  if Array.length argv <> 1 then
    printfn "[*] (Usage)"
    printfn "[*] ./FMinusType <source file>"
    exit 1
  let lexbuf = makeBuf argv[0]
  let prog = parse lexbuf
  let _ =
    try printfn "%s" (Type.toString (Type.infer prog)) with
    | FMinus.TypeError -> printfn "Type error"
  0
