(** Owl_bin_prot.Serialise:
    Functions for serialising Owl dense matrices and ndarrays to files. *)

(** Note: Owl matrices are also Owl ndarrays, so everything said
    below about ndarrays also applies to matrices, vectors, etc. *)

(** Type [flattened] hold dense ndarray data prior to/after 
    serialisation.
    [dims] should contained the dimensions of the original ndarray, and
    [vec] should contain a flattened version of the ndarray data.
    ([vec] is defined by [Bin_prot.common]; it is a 
    [(float, float64_elt, fortran_layout) Bigarray.Array1].)  *)
type flattened = { dims : int array; data : Bin_prot.Common.vec; }


(** Functions for serialising and writing to a file: *)

val ndarray_to_flattened : (float, Bigarray.float64_elt) Owl.Dense.Ndarray.Generic.t -> flattened
(** Given an Owl ndarray [x], [ndarray_to_flattened x] returns a [flattened]
    in which the [dims] field contains the dimensions of the original ndarray,
    and the [data] field contains the same data in a 1D [fortran_layout]
    [Bigarray.Array1].  (This is used by [serialise], but can also be used
    by serialisatiion functions for more  complicated types in which
    [flattened]s will be embedded.) *)

val serialise : (float, Bigarray.float64_elt) Owl.Dense.Ndarray.Generic.t -> Bin_prot.Common.buf
(** Given a dense ndarray [x], [serialise x] returns a [bin_prot]
    buffer structure containing a serialised version of an instance of type 
    [flattened], i.e. of an array of dimensions of the original ndarray, and 
    the flattened data from the original ndarray.  A copy of the original
    ndarray can be recreated from the resulting buffer using [unserialise].
    The buffer structure can be saved to a file using [save_serialised]. *)

val save_serialised : Bin_prot.Common.buf -> string -> unit
(** Given a [bin_prot] buffer created with [serialise], writes it to file
    [filename].  If the file exists, it will be zeroed out and recreated. 
    This file can be read using [load_serialised]. *)

val serialise_to_file : (float, Bigarray.float64_elt) Owl.Dense.Ndarray.Generic.t -> string -> unit
(** Given a dense ndarray [x], [serialise_to_file x] transforms it
    into an instance of [flattened], serialises that using [bin_prot], and
    writes the result to file [filename].  If the file exists, it will be 
    zeroed out and recreated. The process can be reversed using 
    [unserialise_from_file]. *)


(** Functions for unserialising and loading from a file: *)

val load_serialised : string -> Bin_prot.Common.buf
(** [load_serialised filename] reads a serialised [flattened] data structure
    from file [filename] and returns it in a [bin_prot] buffer structure.
    This can then be unserialised using [unserialise]. *)

val flattened_to_ndarray : flattened -> (float, Bigarray.float64_elt, Bigarray.c_layout) Bigarray.Genarray.t
(** [flattened_to_ndarray flat], where [flat] is a [flattened], returns a new
    ndarray specified by [flat], i.e. with dimensions [flat.dims] and data from
    [flat.data]. *)

val unserialise : Bin_prot.Common.buf -> (float, Bigarray.float64_elt, Bigarray.c_layout) Bigarray.Genarray.t
(** [unserialise buf] unserialises the [bin_prot] buffer [buf] and
    returns an ndarray specified by the [flattened] that
    is serialised in [buf]. *)

val unserialise_from_file : string -> (float, Bigarray.float64_elt, Bigarray.c_layout) Bigarray.Genarray.t
(** [unserialise_from_file filename] reads a serialised [flattened] data 
    structure from file [filename], unserialises the result, and returns
    the ndarray specified by the unserialised [flattened]. *)


(** Utility functions: *)

val multiply_array_elts : int array -> int
(** Multiply together all elements of an [int array]. *)


(** The functions with names beginning with "bin_" below are defined 
    automatically via [[@@deriving bin_io]] frm the [flattened] type 
    definition. This process uses [ppx_bin_prot].  The definitions are 
    used by higher-level serialisation functions defined here, and can 
    also be used separately, of course. They will also be called if
    you defined serialisable types for embedded matrices/ndarrays using
    [ppx_bin_prot]. *)

val bin_flattened : flattened Bin_prot.Type_class.t

val bin_shape_flattened : Bin_prot.Shape.t
(** There might be more information about this function at 
    https://github.com/janestreet/bin_prot *)

val bin_size_flattened : flattened -> int
(** Return the size in bytes of a [flattened] from [bin_prot]'s point of view. *)

val bin_write_flattened : Bin_prot.Common.buf -> pos:Bin_prot.Common.pos -> flattened -> Bin_prot.Common.pos
(** Given a [bin_prot] buffer an an initial byte position in the buffer
    (e.g. 0), serialise the [flattened] into the buffer starting at that
    position. *)

val bin_writer_flattened : flattened Bin_prot.Type_class.writer
(** There might be more information about this function at 
    https://github.com/janestreet/bin_prot *)

val bin_read_flattened : Bin_prot.Common.buf -> pos_ref:Bin_prot.Common.pos_ref -> flattened
(** Given a [bin_prot] buffer and a variable containing a reference to an
    initial byte positionin the buffer (e.g. [ref 0]), unserialise the
    buffer's contents, starting from that position, and return it as a
    [flattened].  The position reference will contain the position after
    what was read. *)

val bin_reader_flattened : flattened Bin_prot.Type_class.reader
(** There might be more information about this function at 
    https://github.com/janestreet/bin_prot *)

