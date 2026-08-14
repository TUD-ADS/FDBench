# build.tcl - Vivado automation
set main_project_name "FIFO_RSEQ_D"
set proj_name   "FIFO_RSEQ"
set proj_dir    "./$main_project_name/FIFO_RSEQ_"
set build_dir   "./$main_project_name/build"
set part        "xc7z020clg484-1"

set rtl_glob    "./$main_project_name/rtl/*.vhd"
set tb_glob     "./$main_project_name/tb/*_tb.vhd"
set xdc_glob    "./constraints/*.xdc"

# Entity top name <change>
set rtl_top_e   "FIFO_RSEQ"
set tb_top_e   "FIFO_RSEQ_tb"

set rtl_top     "./$main_project_name/rtl"
set tb_top      "./$main_project_name/tb"
set vivado_tool "Vivado 2022.2"
set rtl_dir     "./rtl"
set tb_dir      "./tb"
set src_dir [glob -type d ./*.srcs]
set full_src_rtl "$src_dir/sources_1/new"
set full_src_tb "$src_dir/sim_1/new"

catch {file mkdir $main_project_name}

# Clean build directory each run
if {[file exists $build_dir]} {
    puts "Cleaning build directory: $build_dir"
    file delete -force $build_dir
}
file mkdir $build_dir

catch { exec cmd.exe /c robocopy "./" "./$main_project_name" build.tcl run_case.dat } result

if {![file exists $tb_top]} {
catch {file mkdir $rtl_top}
catch {file mkdir $tb_top}
catch { exec cmd.exe /c robocopy "$full_src_tb" "$tb_top" /E } result
catch { exec cmd.exe /c robocopy "$full_src_rtl" "$rtl_top" /E } result
}

# create project
create_project $proj_name $proj_dir -part $part -force

# add rtl
foreach f [glob -nocomplain $rtl_glob] {
  add_files $f
}

# set up top for below code then Must use entity name & Must match exactly (case-sensitive!)
set_property top $rtl_top_e [current_fileset]
update_compile_order -fileset sources_1

# add constraints 
#foreach f [glob -nocomplain $xdc_glob] {
#  add_files $f
#}

# add tb if present
set tb_list [glob -nocomplain $tb_glob]
set run_sim 0
if {[llength $tb_list] > 0} {
  set run_sim 1
  foreach f $tb_list {
    add_files -fileset sim_1 $f
  }
  catch { set_property top $tb_top_e [get_filesets sim_1] }
  update_compile_order -fileset sim_1
}



launch_runs synth_1
wait_on_run synth_1
open_run synth_1
write_checkpoint -force [file join $build_dir post_synth.dcp]

launch_runs impl_1
wait_on_run impl_1
open_run impl_1
report_utilization    -file [file join $build_dir utilization.rpt]
report_timing_summary -file [file join $build_dir timing_summary.rpt]


# Simulation (if TB exists)
set sim_log [file join $build_dir sim.log]
if {$run_sim} {
  launch_simulation -simset sim_1 -mode behavioral
  log_wave -recursive *
  run all
  catch { write_waveform -file [file join $build_dir waveform.wdb] }
  if {[file exists "vivado.log"]} {
    file copy -force "vivado.log" $sim_log
  } else {
    # create empty log
    set fd [open $sim_log w]; puts $fd "No vivado.log"; close $fd
  }
} else {
  # no sim run
  set fd [open $sim_log w]; puts $fd "Simulation not run (no TB)"; close $fd
}



