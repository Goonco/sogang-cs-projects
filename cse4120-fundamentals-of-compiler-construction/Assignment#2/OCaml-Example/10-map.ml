module IMap = Map.Make(String)

let m1 = IMap.empty
let m2 = IMap.add "a" 3 m1
let m3 = IMap.add "a" 4 m2
let m4 = IMap.add "b" 5 m3

let has_c = IMap.mem "c" m4 (* false *)
let has_b = IMap.mem "a" m4 (* true *)
let i = IMap.find "a" m4    (* 4 *)

let _ = Printf.printf "%b %b %d\n" has_c has_b i
