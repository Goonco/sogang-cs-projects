namespace Types

// Raise this exception if the semantics of given program is not defined. Do NOT
// change the name of this exception or remove this definition.
exception UndefinedSemantics

// Variable name that can appear in the program.
type VarName = string

// Value that can appear in this language.
type Val = Int of int | Bool of bool | Loc of VarName

// Memory is a map from variable to value.
type Mem = Map<VarName, Val>
