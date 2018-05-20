(** Owl_bin_prot.Test:
    Functions for speed tests on Owl_bin_prot serialisation functions.
    These also be used as the basis of regression tests. *)


(* These next two should go somewhere else since they're not owl_bin_prot specific: *)

val time_print_return : (unit -> 'a) -> 'a
(** Run function that has unit arg, print timing info to stdout, and return 
    result. *)

val time_return_times : (unit -> 'a) -> 'a * float * float
(** Run function that has unit arg, return its result as the first element 
    of a triple.  The other elements are cpu time and wall time. *)

val test_serialise_once : ?gc:bool -> (float, Bigarray.float64_elt) Owl.Dense.Ndarray.Generic.t -> bool * float list
(** [test_serialise nd] serialises ndarray [nd] to a temporary 
    file.  The result is then unserialised from the file and checked to see if the
    original and copy are equal.  A pair is returned.  The first element is
    true or false, depending on whether the unseralied ndarray is equal to the
    original one.  The second element is a list of four floats, representing
    cpu time spent serialising and writing to disk, wall time in the same
    operations, cpu time spent reading from disk and unserialising, and wall 
    time in those opeations.  If [~gc] is true, the will be a garbage collection
    before each serialisation-and-write or read-and-unserialise. *)

val test_serialise : ?gc:bool -> int -> int -> unit
(** [test_serialise m cycles] creates an ndarray with [m] million elements
    and passes it to [test_serialise_once] [cycle] times.  [test_serialise]
    sums the cpu and wall times for serialisation-and-write-to-disk and 
    read-from-disk-and-unserialise steps performed by [test_serialise_once]
    and reports their average values over all [cycle] runs.  [gc] is [false]
    by default, and is passed to [test_serialise_once].  See that function's
    doc for explanation of [gc]. *)
