Owl serialization with `bin_prot`
====

`owl-serialization` provides functions for serializing Owl dense
matrices and ndarrays using https://github.com/janestreet/bin_prot,
among other things.

## Loading

See `owl-serialisation` installation instructions.  Or to load directly
into utop, load bin_prot.cma.  (NEED MORE.)

## Basic usage

For an Owl dense matrix or ndarray `x`:

```OCaml
(* Serialize x and write it into file x.bin.  If x.bin exists, it will
be truncated and overwritten. *)
Owl_bin_prot.serialize_to_file x "x.bin"

(* Read the data back in from the file: *)
let x' = Owl_bin_prot.unserialize_from_file "x.bin"

(* Check that the old and new versions are equal: *)
x = x'
```

For more fine-grained options, see generated docs or the file
`src/owl_bin_prot/serialisation.mli`.

To see how to serialize data structures in which Owl matrices or
ndarrays are embedded, see
[bin_prot_embedded.md](./bin_prot_embedded.md) in the `doc`
directory.
