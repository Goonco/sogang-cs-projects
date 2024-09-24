# <small><small><small><small>CSE4120</small></small></small></small> Fundamentals Of Compiler Construction

본 문서는 **23년도 2학기 서강대학교 최재승 교수님**의 **CSE4120 기초 컴파일러 구성** 수업을 바탕으로 작성되었습니다.

수업 내용과 강의자료에 더해 개인적인 해석이 더해진 정리이므로 오류가 존재할 수 있다는 점 주의해주세요.<br/>
또한 Proj #3의 경우 역량 및 시간 부족으로 Copy Propogation과 Common Subexpression Elimination을 구현하지 못했다는 점 참고해주세요 🥲

해당 과제는 LLM의 도움 없이 구현된 만큼, 무분별한 카피는 보다 쉽게 확인될 수 있습니다.<br/>
더 나아가, 본 과제의 수행이 수업의 내용을 더욱 깊게 이해하고 소화하는데 직접적으로 도움이 된다고 생각합니다. 따라서 해당 코드들은 단순한 참고용으로 활용하는 것을 추천드립니다 😃

<br/>

# <small><small><small><small>Assignment #1.</small></small></small></small> Flex & Bison Exercise

### Overview

The goal of this project is to define the specifications for automatic generation of lexer and parser.

**1. Lexer** <br/>
The **lexer** takes the program's source code as input, tokenizes it according to predefined rules, and rejects any malformed input. These rules specify the valid token patterns, typically expressed as **regular expressions (RegEx)**. The tool used to automatically generate the lexer, **Flex**, accepts RegEx-based specifications to produce the lexer. 

Our task is to define the token patterns in `prog.l` using Regex, so that Flex can generate a valid lexer. 

Additionally, the lexer generation process involves converting the provided RegEx into a **Non-Deterministic Finite Automata (NFA)**, which is then converted into a **Deterministic Finite Automata (DFA)**. A detailed explanation for this complex process is beyond the scope of this assignment, but you can refer to the lecture notes for more information.

**2. Parser** <br/>
The **parser** uses the token stream produced by the lexer to construct an **Abstract Syntax Tree (AST)** based on a set of grammar rules. These grammar rules define how the parser interprets the input and are described using a **Context-Free Grammar (CFG)**. The parser generation tool, **Bison**, accepts CFG and additional specifications to generate the parser.

Our task is to define the CFG and the AST construction logic in `prog.y` so that Bison can automatically generate the parser.

Additionally, there are two main methods for automatic parser generation: top-down and bottom-up. Both methods use complex algorithms to generate parsers. In this assignment, Bison uses the bottom-up approach to generate an LALR parser. As with the lexer, a detailed explanation of these algorithms is beyond the scope of this assignment, so please refer to the lecture notes for further details.

<!-- ### Details
* `run`
    * Receives a `program` and returns a error list that contains all the error occured during the type checking.
    * 전체 타입 체킹 알고리즘을 진행한다. 먼저 `collect_vars`와 `collect_functions`를 수행하며 global declaration과 함수를 순회하며 global symbol table을 채운다. 이후 `check_functions`를 호출해 각 함수 내부를 확인하며 에러를 에러 리스트에 추가한다.

* `collect_vars` & `collect_functions`

    * 각 각 global declaration과 unction을 순회하며 이름과 타입을 symbol table에 기록한다.
    * 이때 symbol table은 `String`과 `ctype_entry`의 map으로 타입 저장 시 `ctype_entry`로의 타입 변환이 필요하다. 이를 위해서 `collect_functoins`는 `filter_decls_to_ctyps`라는 helper function을 활용한다.

* `check_functions`
    * global variable과 function의 타입이 저장된 symbol table, 그리고 함수들을 receive하고 errorlist를 반환한다.
    * `collect_vars`를 활용해 function 내의 declaration을 symbol table에 추가한다.
    * `check_statements`를 호출하여 errorlist를 반환한다.

* `check_statements`

* `check_exp`

개인적으로 불필요한 함수도 존재하고 함수형 언어를 잘 다루지 못해 코드가 가독성도 낮고 길어졌다. 🥲 -->

<br/>

# <small><small><small><small>Assignment #2.</small></small></small></small> OCaml Exercise

Requires some simple `OCaml` implementations. Helps you to get familliar with `OCaml` and the concept of functional languages which is essential for the further projects 🐪

Use the files in `OCaml-Example` as a cheat sheet 👀

<br/>

# <small><small><small><small>Project #1.</small></small></small></small> Type Checking

### Overview

The goal of this project is to implement type checking for AST.

Type checking is a process that occurs in the front-end (FE) of the compiler, before IR generation, and is responsible for detecting obvious semantic errors from the AST. While syntax analysis (parsing) can catch syntax-level errors, such as tokens appearing in incorrect positions, it does not detect semantic errors. Type checking indentifies errors like type mismatches, use of undeclared identifiers, redeclaration of identifiers, and more. Note that there are still some semantic errors that type checking cannot detect.

If the source language uses implicit typing, such as python, type inference becomes necessary, making the process more complex than for explicitly typed languages. Fortunately, the target language in this assignment is a simplified version of C, which uses explicit typing, eliminating the need for type inference. For an example of a type inference system, refer to [CSE4050 Programming Languages](https://github.com/Goonco/sogang-cs-projects/tree/main/cse4050-programming-languages).

In explicitly typed languages, type checking is performed using a symbol table. A **Symbol Table** stores mappings between variables or function names and their associated types. The type checker uses this table to ensure variables are used correctly throughout the program.

The symbol table needs to maintain correct information among different scopes. Since each identifier has its own scope, the symbol table must be updated accordingly when entering new scopes, such as functions. Care should be taken to correctly manage the symbol table during scope transitions to ensure accurate type checking.

<br/>

# <small><small><small><small>Project #2.</small></small></small></small> IR Translation

### Overview

The goal of this project is to generate IR from an AST that has already undergone type checking.

**IR** stands for **Intermediate Representation**, and as the name suggests, it serves as an intermediate stage before the compiler converts the code into the target language. By introducing this intermediate stage, the compiler can support multiple source and target languages. Additionally, IR operates at a lower level of abstraction compared to the AST, making it more suitable for optimizations and machine code generation.

The key difference between AST and IR is that IR distinguishes variables (in memory) from registers. This means that for operands such as add/sub, IR needs to load variables from memory to registers. Later on, these IR registers are mapped to actual CPU registers, making it significantly easier to generate machine code compared to working directly with the AST. However, note that there remains a gap between IR and machine level code. For example, while IR assumes an infinite number of registers, real CPUs have a limited number.

Our task is to utilize the characteristics of IR to translate the AST into IR instructions as defined in `ir.ml`. To introduce the concept of registers, a symbol table is required to map variable names to their corresponding registers. Unlike in Project #1, Project #2 must also support 1D arrays, with the AST reflecting array structures. Since the size of an array index depends on its type, type information must also be stored in the symbol table. Additionally, this project must handle short-circuit evaluation for logical operators such as `OR` and `AND`.

During the IR generation process, you may encounter inefficiencies such as the generation of an excessive number of registers. While these inefficiencies could also be optimized in the IR generation code, they are typically addressed in the middle end of the compiler during IR optimization. Personally, I recommended to focus on creating readable and intuitive translation code, even if it means sacrificing some optimization at this stage.

<!-- 먼가 reigster는 곧 메모리 라는 걸 좀더 말하고 싶은데 잘안되네 -->

<br/>

# <small><small><small><small>Project #3.</small></small></small></small> Optimization

### Overview

The goal of this project is IR optimization, or in other words, implementing the middle end of the compiler.

The purpose of IR optimization is to generate “better code.” While “better code” can have various interpretations, it typically refers to improvements such as reducing execution time, code size, and memory usage.

Also note that IR optimization must never alter the behavior of the original IR. It should only focus on enhancing the efficiency of the code.

While individual optimizations can be complex, the overall process in the compiler’s middle end is quite straightforward: it simply receives the IR from the front end, applies optimizations, and outputs the optimized IR. In this project, we will perform five key optimizations on the provided IR:

* constant folding
* constant propagation
* copy propagation
* common subexpression elimination
* dead code elimination

<br/>

<h3 align="center">Thank you for reading, I hope you enjoy the project too 🤩</h3>