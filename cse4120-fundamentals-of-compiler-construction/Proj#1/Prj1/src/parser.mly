%{
%}

%token PLUS MINUS TIMES DIVIDE EQUAL NOTEQ LEQ LESS GEQ GREATER AND OR NOT
%token LPAR RPAR ASSIGN LBRA RBRA SEMICOLON COMMA
%token TRUE FALSE INT BOOL VOID IF ELSE WHILE RETURN
%token EOF
%token <int> NUM
%token <string> IDENTIFIER

%left PLUS MINUS OR
%left TIMES DIVIDE AND
%nonassoc EQUAL NOTEQ LEQ LESS GEQ GREATER
%right NOT

%start program
%type <Program.program> program
%type <Program.decl> gdecl
%type <Program.func> func

%%

program: top_decls EOF { $1 }

/* top-level declataions */
top_decls : /* epsilon */ { ([], []) }
      | gdecl top_decls { let (gdecls, funcs) = $2 in ($1 :: gdecls, funcs) }
      | func funcs { ([], $1 :: $2) }

funcs:  /* epsilon */ { [] }
      | func funcs { $1 :: $2 }

gdecl: ctype IDENTIFIER SEMICOLON { ($1, $2) }

func: ctype IDENTIFIER LPAR args RPAR LBRA stmts RBRA { ($2, $1, $4, $7) }

ctype:  VOID { Program.CVoid }
      | BOOL { Program.CBool }
      | INT { Program.CInt }

args: /* epsilon */ { [] }
    | VOID { [] }
    | arg { [$1] }
    | arg COMMA args { $1 :: $3 }

arg: ctype IDENTIFIER { ($1, $2) } 

stmts:  /* epsilon */ { [] }
      | stmt stmts { $1 :: $2 }
      | SEMICOLON stmts { $2 }

stmt: IDENTIFIER ASSIGN exp SEMICOLON { Program.Assign ($1, $3) }
    | ctype IDENTIFIER SEMICOLON { Program.LocalDecl ($1, $2) }
    | IDENTIFIER LPAR exps RPAR SEMICOLON { Program.Call ($1, $3) }
    | RETURN SEMICOLON { Program.Return }
    | RETURN exp SEMICOLON { Program.ReturnValue $2 }
    | IF LPAR exp RPAR LBRA stmts RBRA elseopt { Program.If ($3, $6, $8) }
    | WHILE LPAR exp RPAR LBRA stmts RBRA { Program.While ($3, $6) }

elseopt:  /* epsilon */ { [] }
        | ELSE LBRA stmts RBRA { $3 }

exps: /* epsilon */ { [] }
    | exp { [$1] }
    | exp COMMA exps { $1 :: $3 }

exp:  NUM { Program.ConstInt $1 }
    | TRUE { Program.ConstBool true }
    | FALSE { Program.ConstBool false }
    | IDENTIFIER { Program.Var $1 }
    | IDENTIFIER LPAR exps RPAR { Program.CallExp ($1, $3) }
    | exp PLUS exp { Program.Add ($1, $3) }
    | exp MINUS exp { Program.Sub ($1, $3) }
    | exp TIMES exp { Program.Mul ($1, $3) }
    | exp DIVIDE exp { Program.Div ($1, $3) }
    | PLUS exp { $2 }
    | MINUS exp { Program.Neg $2 }
    | exp EQUAL exp { Program.Equal ($1, $3) }
    | exp NOTEQ exp { Program.NotEq ($1, $3) }
    | exp LEQ exp { Program.LessEq ($1, $3) }
    | exp LESS exp { Program.LessThan ($1, $3) }
    | exp GEQ exp { Program.GreaterEq ($1, $3) }
    | exp GREATER exp { Program.GreaterThan ($1, $3) }
    | exp AND exp { Program.And ($1, $3) }
    | exp OR exp { Program.Or ($1, $3) }
    | NOT exp { Program.Not $2 }
    | LPAR exp RPAR { $2 }
