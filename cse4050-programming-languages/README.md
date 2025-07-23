# <small><small><small><small>CSE4050</small></small></small></small> Programming Languages

본 문서는 **24년도 1학기 서강대학교 최재승 교수님**의 **CSE4050 프로그래밍 언어** 수업을 바탕으로 작성되었습니다. <br/>
수업 내용과 강의자료에 더해 개인적인 해석이 더해진 정리이므로 오류가 존재할 수 있다는 점 주의해주세요 🥲

해당 과제는 LLM의 도움 없이 구현된 만큼, 무분별한 카피는 보다 쉽게 확인될 수 있습니다.<br/>
더 나아가, 본 과제의 수행이 수업의 내용을 더욱 깊게 이해하고 소화하는데 직접적으로 도움이 된다고 생각합니다. 따라서 해당 코드들은 단순한 참고용으로 활용하는 것을 추천드립니다. 😃

<br/>

# <small><small><small><small>Lab #1.</small></small></small></small> Warm-Up Exercise

Requires some simple `F#` implementations. Helps you to get familliar with `F#` and the concept of functional languages which is essential for the further projects 🙌

<br/>

# <small><small><small><small>Lab #2.</small></small></small></small> C- Interpreter

### Overview

The goal of this project is to implement a C- interpreter that takes a program as input and returns a **memory state**, which is a mappping from variables to their corresponding values.

Since the lexer and parser are already provided, our task is to interpret the C- AST and produce a memroy state that reflects which variables hold which values.

The C- AST is defined on `AST.fs`. To fully understand its structure, understanding the concept of `Stmt` and `Exp` must be preceded.

`Stmt` (statement) represents the smallest unit of execution, capable of modifying the memory state. Because `Stmt` itself may also be a sequence of `Stmt`, you can find out that `Program` is equavalent to `Stmt`.

A `Stmt` often contains one or more `Exp` (expression). An `Exp` is always evaluated to produce a specific value, which a `Stmt` uses to modify the memory state. Thus, every `Stmt` manipulates the memory state based on the values computed from its associated `Exp`.

In summary, our task is to develop the C- interpreter by implementing the `run` function, which processes a `Program` by evaluating the expressions and updating the memory state according to the semantics of the statements.

<br/>

### Details

* `run`

    * Receives a `Program` and returns a memory state.
    * Initializes the process by invoking `evalStmt` with an empty memory state.

* `evalStmt`

    * Receives a statement and memory state, modifies the memory state according to the C- semantics and returns the memory state.
    * For `If` and `While` statement, if the condition epxression does not evaluate to a boolean value, the interpreter raises a semantic error.

* `evalExp`

    * Receives an expression and a memory state, computes the expression based on the memory state and C- semantics, then returns the computed value.
    * Arithmetic operators and comparison operators must have operands of compatible types. If not, the interpreter raises a semantic error.
    * For `LV` expressions, if the variable name computed by `evalLVal` does not exist in the memory state, the interpreter raises a semntic error.

* `evalLVal`

    * `LVal` expressions are values that appear on the left side of an assignment operator, which means they must eventually resolve to a variable name.
    * Therefore, this function receives a `LVal` expression and a memory state, coumputes the expression, and check if it resolves to a variable name. If it does, the varialbe name is returned; otherwise, the interpreter raises a semntic error.

<br/>

# <small><small><small><small>Lab #3.</small></small></small></small> F- Intepreter

### Overview

The overall structure of the F- interpreter is quite similar to the C- interpreter, but there are some key differences, as C- is an imperative language, while F- is a functional language.

Functional programming languages are often referred to as “expression-oriented” languages, because they treat the entire program as a single expression.

Therefore, unlike the C- interpreter which returns a memory state, the F- interpreter evaluates the program and returns a specific value.

Additionally, the F- interpreter use a concept called **environment** to store the mappaing from variables to values instead of memory state. However, unlike the memory state, which is permanently modified by statements, the environment is a contextual snapshot at a given point of a program, and is not modified, but created by special expressions like `let in`.

Further more, functions and recursive functions are also treated as variables, and they, too, must be stored in the environment. A function is mapped to a combination of its name, expression (body), and the environment at the time of its definition. This combination is called a **closure**.

In summary, our task is to implement to develop the F- interpreter by implementing the `run` function, which processes a `Program` by creating environments and evaluating expressions according to the semantics of the F- language.

<br/>

### Details

* `run`

    * Receives a `Program` and returns a value.
    * Initializes the process by invoking `evalExp` with an empty environment.

* `evalExp`

    * Receives an expression and an environment, computes the expression based on the environment and F- semantics, then returns the computed value.
    * Utilizes helper functions (`checkNumber`, `checkBoolean`, `checkSame`) for value type checking and integrated error handling.
    * New environments are created on `LetIn`, `LetFunIn`, `LetRecIn` and `App` expressions.

<br/>

# <small><small><small><small>Lab #4.</small></small></small></small> F- Type System

> 🚨 Note that the `ExtraTestcases` may include wrong answers.

### Overview

The goal of this project is to implement a F- type system that takes a program as input, verifes wheter the program adheres to the rule of the type system, and returns the overall type of the program.

There are two key metrics for measuring the performance of a type system: **soundness** and **completeness**. A sound type system guarantees that it never misses an error, while a complete type system ensures that it never rejects a safe program.

For our project, we are focusing on implementing a sound type system for F-. As a result, the system may even reject some semantically correct programs such as `if true then 1 else false`.

A "static" type analyzer runs before runtime, specifically before the implementation from Lab #3 executes. Therefore, our task is to consume the F- AST same as the previous project, and return the type of the whole program.

Similar to the F- interpreter, the F- type system uses **type environment** to store mappings from variables to types. However, during the type analysis, there are instances where the type of a variable cannot be determined immediately and must be inferred by examining the surrounding code.

Type inference involves two major steps.

**1. Generating type equations (type constraints)** <br/>
This process introduces a type variable for each expressions. A **type variable** is a placeholder that represents types for variables whose types have not yet been determined. By constructing equations based on these type variables, the type system can accurately infer the types of the variables involved.

**2. Solving the generated equations** <br/>
Once the equations are formed, the next step is constructing a **substitution** which is a mapping from type variables to concrete types. The substitution is filled up by solveing the equation and inferring the types of the type variables, including the variable representing the entire program. If a solution exists, the overall type of the program can be determined. If no solution can be found, such as when a contradiction occurs, a type error is raised.

This high-level overview of type inference is underpinned by specific algorithms involving functions such as `APPLY`, `GEN`, `EXTEND`, and `UNIFY`. In summary, our task is to develop the static type system for the F- language by implementing its type inference algorithm in accordance with the F- typing rules.

<br/>

### Details

* `infer`

    * Receives a `Program` and returns the type of the `Program`.
    * Creates a type varaible for the `Program`.
    * Control the type inference process by invoking `GEN` and `iterateEqList`.

* `GEN`

    * Follows the `Gen` algorithm intorduced on the lecture note.
    * Receives an expression, a type environment, and a type, then generates and returns the type equation according to the F- type system. The type equation contains information indicating that the expression has the specified type within the given type environment.
    * Unlike previous implementations, the type equations should be concatenated continuously.

* `APPLY`

    * Follows the `App` algorithm intorduced on the lecture note.
    * Receives a substitution and a type, then apply the substitution to the type. If the type is a type variable that is defined in the substitution, the function returns the defined type.

* `UNIFY`

    * Follows the `Unify` algorithm intorduced on the lecture note.
    * Note that `Unify(t1 = t2, s)` is just a short version of `Extend(App(s,t1) = App(s,t2), s)`

* `EXTEND`

    * Follows the `Extend` algorithm intorduced on the lecture note.
    * The actual function that moves the equation to the substitution.
    * Receives a type equation and a substitution, processes the type equation based on the substitution, and adds it to the substitution if no contradiction is found. Otherwise, raises type error.

* `type IntOrBool`

    * `IntOrBool` is type introduced to support ad-hoc overloading of equality operation.
    * For the equality operation in `GEN`, the type varaible for both left and right expression declared as `IntOrBool`.
    * Be cautious when adding IntOrBool to the type system, as it requires appropriate handling in all relevant `match` cases.

<br/>

<h3 align="center">Thank you for reading, I hope you enjoy the project too 🤩</h3>