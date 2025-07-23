module P6

/// From list 'l', find the element that appears most frequently in the list,
/// and return how many times it appears. If the input list is empty, return 0.

let rec makeDict (l: List<'a>) : Map<'a, int> =
  match l with
  | [] -> Map.empty
  | head::tail -> (
    let tmpMap = makeDict tail in
    if Map.containsKey head tmpMap then
      Map.add head ((Map.find head tmpMap)+1) tmpMap
    else
      Map.add head 1 tmpMap
  )

let rec findMax (l: List<'a * int>) : int =
  match l with
  | [] -> 0
  | (_, candidateMax)::tail -> (
    let originMax : int = findMax tail in
    if originMax > candidateMax then originMax else candidateMax
  )

let countMostFrequent (l: List<'a>) : int =
  let dict : Map<'a, int> = makeDict l in
  findMax (Map.toList dict)
