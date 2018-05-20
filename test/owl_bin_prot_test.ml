(** owl_bin_prot_test.ml: Create and run speed tests on an Owl ndarray. *)

let usage argv =
  print_string "Tests serializing and unserializing ndarrays to/from disk\n";
  Printf.printf "Usage: %s  megabytes_in_file  number_of_cycles  [true/false]\n" argv.(0);
  print_string ("If third argument is present and is \"true\", there will be explicit garbage\n" ^
               "collection between serialize and unserialize events (defaults to \"false\").\n");
  exit 1

let main () =
  let open Sys in (* for argv *)
  let num_args = Array.length argv in
  if num_args < 3 || num_args > 4 then usage argv else
  let mb = int_of_string argv.(1) in
  let cycles = int_of_string argv.(2) in
  let gc = if num_args = 4 then bool_of_string argv.(3) else false in
  Owl_bin_prot.Test.test_serialise ~gc mb cycles

let _ = main ()
