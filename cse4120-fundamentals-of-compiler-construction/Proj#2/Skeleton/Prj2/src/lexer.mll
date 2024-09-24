{
  open Parser
    exception LexicalError
  let keyword_table = Hashtbl.create 31
  let entries = [
    ("true", TRUE); 
    ("false", FALSE); 
    ("int", INT);
    ("bool", BOOL);
    ("void", VOID);
    ("if", IF);
    ("else", ELSE);
    ("while", WHILE);
    ("return", RETURN);
  ]
  let _ = List.iter (fun (k, t) -> Hashtbl.add keyword_table k t) entries
}

  let digit = ['0'-'9']
  let alpha = ['A'-'Z' 'a'-'z']
  let blank = [' ' '\t' '\n']

  rule token = parse
  | '+'       { PLUS }
  | '-'       { MINUS }
  | '*'       { TIMES }
  | '/'       { DIVIDE }
  | "=="      { EQUAL }
  | "!="      { NOTEQ }
  | "<="      { LEQ }
  | '<'       { LESS }
  | ">="      { GEQ }
  | '>'       { GREATER }
  | "!="      { NOTEQ }
  | "&&"      { AND }
  | "||"      { OR }
  | '!'       { NOT } 
  | '('       { LPAR }
  | ')'       { RPAR }
  | '['       { LSQUARE }
  | ']'       { RSQUARE }
  | '='       { ASSIGN }
  | '{'       { LBRA } 
  | '}'       { RBRA } 
  | ';'       { SEMICOLON }
  | ','       { COMMA }
  | eof       { EOF }
  | blank+    { token lexbuf }
  | digit+    { NUM (int_of_string (Lexing.lexeme lexbuf)) }
  | (alpha|'_')(alpha|digit|'_')* { let s = Lexing.lexeme lexbuf in
                                    try Hashtbl.find keyword_table s with
                                    Not_found -> IDENTIFIER s }
  | _ { let _ = Printf.printf "Invalid token %s\n" (Lexing.lexeme lexbuf) in
        raise LexicalError }
