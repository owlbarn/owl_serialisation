Serializing embedded matrices/ndarrays
==

What if you want to serialize a complex type that contains Owl dense
matrices or ndarrays?  You can create a corresponding type in which the
`flattened` type is embedded.  This is the type that's used as an
intermediate storage format for Owl matrices/ndarrays.  It's actually
instances of `flattened` that are serialized.

The idea is that you define the type containing `flattened`s using
`[@@deriving bin_io]`, and that will generate special purpose
serialization functions, as long as `bin_prot` knows about the
structures you use to embed the Owl matrices or ndarrays.

Then you can serialize data to a file form using the new functions along
with `save_serialized` and `load_serialized` from `Owl_bin_prot`.

Here is an example in `utop`, running it from the repo directory.
(Doing this in `utop` allows us to see what functions are created by
`[@@deriving bin_io]`.  The first `#` on each line is `utop`'s.  See
`src/jbuild` for an illustration of what you need to do to use
`ppx_bin_prot` with `dune/jbuilder`.)

Start `utop` with
```
`jbuilder utop src/owl_bin_prot`
```
or use
```
utop -I ./_build/install/default/lib/owl_bin_prot
```
and then execute `#load "owl_bin_prot"` in `utop`.

```OCaml
# #require "ppx_bin_prot";;
# open Bin_prot.Std;;

(* Define an intermediate type for lists of Owl ndarrays, along
   with serialization helper functions: *)
# type flatlist = Owl_bin_prot.flattened list [@@deriving bin_io];;
type flatlist = Owl_bin_prot.flattened list
val bin_shape_flatlist : Bin_prot.Shape.t = <abstr>
val bin_size_flatlist : Owl_bin_prot.flattened list -> int = <fun>
val bin_write_flatlist : Bin_prot.Common.buf -> pos:int -> Owl_bin_prot.flattened list -> int = <fun>
val bin_writer_flatlist : Owl_bin_prot.flattened list Bin_prot.Type_class.writer0 = {Bin_prot.Type_class.size = <fun>; write = <fun>}
val bin_read_flatlist : Bin_prot.Common.buf -> pos_ref:Bin_prot.Common.pos_ref -> Owl_bin_prot.flattened list = <fun>
val bin_reader_flatlist : Owl_bin_prot.flattened list Bin_prot.Type_class.reader0 = {Bin_prot.Type_class.read = <fun>; vtag_read = <fun>}
val bin_flatlist : Owl_bin_prot.flattened list Bin_prot.Type_class.t0 =
  {Bin_prot.Type_class.shape = <abstr>; writer = {Bin_prot.Type_class.size = <fun>; write = <fun>}; reader = {Bin_prot.Type_class.read = <fun>; vtag_read = <fun>}}

(* Some sample data: *)
# let mats = Owl.Mat.( [(uniform 4 5); (uniform 10 20); (uniform 30 40)] );;

(* Convert it to a list of flatteneds: *)
# let flats = List.map Owl_bin_prot.ndarray_to_flattened mats;;
val flats : Owl_bin_prot.flattened list =
  [{Owl_bin_prot.dims = [|4; 5|]; data = <abstr>};
   {Owl_bin_prot.dims = [|10; 20|]; data = <abstr>};
   {Owl_bin_prot.dims = [|30; 40|]; data = <abstr>}]

(* Serialize the list of flatteneds to a buffer using the automatically 
   generated bin_prot functions: *)
# let buf = Bin_prot.Common.create_buf (bin_size_flatlist flats);;
# bin_write_flatlist buf 0 flats;;
- : int = 11377

(* Save the buffer to a file: *)
# Owl_bin_prot.save_serialized buf "flats.bin";;
(* There's nothing very special in this function; you could use some
   other method for saving the buffer. *)

(* Read the file back in, returning a new buffer: *)
# let buf' = Owl_bin_prot.load_serialized "flats.bin";;

(* Unserialize the buffer: *)
# let flats' = bin_read_flatlist buf' (ref 0);;

(* Convert the list of flatteneds back to a list of matrices: *)
# let mats' = List.map Owl_bin_prot.flattened_to_ndarray flats';;

(* Check that the original and new versions of the data are the same: *)
# mats = mats';;
- : bool = true
```
