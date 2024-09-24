%{
%}

%token PLUS MINUS TIMES DIVIDE EQUAL NOTEQ LEQ LESS GEQ GREATER AND OR NOT
%token LPAR RPAR LSQUARE RSQUARE ASSIGN LBRA RBRA SEMICOLON COMMA
%token TRUE FALSE INT BOOL VOID IF ELSE WHILE RETURN
%token EOF
%token <int> NUM
%token <string> IDENTIFIER

%left OR
%left AND
%nonassoc EQUAL NOTEQ LEQ LESS GEQ GREATER
%left PLUS MINUS
%left TIMES DIVIDE
%right NOT

%start program
%type <Program.program> program
%type <Program.func> func

%%

program: func EOF { $1 }

func: ctype IDENTIFIER LPAR argdecl RPAR LBRA stmts RBRA { ($2, $1, $4, $7) }

ctype:  VOID { failwith "In this phase, cannot have 'void' as return type" }
      | BOOL { Program.CBool }
      | INT { Program.CInt }

argdecl:  VOID { failwith "In this phase, cannot have 'void' argument" }
        | args { $1 }

args: /* epsilon */ { [] }
    | adecl { [$1] }
    | adecl COMMA args { $1 :: $3 }

adecl:  BOOL IDENTIFIER { (Program.CBool, $2) }
      | INT IDENTIFIER { (Program.CInt, $2) }

vdecl:  BOOL IDENTIFIER { (Program.CBool, $2) }
      | INT IDENTIFIER { (Program.CInt, $2) }
      | BOOL IDENTIFIER LSQUARE NUM RSQUARE { (Program.CBoolArr $4, $2) }
      | INT IDENTIFIER LSQUARE NUM RSQUARE { (Program.CIntArr $4, $2) }

stmts:  /* epsilon */ { [] }
      | stmt stmts { $1 :: $2 }
      | SEMICOLON stmts { $2 }

stmt: vdecl SEMICOLON { Program.LocalDecl $1 }
    | lvalue ASSIGN exp SEMICOLON { Program.Assign ($1, $3) }
    | RETURN SEMICOLON { failwith "In this phase, 'return' must have a value" }
    | RETURN exp SEMICOLON { Program.ReturnValue $2 }
    | IF LPAR exp RPAR LBRA stmts RBRA elseopt { Program.If ($3, $6, $8) }
    | WHILE LPAR exp RPAR LBRA stmts RBRA { Program.While ($3, $6) }

lvalue: IDENTIFIER { Program.LVar $1 }
      | IDENTIFIER LSQUARE exp RSQUARE { Program.LArr ($1, $3) }

elseopt:  /* epsilon */ { [] }
        | ELSE LBRA stmts RBRA { $3 }

exp:  NUM { Program.ConstInt $1 }
    | TRUE { Program.ConstBool true }
    | FALSE { Program.ConstBool false }
    | IDENTIFIER { Program.Var $1 }
    | IDENTIFIER LSQUARE exp RSQUARE { Program.Arr ($1, $3) }
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
