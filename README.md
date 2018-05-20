owl-serialisation
====

Functions for serlialising Owl matrices and NDarrays.

At present only [bin_prot](https://github.com/janestreet/bin_prot)-based
serialisation for dense matrices is provided.  See
[doc/bin_prot.md](doc/bin_prot.md).

Other kinds of serialization are expected to be added, such as json,
npy, and possibly hdf5.

## Setup

To build: `make`.

*TODO: Installation instructions, opam, etc.*

To build docs: `make doc`.  Then open
`_build/default/_doc/_html/owl_bin_prot/Owl_bin_prot/index.html` in a
browser.  (Or use e.g. `odig odoc` after installing `odig` and `odoc`.)

## Note

When using the functions in this library, North Americans and some
others may want to keep in mind that the code in this library uses British
spelling for the word "seriali**s**ation".
