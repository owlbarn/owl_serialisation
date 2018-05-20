(** Owl_bin_prot.Serialise:
    Functions for serializing Owl dense matrices and ndarrays to files. *)

open Bin_prot.Std    (* for @@deriving bin_prot *)
open Bin_prot.Common (* for @@deriving bin_prot *)

let multiply_array_elts ra = Array.fold_left ( * ) 1 ra

type flattened = {dims : int array ; data : vec} [@@deriving bin_io]

let ndarray_to_flattened x =
  let dims = Owl.Dense.Ndarray.Generic.shape x in
  let len = multiply_array_elts dims in
  let x' = Bigarray.Genarray.change_layout x Bigarray.fortran_layout in
  let data = Bigarray.reshape_1 x' len in  (* Bigarray.Array1 with float64 and fortran_layout is compatible with Bin_prot's vec *)
  {dims; data}

let serialise x =
  let flat = ndarray_to_flattened x in
  let size = bin_size_flattened flat in
  let buf = create_buf size in
  ignore(bin_write_flattened buf 0 flat);
  buf

let save_serialised buf filename =
  let size = buf_len buf in
  let write_file fd = Core.Bigstring.write fd ~pos:0 ~len:size buf in
  let num_written =
    Core.Unix.with_file filename ~mode:[O_WRONLY; O_CREAT; O_TRUNC] ~f:write_file (* QUESTION: O_TRUNC ... What should be done if the file exists? *)
  in
  if num_written <> size
  then failwith (Printf.sprintf "serialise: %d bytes written to file for a %d-byte buffer"
                                num_written  size) (* QUESTION: Use a proper exception? *)
  else ()

let serialise_to_file x filename =
  save_serialised (serialise x) filename


let load_serialised filename =
  let read_file fd =
    let stats = Core.Unix.fstat fd in  (* QUESTION: Will this work correctly on symbolic links? If not use stat on the filename. *)
    let size = Int64.to_int (stats.st_size) in
    let buf = Bin_prot.Common.create_buf size in
    let num_read = Core.Bigstring.read ~pos:0 ~len:size fd buf in
    if num_read <> size
    then failwith (Printf.sprintf "load_serialised: %d bytes read from a %d-byte file"
                                  num_read size) (* Use a proper exception? *)
    else buf
  in Core.Unix.(with_file filename ~mode:[O_RDONLY] ~f:read_file)

let flattened_to_ndarray flat =
  let {dims; data} = flat in
  let still_flat = Bigarray.Array1.change_layout data Bigarray.c_layout in
  Bigarray.reshape (Bigarray.genarray_of_array1 still_flat) dims

let unserialise buf =
  let posref = ref 0 in
  let flat = bin_read_flattened buf posref in
  flattened_to_ndarray flat

let unserialise_from_file filename =
  unserialise (load_serialised filename)
