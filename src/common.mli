module type Showable = sig
  type t
  val to_string : t -> string
end

module Position : Showable with type t = Lexing.position

val format_error_message : string -> string -> string
