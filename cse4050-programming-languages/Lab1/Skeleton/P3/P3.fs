module P3

// (Note) Int this problem, you are NOT allowed to use the pre-defined library
// function, 'List.unzip'.

/// Take "a list of pairs" as input and split those pairs into "a pair of two
/// lists". For example, "unzip [(1, 10); (2, 20); (3, 30)]" must return
/// "([1; 2; 3], [10; 20; 30])" as a result.
let rec unzip (l: ('a * 'b) list) : 'a list * 'b list =
  ([], []) // TODO
