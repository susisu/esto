open Core

type 'a t = Lit of 'a * Value.t
          | Var of 'a * string
          | Vec of 'a * 'a t list
          | App of 'a * 'a t * 'a t
          | Let of 'a * string * 'a t * 'a t


let rec equal t1 t2 = match (t1, t2) with
  | (Lit (_, v1), Lit (_, v2)) -> Value.equal v1 v2
  | (Lit _, _) -> false
  | (Var (_, name1), Var (_, name2)) -> name1 = name2
  | (Var _, _) -> false
  | (Vec (_, elems1), Vec (_, elems2)) ->
    begin
      let module U = List.Or_unequal_lengths in
      match List.for_all2 elems1 elems2 ~f:equal with
      | U.Ok r -> r
      | U.Unequal_lengths -> false
    end
  | (Vec _, _) -> false
  | (App (_, func1, arg1), App (_, func2, arg2)) -> equal func1 func2 && equal arg1 arg2
  | (App _, _) -> false
  | (Let (_, name1, expr1, body1), Let (_, name2, expr2, body2)) ->
    name1 = name2 && equal expr1 expr2 && equal body1 body2
  | (Let _, _) -> false

let get_info = function
  | Lit (info, _) -> info
  | Var (info, _) -> info
  | Vec (info, _) -> info
  | App (info, _, _) -> info
  | Let (info, _, _, _) -> info

let rec to_string = function
  | Lit (_, v) -> Value.to_string v
  | Var (_, name) -> name
  | Vec (_, elems) ->
    let elems_str = String.concat ~sep:", " (List.map elems ~f:to_string) in
    "[" ^ elems_str ^ "]"
  | App (_, func, arg) ->
    let func_str = match func with
      | Lit _ | Var _ | Vec _ | App _ -> to_string func
      | Let _ -> "(" ^ to_string func ^ ")"
    in
    let arg_str = match arg with
      | Lit _ | Var _ | Vec _ -> to_string arg
      | App _ | Let _ -> "(" ^ to_string arg ^ ")"
    in
    func_str ^ " " ^ arg_str
  | Let (_, name, expr, body) -> sprintf "let %s = %s in %s" name (to_string expr) (to_string body)
