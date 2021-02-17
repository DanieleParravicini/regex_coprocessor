#!/bin/bash -f
#*********************************************************************************************************
# Vivado (TM) v2019.2 (64-bit)
#
# Filename    : re2_copro.sh
# Simulator   : Synopsys Verilog Compiler Simulator
# Description : Simulation script for compiling, elaborating and verifying the project source files.
#               The script will automatically create the design libraries sub-directories in the run
#               directory, add the library logical mappings in the simulator setup file, create default
#               'do/prj' file, execute compilation, elaboration and simulation steps.
#
# Generated by Vivado on Fri Feb 12 18:37:09 +0100 2021
# SW Build 2708876 on Wed Nov  6 21:40:23 MST 2019
#
# Copyright 1986-2019 Xilinx, Inc. All Rights Reserved. 
#
# usage: re2_copro.sh [-help]
# usage: re2_copro.sh [-lib_map_path]
# usage: re2_copro.sh [-noclean_files]
# usage: re2_copro.sh [-reset_run]
#
# Prerequisite:- To compile and run simulation, you must compile the Xilinx simulation libraries using the
# 'compile_simlib' TCL command. For more information about this command, run 'compile_simlib -help' in the
# Vivado Tcl Shell. Once the libraries have been compiled successfully, specify the -lib_map_path switch
# that points to these libraries and rerun export_simulation. For more information about this switch please
# type 'export_simulation -help' in the Tcl shell.
#
# You can also point to the simulation libraries by either replacing the <SPECIFY_COMPILED_LIB_PATH> in this
# script with the compiled library directory path or specify this path with the '-lib_map_path' switch when
# executing this script. Please type 're2_copro.sh -help' for more information.
#
# Additional references - 'Xilinx Vivado Design Suite User Guide:Logic simulation (UG900)'
#
#*********************************************************************************************************

# Directory path for design sources and include directories (if any) wrt this path
ref_dir="."

# Override directory with 'export_sim_ref_dir' env path value if set in the shell
if [[ (! -z "$export_sim_ref_dir") && ($export_sim_ref_dir != "") ]]; then
  ref_dir="$export_sim_ref_dir"
fi

# Command line options
vlogan_opts="-full64"
vhdlan_opts="-full64"
vcs_elab_opts="-full64 -debug_pp -t ps -licqueue -l elaborate.log"
vcs_sim_opts="-ucli -licqueue -l simulate.log"

# Design libraries
design_libs=(xilinx_vip axi_infrastructure_v1_1_0 axi_vip_v1_1_6 zynq_ultra_ps_e_vip_v1_0_6 xil_defaultlib)

# Simulation root library directory
sim_lib_dir="vcs_lib"

# Script info
echo -e "re2_copro.sh - Script generated by export_simulation (Vivado v2019.2 (64-bit)-id)\n"

# Main steps
run()
{
  check_args $# $1
  setup $1 $2
  compile
  elaborate
  simulate
}

# RUN_STEP: <compile>
compile()
{
  # Compile design files
  vlogan -work xilinx_vip $vlogan_opts -sverilog +incdir+"$ref_dir/../../../../regex_copro.srcs/sources_1/bd/re2_copro/ipshared/ec67/hdl" +incdir+"$ref_dir/../../../../regex_copro.srcs/sources_1/bd/re2_copro/ipshared/0eaf/hdl" +incdir+"$ref_dir/../../../../regex_copro.srcs/sources_1/bd/re2_copro/ip/re2_copro_zynq_ultra_ps_e_0_0/sim_tlm" +incdir+"$ref_dir/../../../../regex_copro.srcs/sources_1/bd/re2_copro/ip/re2_copro_zynq_ultra_ps_e_0_0" +incdir+"C:/Xilinx/Vivado/2019.2/data/xilinx_vip/include" \
    "C:/Xilinx/Vivado/2019.2/data/xilinx_vip/hdl/axi4stream_vip_axi4streampc.sv" \
    "C:/Xilinx/Vivado/2019.2/data/xilinx_vip/hdl/axi_vip_axi4pc.sv" \
    "C:/Xilinx/Vivado/2019.2/data/xilinx_vip/hdl/xil_common_vip_pkg.sv" \
    "C:/Xilinx/Vivado/2019.2/data/xilinx_vip/hdl/axi4stream_vip_pkg.sv" \
    "C:/Xilinx/Vivado/2019.2/data/xilinx_vip/hdl/axi_vip_pkg.sv" \
    "C:/Xilinx/Vivado/2019.2/data/xilinx_vip/hdl/axi4stream_vip_if.sv" \
    "C:/Xilinx/Vivado/2019.2/data/xilinx_vip/hdl/axi_vip_if.sv" \
    "C:/Xilinx/Vivado/2019.2/data/xilinx_vip/hdl/clk_vip_if.sv" \
    "C:/Xilinx/Vivado/2019.2/data/xilinx_vip/hdl/rst_vip_if.sv" \
  2>&1 | tee -a vlogan.log

  vlogan -work axi_infrastructure_v1_1_0 $vlogan_opts +v2k +incdir+"$ref_dir/../../../../regex_copro.srcs/sources_1/bd/re2_copro/ipshared/ec67/hdl" +incdir+"$ref_dir/../../../../regex_copro.srcs/sources_1/bd/re2_copro/ipshared/0eaf/hdl" +incdir+"$ref_dir/../../../../regex_copro.srcs/sources_1/bd/re2_copro/ip/re2_copro_zynq_ultra_ps_e_0_0/sim_tlm" +incdir+"$ref_dir/../../../../regex_copro.srcs/sources_1/bd/re2_copro/ip/re2_copro_zynq_ultra_ps_e_0_0" +incdir+"C:/Xilinx/Vivado/2019.2/data/xilinx_vip/include" \
    "$ref_dir/../../../../regex_copro.srcs/sources_1/bd/re2_copro/ipshared/ec67/hdl/axi_infrastructure_v1_1_vl_rfs.v" \
  2>&1 | tee -a vlogan.log

  vlogan -work axi_vip_v1_1_6 $vlogan_opts -sverilog +incdir+"$ref_dir/../../../../regex_copro.srcs/sources_1/bd/re2_copro/ipshared/ec67/hdl" +incdir+"$ref_dir/../../../../regex_copro.srcs/sources_1/bd/re2_copro/ipshared/0eaf/hdl" +incdir+"$ref_dir/../../../../regex_copro.srcs/sources_1/bd/re2_copro/ip/re2_copro_zynq_ultra_ps_e_0_0/sim_tlm" +incdir+"$ref_dir/../../../../regex_copro.srcs/sources_1/bd/re2_copro/ip/re2_copro_zynq_ultra_ps_e_0_0" +incdir+"C:/Xilinx/Vivado/2019.2/data/xilinx_vip/include" \
    "$ref_dir/../../../../regex_copro.srcs/sources_1/bd/re2_copro/ipshared/dc12/hdl/axi_vip_v1_1_vl_rfs.sv" \
  2>&1 | tee -a vlogan.log

  vlogan -work zynq_ultra_ps_e_vip_v1_0_6 $vlogan_opts -sverilog +incdir+"$ref_dir/../../../../regex_copro.srcs/sources_1/bd/re2_copro/ipshared/ec67/hdl" +incdir+"$ref_dir/../../../../regex_copro.srcs/sources_1/bd/re2_copro/ipshared/0eaf/hdl" +incdir+"$ref_dir/../../../../regex_copro.srcs/sources_1/bd/re2_copro/ip/re2_copro_zynq_ultra_ps_e_0_0/sim_tlm" +incdir+"$ref_dir/../../../../regex_copro.srcs/sources_1/bd/re2_copro/ip/re2_copro_zynq_ultra_ps_e_0_0" +incdir+"C:/Xilinx/Vivado/2019.2/data/xilinx_vip/include" \
    "$ref_dir/../../../../regex_copro.srcs/sources_1/bd/re2_copro/ipshared/0eaf/hdl/zynq_ultra_ps_e_vip_v1_0_vl_rfs.sv" \
  2>&1 | tee -a vlogan.log

  vlogan -work xil_defaultlib $vlogan_opts +v2k +incdir+"$ref_dir/../../../../regex_copro.srcs/sources_1/bd/re2_copro/ipshared/ec67/hdl" +incdir+"$ref_dir/../../../../regex_copro.srcs/sources_1/bd/re2_copro/ipshared/0eaf/hdl" +incdir+"$ref_dir/../../../../regex_copro.srcs/sources_1/bd/re2_copro/ip/re2_copro_zynq_ultra_ps_e_0_0/sim_tlm" +incdir+"$ref_dir/../../../../regex_copro.srcs/sources_1/bd/re2_copro/ip/re2_copro_zynq_ultra_ps_e_0_0" +incdir+"C:/Xilinx/Vivado/2019.2/data/xilinx_vip/include" \
    "$ref_dir/../../../bd/re2_copro/ip/re2_copro_zynq_ultra_ps_e_0_0/sim/re2_copro_zynq_ultra_ps_e_0_0_vip_wrapper.v" \
    "$ref_dir/../../../bd/re2_copro/ipshared/7671/hdl/re2_copro_v1_S00_AXI.v" \
  2>&1 | tee -a vlogan.log

  vlogan -work xil_defaultlib $vlogan_opts -sverilog +incdir+"$ref_dir/../../../../regex_copro.srcs/sources_1/bd/re2_copro/ipshared/ec67/hdl" +incdir+"$ref_dir/../../../../regex_copro.srcs/sources_1/bd/re2_copro/ipshared/0eaf/hdl" +incdir+"$ref_dir/../../../../regex_copro.srcs/sources_1/bd/re2_copro/ip/re2_copro_zynq_ultra_ps_e_0_0/sim_tlm" +incdir+"$ref_dir/../../../../regex_copro.srcs/sources_1/bd/re2_copro/ip/re2_copro_zynq_ultra_ps_e_0_0" +incdir+"C:/Xilinx/Vivado/2019.2/data/xilinx_vip/include" \
    "$ref_dir/../../../../regex_copro.srcs/sources_1/bd/hdl_src/rtl/AXI/AXI_package.sv" \
    "$ref_dir/../../../../regex_copro.srcs/sources_1/bd/hdl_src/rtl/AXI/AXI_top.sv" \
    "$ref_dir/../../../../regex_copro.srcs/sources_1/bd/hdl_src/rtl/arbiters/arbiter_2_fixed.sv" \
    "$ref_dir/../../../../regex_copro.srcs/sources_1/bd/hdl_src/rtl/arbiters/arbiter_2_rr.sv" \
    "$ref_dir/../../../../regex_copro.srcs/sources_1/bd/hdl_src/rtl/arbiters/arbiter_fixed.sv" \
    "$ref_dir/../../../../regex_copro.srcs/sources_1/bd/hdl_src/rtl/arbiters/arbiter_rr_n.sv" \
    "$ref_dir/../../../../regex_copro.srcs/sources_1/bd/hdl_src/rtl/arbiters/arbitration_logic_fixed.sv" \
    "$ref_dir/../../../../regex_copro.srcs/sources_1/bd/hdl_src/rtl/arbiters/arbitration_logic_rr.sv" \
    "$ref_dir/../../../../regex_copro.srcs/sources_1/bd/hdl_src/rtl/memories/bram.sv" \
    "$ref_dir/../../../../regex_copro.srcs/sources_1/bd/hdl_src/rtl/memories/cache_block_directly_mapped.sv" \
    "$ref_dir/../../../../regex_copro.srcs/sources_1/bd/hdl_src/rtl/coprocessor/channel.sv" \
    "$ref_dir/../../../../regex_copro.srcs/sources_1/bd/hdl_src/rtl/coprocessor/channel_iface.sv" \
    "$ref_dir/../../../../regex_copro.srcs/sources_1/bd/hdl_src/rtl/coprocessor/engine.sv" \
    "$ref_dir/../../../../regex_copro.srcs/sources_1/bd/hdl_src/rtl/coprocessor/engine_and_station.sv" \
    "$ref_dir/../../../../regex_copro.srcs/sources_1/bd/hdl_src/rtl/coprocessor/engine_interfaced.sv" \
    "$ref_dir/../../../../regex_copro.srcs/sources_1/bd/hdl_src/rtl/fifo.sv" \
    "$ref_dir/../../../../regex_copro.srcs/sources_1/bd/hdl_src/rtl/CPU/instruction.sv" \
    "$ref_dir/../../../../regex_copro.srcs/sources_1/bd/hdl_src/rtl/memories/memory_read_iface.sv" \
    "$ref_dir/../../../../regex_copro.srcs/sources_1/bd/hdl_src/rtl/coprocessor/ping_pong_buffer.sv" \
    "$ref_dir/../../../../regex_copro.srcs/sources_1/bd/hdl_src/rtl/coprocessor/regex_coprocessor_package.sv" \
    "$ref_dir/../../../../regex_copro.srcs/sources_1/bd/hdl_src/rtl/coprocessor/regex_coprocessor_top.sv" \
    "$ref_dir/../../../../regex_copro.srcs/sources_1/bd/hdl_src/rtl/CPU/regex_cpu.sv" \
    "$ref_dir/../../../../regex_copro.srcs/sources_1/bd/hdl_src/rtl/CPU/regex_cpu_pipelined.sv" \
    "$ref_dir/../../../../regex_copro.srcs/sources_1/bd/hdl_src/rtl/coprocessor/switch.sv" \
    "$ref_dir/../../../../regex_copro.srcs/sources_1/bd/hdl_src/rtl/coprocessor/topology_single.sv" \
    "$ref_dir/../../../../regex_copro.srcs/sources_1/bd/hdl_src/rtl/coprocessor/topology_token_ring.sv" \
  2>&1 | tee -a vlogan.log

  vlogan -work xil_defaultlib $vlogan_opts +v2k +incdir+"$ref_dir/../../../../regex_copro.srcs/sources_1/bd/re2_copro/ipshared/ec67/hdl" +incdir+"$ref_dir/../../../../regex_copro.srcs/sources_1/bd/re2_copro/ipshared/0eaf/hdl" +incdir+"$ref_dir/../../../../regex_copro.srcs/sources_1/bd/re2_copro/ip/re2_copro_zynq_ultra_ps_e_0_0/sim_tlm" +incdir+"$ref_dir/../../../../regex_copro.srcs/sources_1/bd/re2_copro/ip/re2_copro_zynq_ultra_ps_e_0_0" +incdir+"C:/Xilinx/Vivado/2019.2/data/xilinx_vip/include" \
    "$ref_dir/../../../bd/re2_copro/ipshared/7671/hdl/re2_copro_v1.v" \
    "$ref_dir/../../../bd/re2_copro/ip/re2_copro_re2_copro_0_1/sim/re2_copro_re2_copro_0_1.v" \
    "$ref_dir/c:/Users/danie/Documents/GitHub/regex_coprocessor_safe/proj/regex_copro/regex_copro.srcs/sources_1/bd/re2_copro/ip/re2_copro_xbar_1/re2_copro_xbar_1_sim_netlist.v" \
    "$ref_dir/c:/Users/danie/Documents/GitHub/regex_coprocessor_safe/proj/regex_copro/regex_copro.srcs/sources_1/bd/re2_copro/ip/re2_copro_rst_ps8_0_100M_0/re2_copro_rst_ps8_0_100M_0_sim_netlist.v" \
    "$ref_dir/c:/Users/danie/Documents/GitHub/regex_coprocessor_safe/proj/regex_copro/regex_copro.srcs/sources_1/bd/re2_copro/ip/re2_copro_auto_ds_0/re2_copro_auto_ds_0_sim_netlist.v" \
    "$ref_dir/c:/Users/danie/Documents/GitHub/regex_coprocessor_safe/proj/regex_copro/regex_copro.srcs/sources_1/bd/re2_copro/ip/re2_copro_auto_pc_0/re2_copro_auto_pc_0_sim_netlist.v" \
    "$ref_dir/c:/Users/danie/Documents/GitHub/regex_coprocessor_safe/proj/regex_copro/regex_copro.srcs/sources_1/bd/re2_copro/ip/re2_copro_auto_ds_1/re2_copro_auto_ds_1_sim_netlist.v" \
    "$ref_dir/c:/Users/danie/Documents/GitHub/regex_coprocessor_safe/proj/regex_copro/regex_copro.srcs/sources_1/bd/re2_copro/ip/re2_copro_auto_pc_1/re2_copro_auto_pc_1_sim_netlist.v" \
    "$ref_dir/../../../bd/re2_copro/sim/re2_copro.v" \
  2>&1 | tee -a vlogan.log


  vlogan -work xil_defaultlib $vlogan_opts +v2k \
    glbl.v \
  2>&1 | tee -a vlogan.log

}

# RUN_STEP: <elaborate>
elaborate()
{
  vcs $vcs_elab_opts xil_defaultlib.re2_copro xil_defaultlib.glbl -o re2_copro_simv
}

# RUN_STEP: <simulate>
simulate()
{
  ./re2_copro_simv $vcs_sim_opts -do simulate.do
}

# STEP: setup
setup()
{
  case $1 in
    "-lib_map_path" )
      if [[ ($2 == "") ]]; then
        echo -e "ERROR: Simulation library directory path not specified (type \"./re2_copro.sh -help\" for more information)\n"
        exit 1
      fi
      create_lib_mappings $2
    ;;
    "-reset_run" )
      reset_run
      echo -e "INFO: Simulation run files deleted.\n"
      exit 0
    ;;
    "-noclean_files" )
      # do not remove previous data
    ;;
    * )
      create_lib_mappings $2
  esac

  create_lib_dir

  # Add any setup/initialization commands here:-

  # <user specific commands>

}

# Define design library mappings
create_lib_mappings()
{
  file="synopsys_sim.setup"
  if [[ -e $file ]]; then
    if [[ ($1 == "") ]]; then
      return
    else
      rm -rf $file
    fi
  fi

  touch $file

  lib_map_path=""
  if [[ ($1 != "") ]]; then
    lib_map_path="$1"
  fi

  for (( i=0; i<${#design_libs[*]}; i++ )); do
    lib="${design_libs[i]}"
    mapping="$lib:$sim_lib_dir/$lib"
    echo $mapping >> $file
  done

  if [[ ($lib_map_path != "") ]]; then
    incl_ref="OTHERS=$lib_map_path/synopsys_sim.setup"
    echo $incl_ref >> $file
  fi
}

# Create design library directory paths
create_lib_dir()
{
  if [[ -e $sim_lib_dir ]]; then
    rm -rf $sim_lib_dir
  fi

  for (( i=0; i<${#design_libs[*]}; i++ )); do
    lib="${design_libs[i]}"
    lib_dir="$sim_lib_dir/$lib"
    if [[ ! -e $lib_dir ]]; then
      mkdir -p $lib_dir
    fi
  done
}

# Delete generated data from the previous run
reset_run()
{
  files_to_remove=(ucli.key re2_copro_simv vlogan.log vhdlan.log compile.log elaborate.log simulate.log .vlogansetup.env .vlogansetup.args .vcs_lib_lock scirocco_command.log 64 AN.DB csrc re2_copro_simv.daidir)
  for (( i=0; i<${#files_to_remove[*]}; i++ )); do
    file="${files_to_remove[i]}"
    if [[ -e $file ]]; then
      rm -rf $file
    fi
  done

  create_lib_dir
}

# Check command line arguments
check_args()
{
  if [[ ($1 == 1 ) && ($2 != "-lib_map_path" && $2 != "-noclean_files" && $2 != "-reset_run" && $2 != "-help" && $2 != "-h") ]]; then
    echo -e "ERROR: Unknown option specified '$2' (type \"./re2_copro.sh -help\" for more information)\n"
    exit 1
  fi

  if [[ ($2 == "-help" || $2 == "-h") ]]; then
    usage
  fi
}

# Script usage
usage()
{
  msg="Usage: re2_copro.sh [-help]\n\
Usage: re2_copro.sh [-lib_map_path]\n\
Usage: re2_copro.sh [-reset_run]\n\
Usage: re2_copro.sh [-noclean_files]\n\n\
[-help] -- Print help information for this script\n\n\
[-lib_map_path <path>] -- Compiled simulation library directory path. The simulation library is compiled\n\
using the compile_simlib tcl command. Please see 'compile_simlib -help' for more information.\n\n\
[-reset_run] -- Recreate simulator setup files and library mappings for a clean run. The generated files\n\
from the previous run will be removed. If you don't want to remove the simulator generated files, use the\n\
-noclean_files switch.\n\n\
[-noclean_files] -- Reset previous run, but do not remove simulator generated files from the previous run.\n\n"
  echo -e $msg
  exit 1
}

# Launch script
run $1 $2