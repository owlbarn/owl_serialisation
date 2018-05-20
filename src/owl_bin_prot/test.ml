(** Owl_bin_prot.Test:
    Functions for speed tests on Owl_bin_prot serialisation functions.
    These also be used as the basis of regression tests. *)

let time_print_return f =
    let cpu_time, wall_time = Sys.time(), Unix.gettimeofday() in
    let result = f () in
    Printf.printf "cpu: %fs, wall: %fs\n%!" (Sys.time() -. cpu_time) (Unix.gettimeofday() -. wall_time);
    result

let time_return_times f =
    let cpu_time, wall_time = Sys.time(), Unix.gettimeofday() in
    let result = f () in
    let cpu_time = Sys.time() -. cpu_time in
    let wall_time = Unix.gettimeofday() -. wall_time in
    (result, cpu_time, wall_time)

let test_serialise_once ?(gc=false) nd =
  let filename = Core.Filename.temp_file "owl_bin_prot_test" "" in
  if gc then Gc.major ();
  let (_, serial_cpu, serial_wall) =
    time_return_times (fun () -> Serialise.serialise_to_file nd filename)
  in
  if gc then Gc.major ();
  let (nd', unser_cpu, unser_wall) =
    time_return_times (fun () -> Serialise.unserialise_from_file filename)
  in
  Core.Unix.unlink filename;
  nd = nd', [serial_cpu; serial_wall; unser_cpu; unser_wall]

[@@@ warning "-8"] (* disable match warning on the list assignment. https://stackoverflow.com/a/46006016/1455243 *)
let test_serialise ?(gc=false) m cycles =
  let xdim, ydim, zdim = 1000, 1000, m in
  let nd = Owl.Arr.uniform [| xdim ; ydim ; zdim |] in
  let float_cycles = float cycles in
  let init_times = [0.; 0.; 0.; 0.] in
  let times = ref init_times in
  for i = 1 to cycles do
    let (_, new_times) = test_serialise_once ~gc nd in (* TODO: Add test for false? *)
    times := List.map2 (+.) !times new_times
  done;
  let [avg_serial_cpu; avg_serial_wall; avg_unser_cpu; avg_unser_wall] = 
        List.map (fun x -> x /. float_cycles) !times
  in
  Printf.printf "%d trials with a %dM-element ndarray:\n%!" cycles m;
  Printf.printf "average for serialisation:   cpu: %fs, wall: %fs\n%!" avg_serial_cpu avg_serial_wall;
  Printf.printf "average for unserialisation: cpu: %fs, wall: %fs\n%!" avg_unser_cpu  avg_unser_wall
[@@@ warning "+8"]
