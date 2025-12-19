
################################################################
# This is a generated script based on design: design_1
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

namespace eval _tcl {
proc get_script_folder {} {
   set script_path [file normalize [info script]]
   set script_folder [file dirname $script_path]
   return $script_folder
}
}
variable script_folder
set script_folder [_tcl::get_script_folder]

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2018.3
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   catch {common::send_msg_id "BD_TCL-109" "ERROR" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."}

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source design_1_script.tcl


# The design that will be created by this Tcl script contains the following 
# module references:
# ad7606_driver, adc_to_fft_buffer, auto_nrst, digital_agc, fft_freq_meter, fft_sys_controller, freq_screen_driver, seg_driver

# Please add the sources of those modules before sourcing this Tcl script.

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xc7a35tftg256-1
}


# CHANGE DESIGN NAME HERE
variable design_name
set design_name design_1

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      common::send_msg_id "BD_TCL-001" "INFO" "Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   common::send_msg_id "BD_TCL-002" "INFO" "Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   common::send_msg_id "BD_TCL-003" "INFO" "Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   common::send_msg_id "BD_TCL-004" "INFO" "Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

common::send_msg_id "BD_TCL-005" "INFO" "Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   catch {common::send_msg_id "BD_TCL-114" "ERROR" $errMsg}
   return $nRet
}

##################################################################
# DESIGN PROCs
##################################################################



# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  variable script_folder
  variable design_name

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports

  # Create ports
  set aclk [ create_bd_port -dir I -type clk aclk ]
  set_property -dict [ list \
   CONFIG.ASSOCIATED_RESET {aresetn} \
   CONFIG.FREQ_HZ {50000000} \
 ] $aclk
  set ad_busy_0 [ create_bd_port -dir I ad_busy_0 ]
  set ad_convst_0 [ create_bd_port -dir O ad_convst_0 ]
  set ad_cs_0 [ create_bd_port -dir O ad_cs_0 ]
  set ad_data_in_0 [ create_bd_port -dir I -from 15 -to 0 ad_data_in_0 ]
  set ad_rd_0 [ create_bd_port -dir O ad_rd_0 ]
  set ad_reset_0 [ create_bd_port -dir O -type rst ad_reset_0 ]
  set agc_enable_0 [ create_bd_port -dir I agc_enable_0 ]
  set aresetn [ create_bd_port -dir I -type rst aresetn ]
  set fft_valid [ create_bd_port -dir O fft_valid ]
  set measure_done [ create_bd_port -dir O measure_done ]
  set seg [ create_bd_port -dir O -from 7 -to 0 seg ]
  set sel [ create_bd_port -dir O -from 5 -to 0 sel ]
  set sw_points_0 [ create_bd_port -dir I -from 1 -to 0 sw_points_0 ]
  set uart_tx_0 [ create_bd_port -dir O uart_tx_0 ]

  # Create instance: ad7606_driver_0, and set properties
  set block_name ad7606_driver
  set block_cell_name ad7606_driver_0
  if { [catch {set ad7606_driver_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_msg_id "BD_TCL-105" "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $ad7606_driver_0 eq "" } {
     catch {common::send_msg_id "BD_TCL-106" "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: adc_to_fft_buffer_0, and set properties
  set block_name adc_to_fft_buffer
  set block_cell_name adc_to_fft_buffer_0
  if { [catch {set adc_to_fft_buffer_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_msg_id "BD_TCL-105" "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $adc_to_fft_buffer_0 eq "" } {
     catch {common::send_msg_id "BD_TCL-106" "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: auto_nrst_0, and set properties
  set block_name auto_nrst
  set block_cell_name auto_nrst_0
  if { [catch {set auto_nrst_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_msg_id "BD_TCL-105" "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $auto_nrst_0 eq "" } {
     catch {common::send_msg_id "BD_TCL-106" "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
    set_property -dict [ list \
   CONFIG.CNT_MAX {"0111110101111000001111111"} \
 ] $auto_nrst_0

  # Create instance: digital_agc_0, and set properties
  set block_name digital_agc
  set block_cell_name digital_agc_0
  if { [catch {set digital_agc_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_msg_id "BD_TCL-105" "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $digital_agc_0 eq "" } {
     catch {common::send_msg_id "BD_TCL-106" "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: fft_freq_meter_0, and set properties
  set block_name fft_freq_meter
  set block_cell_name fft_freq_meter_0
  if { [catch {set fft_freq_meter_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_msg_id "BD_TCL-105" "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $fft_freq_meter_0 eq "" } {
     catch {common::send_msg_id "BD_TCL-106" "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: fft_sys_controller_0, and set properties
  set block_name fft_sys_controller
  set block_cell_name fft_sys_controller_0
  if { [catch {set fft_sys_controller_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_msg_id "BD_TCL-105" "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $fft_sys_controller_0 eq "" } {
     catch {common::send_msg_id "BD_TCL-106" "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: freq_screen_driver_0, and set properties
  set block_name freq_screen_driver
  set block_cell_name freq_screen_driver_0
  if { [catch {set freq_screen_driver_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_msg_id "BD_TCL-105" "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $freq_screen_driver_0 eq "" } {
     catch {common::send_msg_id "BD_TCL-106" "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: seg_driver_0, and set properties
  set block_name seg_driver
  set block_cell_name seg_driver_0
  if { [catch {set seg_driver_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_msg_id "BD_TCL-105" "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $seg_driver_0 eq "" } {
     catch {common::send_msg_id "BD_TCL-106" "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: xfft_0, and set properties
  set xfft_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xfft:9.1 xfft_0 ]
  set_property -dict [ list \
   CONFIG.aresetn {true} \
   CONFIG.implementation_options {radix_4_burst_io} \
   CONFIG.number_of_stages_using_block_ram_for_data_and_phase_factors {0} \
   CONFIG.output_ordering {natural_order} \
   CONFIG.run_time_configurable_transform_length {false} \
   CONFIG.scaling_options {block_floating_point} \
   CONFIG.target_clock_frequency {50} \
   CONFIG.transform_length {4096} \
 ] $xfft_0

  # Create instance: xlconcat_0, and set properties
  set xlconcat_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 xlconcat_0 ]

  # Create instance: xlconstant_0, and set properties
  set xlconstant_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_0 ]
  set_property -dict [ list \
   CONFIG.CONST_VAL {0} \
   CONFIG.CONST_WIDTH {16} \
 ] $xlconstant_0

  # Create interface connections
  connect_bd_intf_net -intf_net adc_to_fft_buffer_0_m_axis [get_bd_intf_pins adc_to_fft_buffer_0/m_axis] [get_bd_intf_pins xfft_0/S_AXIS_DATA]

  # Create port connections
  connect_bd_net -net aclk_1 [get_bd_ports aclk] [get_bd_pins ad7606_driver_0/clk] [get_bd_pins adc_to_fft_buffer_0/aclk] [get_bd_pins auto_nrst_0/sys_clk] [get_bd_pins digital_agc_0/clk] [get_bd_pins fft_freq_meter_0/clk] [get_bd_pins fft_sys_controller_0/clk] [get_bd_pins freq_screen_driver_0/clk] [get_bd_pins seg_driver_0/clk] [get_bd_pins xfft_0/aclk]
  connect_bd_net -net ad7606_driver_0_ad_convst [get_bd_ports ad_convst_0] [get_bd_pins ad7606_driver_0/ad_convst]
  connect_bd_net -net ad7606_driver_0_ad_cs [get_bd_ports ad_cs_0] [get_bd_pins ad7606_driver_0/ad_cs]
  connect_bd_net -net ad7606_driver_0_ad_rd [get_bd_ports ad_rd_0] [get_bd_pins ad7606_driver_0/ad_rd]
  connect_bd_net -net ad7606_driver_0_ad_reset [get_bd_ports ad_reset_0] [get_bd_pins ad7606_driver_0/ad_reset]
  connect_bd_net -net ad7606_driver_0_sample_data_out [get_bd_pins ad7606_driver_0/sample_data_out] [get_bd_pins digital_agc_0/adc_data_in]
  connect_bd_net -net ad7606_driver_0_sample_valid [get_bd_pins ad7606_driver_0/sample_valid] [get_bd_pins adc_to_fft_buffer_0/adc_valid]
  connect_bd_net -net ad_busy_0_1 [get_bd_ports ad_busy_0] [get_bd_pins ad7606_driver_0/ad_busy]
  connect_bd_net -net ad_data_in_0_1 [get_bd_ports ad_data_in_0] [get_bd_pins ad7606_driver_0/ad_data_in]
  connect_bd_net -net agc_enable_0_1 [get_bd_ports agc_enable_0] [get_bd_pins digital_agc_0/agc_enable] [get_bd_pins freq_screen_driver_0/agc_enable]
  connect_bd_net -net aresetn_1 [get_bd_ports aresetn] [get_bd_pins auto_nrst_0/sys_rst_n] [get_bd_pins digital_agc_0/rst_n] [get_bd_pins freq_screen_driver_0/rst_n] [get_bd_pins seg_driver_0/rst_n]
  connect_bd_net -net auto_nrst_0_aresetn_out [get_bd_pins ad7606_driver_0/rst_n] [get_bd_pins adc_to_fft_buffer_0/aresetn] [get_bd_pins auto_nrst_0/aresetn_out] [get_bd_pins fft_freq_meter_0/rst_n] [get_bd_pins fft_sys_controller_0/rst_n] [get_bd_pins xfft_0/aresetn]
  connect_bd_net -net digital_agc_0_adc_data_out [get_bd_pins digital_agc_0/adc_data_out] [get_bd_pins xlconcat_0/In0]
  connect_bd_net -net digital_agc_0_current_gain [get_bd_pins digital_agc_0/current_gain] [get_bd_pins freq_screen_driver_0/current_gain]
  connect_bd_net -net fft_freq_meter_0_freq_out [get_bd_pins fft_freq_meter_0/freq_out] [get_bd_pins freq_screen_driver_0/data_in] [get_bd_pins seg_driver_0/data_in]
  connect_bd_net -net fft_freq_meter_0_measure_done [get_bd_ports measure_done] [get_bd_pins fft_freq_meter_0/measure_done]
  connect_bd_net -net fft_sys_controller_0_o_force_rst [get_bd_pins adc_to_fft_buffer_0/cfg_rst] [get_bd_pins fft_sys_controller_0/o_force_rst]
  connect_bd_net -net freq_screen_driver_0_uart_tx [get_bd_ports uart_tx_0] [get_bd_pins freq_screen_driver_0/uart_tx]
  connect_bd_net -net seg_driver_0_seg [get_bd_ports seg] [get_bd_pins seg_driver_0/seg]
  connect_bd_net -net seg_driver_0_sel [get_bd_ports sel] [get_bd_pins seg_driver_0/sel]
  connect_bd_net -net sw_points_0_1 [get_bd_ports sw_points_0] [get_bd_pins fft_freq_meter_0/sw_points] [get_bd_pins fft_sys_controller_0/sw_points]
  connect_bd_net -net xfft_0_m_axis_data_tdata [get_bd_pins fft_freq_meter_0/fft_data] [get_bd_pins xfft_0/m_axis_data_tdata]
  connect_bd_net -net xfft_0_m_axis_data_tvalid [get_bd_ports fft_valid] [get_bd_pins fft_freq_meter_0/fft_valid] [get_bd_pins xfft_0/m_axis_data_tvalid]
  connect_bd_net -net xlconcat_0_dout [get_bd_pins adc_to_fft_buffer_0/adc_data] [get_bd_pins xlconcat_0/dout]
  connect_bd_net -net xlconstant_0_dout [get_bd_pins xlconcat_0/In1] [get_bd_pins xlconstant_0/dout]

  # Create address segments


  # Restore current instance
  current_bd_instance $oldCurInst

  validate_bd_design
  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


