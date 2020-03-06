catch {TE::UTILS::te_msg TE_BD-0 INFO "This block design tcl-file was generate with Trenz Electronic GmbH Board Part:trenz.biz:te0720_1c:part0:1.0, FPGA: xc7z020clg484-1 at 2018-08-10T12:23:56."}
catch {TE::UTILS::te_msg TE_BD-1 INFO "This block design tcl-file was modified by TE-Scripts. Modifications are labelled with comment tag  # #TE_MOD# on the Block-Design tcl-file."}

################################################################
# This is a generated script based on design: zsys
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
set scripts_vivado_version 2018.2
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
# source zsys_script.tcl

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xc7z020clg484-1
   set_property BOARD_PART trenz.biz:te0720_1c:part0:1.0 [current_project]
}


# CHANGE DESIGN NAME HERE
variable design_name
set design_name zsys

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

set bCheckIPsPassed 1
##################################################################
# CHECK IPs
##################################################################
set bCheckIPs 1
if { $bCheckIPs == 1 } {
   set list_check_ips "\ 
trenz.biz:user:SC0720:1.0\
xilinx.com:ip:processing_system7:5.5\
xilinx.com:ip:vio:3.0\
xilinx.com:ip:xlconcat:2.1\
"

   set list_ips_missing ""
   common::send_msg_id "BD_TCL-006" "INFO" "Checking if the following IPs exist in the project's IP catalog: $list_check_ips ."

   foreach ip_vlnv $list_check_ips {
      set ip_obj [get_ipdefs -all $ip_vlnv]
      if { $ip_obj eq "" } {
         lappend list_ips_missing $ip_vlnv
      }
   }

   if { $list_ips_missing ne "" } {
      catch {common::send_msg_id "BD_TCL-115" "ERROR" "The following IPs are not found in the IP Catalog:\n  $list_ips_missing\n\nResolution: Please add the repository containing the IP(s) to the project." }
      set bCheckIPsPassed 0
   }

}

if { $bCheckIPsPassed != 1 } {
  common::send_msg_id "BD_TCL-1003" "WARNING" "Will not continue with creation of design due to the error(s) above."
  return 3
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
# #TE_MOD#   set DDR [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:ddrx_rtl:1.0 DDR ]
# #TE_MOD#   set FIXED_IO [ create_bd_intf_port -mode Master -vlnv xilinx.com:display_processing_system7:fixedio_rtl:1.0 FIXED_IO ]

  # Create ports
  set PL_pin_K16 [ create_bd_port -dir I PL_pin_K16 ]
  set PL_pin_K19 [ create_bd_port -dir I PL_pin_K19 ]
  set PL_pin_K20 [ create_bd_port -dir O PL_pin_K20 ]
  set PL_pin_L16 [ create_bd_port -dir O PL_pin_L16 ]
  set PL_pin_M15 [ create_bd_port -dir I PL_pin_M15 ]
  set PL_pin_N15 [ create_bd_port -dir I PL_pin_N15 ]
  set PL_pin_N22 [ create_bd_port -dir O PL_pin_N22 ]
  set PL_pin_P16 [ create_bd_port -dir I PL_pin_P16 ]
  set PL_pin_P22 [ create_bd_port -dir I PL_pin_P22 ]

  # Create instance: SC0720_0, and set properties
  set SC0720_0 [ create_bd_cell -type ip -vlnv trenz.biz:user:SC0720:1.0 SC0720_0 ]

  # Create instance: processing_system7_0, and set properties
  set processing_system7_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7:5.5 processing_system7_0 ]
# #TE_MOD#_Add next line#
  apply_bd_automation -rule xilinx.com:bd_rule:processing_system7 -config {make_external "FIXED_IO, DDR" apply_board_preset "1"}  [get_bd_cells processing_system7_0]
# #TE_MOD#_Add next line#
  set tcl_ext [];if { [catch {set tcl_ext [glob -join -dir ${TE::BOARDDEF_PATH}/carrier_extension/ *_preset.tcl]}] } {};foreach carrier_ext $tcl_ext { source  $carrier_ext};
# #TE_MOD#   set_property -dict [ list \
# #TE_MOD#  ] $processing_system7_0

# #TE_MOD#    CONFIG.PCW_WDT_WDT_IO {EMIO} \
# #TE_MOD#    CONFIG.PCW_WDT_PERIPHERAL_FREQMHZ {133.333333} \
# #TE_MOD#    CONFIG.PCW_WDT_PERIPHERAL_ENABLE {1} \
# #TE_MOD#    CONFIG.PCW_USB_RESET_ENABLE {0} \
# #TE_MOD#    CONFIG.PCW_USB1_RESET_ENABLE {0} \
# #TE_MOD#    CONFIG.PCW_USB0_USB0_IO {MIO 28 .. 39} \
# #TE_MOD#    CONFIG.PCW_USB0_RESET_ENABLE {0} \
# #TE_MOD#    CONFIG.PCW_USB0_PERIPHERAL_FREQMHZ {60} \
# #TE_MOD#    CONFIG.PCW_USB0_PERIPHERAL_ENABLE {1} \
# #TE_MOD#    CONFIG.PCW_UIPARAM_DDR_T_RP {7} \
# #TE_MOD#    CONFIG.PCW_UIPARAM_DDR_T_RCD {7} \
# #TE_MOD#    CONFIG.PCW_UIPARAM_DDR_T_RC {48.91} \
# #TE_MOD#    CONFIG.PCW_UIPARAM_DDR_T_RAS_MIN {35.0} \
# #TE_MOD#    CONFIG.PCW_UIPARAM_DDR_T_FAW {40.0} \
# #TE_MOD#    CONFIG.PCW_UIPARAM_DDR_SPEED_BIN {DDR3_1066F} \
# #TE_MOD#    CONFIG.PCW_UIPARAM_DDR_ROW_ADDR_COUNT {15} \
# #TE_MOD#    CONFIG.PCW_UIPARAM_DDR_PARTNO {MT41J256M16 RE-125} \
# #TE_MOD#    CONFIG.PCW_UIPARAM_DDR_MEMORY_TYPE {DDR 3} \
# #TE_MOD#    CONFIG.PCW_UIPARAM_DDR_ECC {Disabled} \
# #TE_MOD#    CONFIG.PCW_UIPARAM_DDR_DRAM_WIDTH {16 Bits} \
# #TE_MOD#    CONFIG.PCW_UIPARAM_DDR_DEVICE_CAPACITY {4096 MBits} \
# #TE_MOD#    CONFIG.PCW_UIPARAM_DDR_CWL {6} \
# #TE_MOD#    CONFIG.PCW_UIPARAM_DDR_COL_ADDR_COUNT {10} \
# #TE_MOD#    CONFIG.PCW_UIPARAM_DDR_CL {7} \
# #TE_MOD#    CONFIG.PCW_UIPARAM_DDR_BUS_WIDTH {16 Bit} \
# #TE_MOD#    CONFIG.PCW_UIPARAM_DDR_BL {8} \
# #TE_MOD#    CONFIG.PCW_UIPARAM_DDR_BANK_ADDR_COUNT {3} \
# #TE_MOD#    CONFIG.PCW_UIPARAM_ACT_DDR_FREQ_MHZ {533.333374} \
# #TE_MOD#    CONFIG.PCW_UART_PERIPHERAL_VALID {1} \
# #TE_MOD#    CONFIG.PCW_UART_PERIPHERAL_FREQMHZ {100} \
# #TE_MOD#    CONFIG.PCW_UART_PERIPHERAL_DIVISOR0 {10} \
# #TE_MOD#    CONFIG.PCW_UART1_UART1_IO {MIO 12 .. 13} \
# #TE_MOD#    CONFIG.PCW_UART1_PERIPHERAL_ENABLE {1} \
# #TE_MOD#    CONFIG.PCW_UART1_GRP_FULL_ENABLE {0} \
# #TE_MOD#    CONFIG.PCW_UART0_UART0_IO {MIO 14 .. 15} \
# #TE_MOD#    CONFIG.PCW_UART0_PERIPHERAL_ENABLE {1} \
# #TE_MOD#    CONFIG.PCW_UART0_GRP_FULL_ENABLE {0} \
# #TE_MOD#    CONFIG.PCW_TTC_PERIPHERAL_FREQMHZ {50} \
# #TE_MOD#    CONFIG.PCW_TTC1_TTC1_IO {EMIO} \
# #TE_MOD#    CONFIG.PCW_TTC1_PERIPHERAL_ENABLE {1} \
# #TE_MOD#    CONFIG.PCW_TTC1_CLK2_PERIPHERAL_FREQMHZ {133.333333} \
# #TE_MOD#    CONFIG.PCW_TTC1_CLK1_PERIPHERAL_FREQMHZ {133.333333} \
# #TE_MOD#    CONFIG.PCW_TTC1_CLK0_PERIPHERAL_FREQMHZ {133.333333} \
# #TE_MOD#    CONFIG.PCW_TTC0_TTC0_IO {EMIO} \
# #TE_MOD#    CONFIG.PCW_TTC0_PERIPHERAL_ENABLE {1} \
# #TE_MOD#    CONFIG.PCW_TTC0_CLK2_PERIPHERAL_FREQMHZ {133.333333} \
# #TE_MOD#    CONFIG.PCW_TTC0_CLK1_PERIPHERAL_FREQMHZ {133.333333} \
# #TE_MOD#    CONFIG.PCW_TTC0_CLK0_PERIPHERAL_FREQMHZ {133.333333} \
# #TE_MOD#    CONFIG.PCW_TPIU_PERIPHERAL_DIVISOR0 {1} \
# #TE_MOD#    CONFIG.PCW_SPI_PERIPHERAL_DIVISOR0 {1} \
# #TE_MOD#    CONFIG.PCW_SMC_PERIPHERAL_DIVISOR0 {1} \
# #TE_MOD#    CONFIG.PCW_SINGLE_QSPI_DATA_MODE {x4} \
# #TE_MOD#    CONFIG.PCW_SDIO_PERIPHERAL_VALID {1} \
# #TE_MOD#    CONFIG.PCW_SDIO_PERIPHERAL_FREQMHZ {100} \
# #TE_MOD#    CONFIG.PCW_SDIO_PERIPHERAL_DIVISOR0 {10} \
# #TE_MOD#    CONFIG.PCW_SD1_SD1_IO {MIO 46 .. 51} \
# #TE_MOD#    CONFIG.PCW_SD1_PERIPHERAL_ENABLE {1} \
# #TE_MOD#    CONFIG.PCW_SD1_GRP_WP_ENABLE {0} \
# #TE_MOD#    CONFIG.PCW_SD1_GRP_POW_ENABLE {0} \
# #TE_MOD#    CONFIG.PCW_SD1_GRP_CD_ENABLE {0} \
# #TE_MOD#    CONFIG.PCW_SD0_SD0_IO {MIO 40 .. 45} \
# #TE_MOD#    CONFIG.PCW_SD0_PERIPHERAL_ENABLE {1} \
# #TE_MOD#    CONFIG.PCW_SD0_GRP_WP_ENABLE {0} \
# #TE_MOD#    CONFIG.PCW_SD0_GRP_POW_ENABLE {0} \
# #TE_MOD#    CONFIG.PCW_SD0_GRP_CD_ENABLE {0} \
# #TE_MOD#    CONFIG.PCW_QSPI_QSPI_IO {MIO 1 .. 6} \
# #TE_MOD#    CONFIG.PCW_QSPI_PERIPHERAL_FREQMHZ {200} \
# #TE_MOD#    CONFIG.PCW_QSPI_PERIPHERAL_ENABLE {1} \
# #TE_MOD#    CONFIG.PCW_QSPI_PERIPHERAL_DIVISOR0 {5} \
# #TE_MOD#    CONFIG.PCW_QSPI_GRP_SS1_ENABLE {0} \
# #TE_MOD#    CONFIG.PCW_QSPI_GRP_SINGLE_SS_IO {MIO 1 .. 6} \
# #TE_MOD#    CONFIG.PCW_QSPI_GRP_SINGLE_SS_ENABLE {1} \
# #TE_MOD#    CONFIG.PCW_QSPI_GRP_IO1_ENABLE {0} \
# #TE_MOD#    CONFIG.PCW_QSPI_GRP_FBCLK_IO {MIO 8} \
# #TE_MOD#    CONFIG.PCW_QSPI_GRP_FBCLK_ENABLE {1} \
# #TE_MOD#    CONFIG.PCW_PRESET_BANK1_VOLTAGE {LVCMOS 1.8V} \
# #TE_MOD#    CONFIG.PCW_PRESET_BANK0_VOLTAGE {LVCMOS 3.3V} \
# #TE_MOD#    CONFIG.PCW_PCAP_PERIPHERAL_DIVISOR0 {5} \
# #TE_MOD#    CONFIG.PCW_NOR_PERIPHERAL_ENABLE {0} \
# #TE_MOD#    CONFIG.PCW_NOR_GRP_SRAM_INT_ENABLE {0} \
# #TE_MOD#    CONFIG.PCW_NOR_GRP_SRAM_CS1_ENABLE {0} \
# #TE_MOD#    CONFIG.PCW_NOR_GRP_SRAM_CS0_ENABLE {0} \
# #TE_MOD#    CONFIG.PCW_NOR_GRP_CS1_ENABLE {0} \
# #TE_MOD#    CONFIG.PCW_NOR_GRP_CS0_ENABLE {0} \
# #TE_MOD#    CONFIG.PCW_NOR_GRP_A25_ENABLE {0} \
# #TE_MOD#    CONFIG.PCW_NAND_PERIPHERAL_ENABLE {0} \
# #TE_MOD#    CONFIG.PCW_NAND_GRP_D8_ENABLE {0} \
# #TE_MOD#    CONFIG.PCW_MIO_TREE_SIGNALS {gpio[0]#qspi0_ss_b#qspi0_io[0]#qspi0_io[1]#qspi0_io[2]#qspi0_io[3]/HOLD_B#qspi0_sclk#gpio[7]#qspi_fbclk#gpio[9]#scl#sda#tx#rx#rx#tx#tx_clk#txd[0]#txd[1]#txd[2]#txd[3]#tx_ctl#rx_clk#rxd[0]#rxd[1]#rxd[2]#rxd[3]#rx_ctl#data[4]#dir#stp#nxt#data[0]#data[1]#data[2]#data[3]#clk#data[5]#data[6]#data[7]#clk#cmd#data[0]#data[1]#data[2]#data[3]#data[0]#cmd#clk#data[1]#data[2]#data[3]#mdc#mdio} \
# #TE_MOD#    CONFIG.PCW_MIO_TREE_PERIPHERALS {GPIO#Quad SPI Flash#Quad SPI Flash#Quad SPI Flash#Quad SPI Flash#Quad SPI Flash#Quad SPI Flash#GPIO#Quad SPI Flash#GPIO#I2C 0#I2C 0#UART 1#UART 1#UART 0#UART 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#SD 0#SD 0#SD 0#SD 0#SD 0#SD 0#SD 1#SD 1#SD 1#SD 1#SD 1#SD 1#Enet 0#Enet 0} \
# #TE_MOD#    CONFIG.PCW_MIO_9_SLEW {slow} \
# #TE_MOD#    CONFIG.PCW_MIO_9_PULLUP {enabled} \
# #TE_MOD#    CONFIG.PCW_MIO_9_IOTYPE {LVCMOS 3.3V} \
# #TE_MOD#    CONFIG.PCW_MIO_9_DIRECTION {inout} \
# #TE_MOD#    CONFIG.PCW_MIO_8_SLEW {slow} \
# #TE_MOD#    CONFIG.PCW_MIO_8_PULLUP {disabled} \
# #TE_MOD#    CONFIG.PCW_MIO_8_IOTYPE {LVCMOS 3.3V} \
# #TE_MOD#    CONFIG.PCW_MIO_8_DIRECTION {out} \
# #TE_MOD#    CONFIG.PCW_MIO_7_SLEW {slow} \
# #TE_MOD#    CONFIG.PCW_MIO_7_PULLUP {disabled} \
# #TE_MOD#    CONFIG.PCW_MIO_7_IOTYPE {LVCMOS 3.3V} \
# #TE_MOD#    CONFIG.PCW_MIO_7_DIRECTION {out} \
# #TE_MOD#    CONFIG.PCW_MIO_6_SLEW {slow} \
# #TE_MOD#    CONFIG.PCW_MIO_6_PULLUP {disabled} \
# #TE_MOD#    CONFIG.PCW_MIO_6_IOTYPE {LVCMOS 3.3V} \
# #TE_MOD#    CONFIG.PCW_MIO_6_DIRECTION {out} \
# #TE_MOD#    CONFIG.PCW_MIO_5_SLEW {slow} \
# #TE_MOD#    CONFIG.PCW_MIO_5_PULLUP {disabled} \
# #TE_MOD#    CONFIG.PCW_MIO_5_IOTYPE {LVCMOS 3.3V} \
# #TE_MOD#    CONFIG.PCW_MIO_5_DIRECTION {inout} \
# #TE_MOD#    CONFIG.PCW_MIO_53_SLEW {slow} \
# #TE_MOD#    CONFIG.PCW_MIO_53_PULLUP {enabled} \
# #TE_MOD#    CONFIG.PCW_MIO_53_IOTYPE {LVCMOS 1.8V} \
# #TE_MOD#    CONFIG.PCW_MIO_53_DIRECTION {inout} \
# #TE_MOD#    CONFIG.PCW_MIO_52_SLEW {slow} \
# #TE_MOD#    CONFIG.PCW_MIO_52_PULLUP {enabled} \
# #TE_MOD#    CONFIG.PCW_MIO_52_IOTYPE {LVCMOS 1.8V} \
# #TE_MOD#    CONFIG.PCW_MIO_52_DIRECTION {out} \
# #TE_MOD#    CONFIG.PCW_MIO_51_SLEW {slow} \
# #TE_MOD#    CONFIG.PCW_MIO_51_PULLUP {enabled} \
# #TE_MOD#    CONFIG.PCW_MIO_51_IOTYPE {LVCMOS 1.8V} \
# #TE_MOD#    CONFIG.PCW_MIO_51_DIRECTION {inout} \
# #TE_MOD#    CONFIG.PCW_MIO_50_SLEW {slow} \
# #TE_MOD#    CONFIG.PCW_MIO_50_PULLUP {enabled} \
# #TE_MOD#    CONFIG.PCW_MIO_50_IOTYPE {LVCMOS 1.8V} \
# #TE_MOD#    CONFIG.PCW_MIO_50_DIRECTION {inout} \
# #TE_MOD#    CONFIG.PCW_MIO_4_SLEW {slow} \
# #TE_MOD#    CONFIG.PCW_MIO_4_PULLUP {disabled} \
# #TE_MOD#    CONFIG.PCW_MIO_4_IOTYPE {LVCMOS 3.3V} \
# #TE_MOD#    CONFIG.PCW_MIO_4_DIRECTION {inout} \
# #TE_MOD#    CONFIG.PCW_MIO_49_SLEW {slow} \
# #TE_MOD#    CONFIG.PCW_MIO_49_PULLUP {enabled} \
# #TE_MOD#    CONFIG.PCW_MIO_49_IOTYPE {LVCMOS 1.8V} \
# #TE_MOD#    CONFIG.PCW_MIO_49_DIRECTION {inout} \
# #TE_MOD#    CONFIG.PCW_MIO_48_SLEW {slow} \
# #TE_MOD#    CONFIG.PCW_MIO_48_PULLUP {enabled} \
# #TE_MOD#    CONFIG.PCW_MIO_48_IOTYPE {LVCMOS 1.8V} \
# #TE_MOD#    CONFIG.PCW_MIO_48_DIRECTION {inout} \
# #TE_MOD#    CONFIG.PCW_MIO_47_SLEW {slow} \
# #TE_MOD#    CONFIG.PCW_MIO_47_PULLUP {enabled} \
# #TE_MOD#    CONFIG.PCW_MIO_47_IOTYPE {LVCMOS 1.8V} \
# #TE_MOD#    CONFIG.PCW_MIO_47_DIRECTION {inout} \
# #TE_MOD#    CONFIG.PCW_MIO_46_SLEW {slow} \
# #TE_MOD#    CONFIG.PCW_MIO_46_PULLUP {enabled} \
# #TE_MOD#    CONFIG.PCW_MIO_46_IOTYPE {LVCMOS 1.8V} \
# #TE_MOD#    CONFIG.PCW_MIO_46_DIRECTION {inout} \
# #TE_MOD#    CONFIG.PCW_MIO_45_SLEW {slow} \
# #TE_MOD#    CONFIG.PCW_MIO_45_PULLUP {disabled} \
# #TE_MOD#    CONFIG.PCW_MIO_45_IOTYPE {LVCMOS 1.8V} \
# #TE_MOD#    CONFIG.PCW_MIO_45_DIRECTION {inout} \
# #TE_MOD#    CONFIG.PCW_MIO_44_SLEW {slow} \
# #TE_MOD#    CONFIG.PCW_MIO_44_PULLUP {disabled} \
# #TE_MOD#    CONFIG.PCW_MIO_44_IOTYPE {LVCMOS 1.8V} \
# #TE_MOD#    CONFIG.PCW_MIO_44_DIRECTION {inout} \
# #TE_MOD#    CONFIG.PCW_MIO_43_SLEW {slow} \
# #TE_MOD#    CONFIG.PCW_MIO_43_PULLUP {disabled} \
# #TE_MOD#    CONFIG.PCW_MIO_43_IOTYPE {LVCMOS 1.8V} \
# #TE_MOD#    CONFIG.PCW_MIO_43_DIRECTION {inout} \
# #TE_MOD#    CONFIG.PCW_MIO_42_SLEW {slow} \
# #TE_MOD#    CONFIG.PCW_MIO_42_PULLUP {disabled} \
# #TE_MOD#    CONFIG.PCW_MIO_42_IOTYPE {LVCMOS 1.8V} \
# #TE_MOD#    CONFIG.PCW_MIO_42_DIRECTION {inout} \
# #TE_MOD#    CONFIG.PCW_MIO_41_SLEW {slow} \
# #TE_MOD#    CONFIG.PCW_MIO_41_PULLUP {disabled} \
# #TE_MOD#    CONFIG.PCW_MIO_41_IOTYPE {LVCMOS 1.8V} \
# #TE_MOD#    CONFIG.PCW_MIO_41_DIRECTION {inout} \
# #TE_MOD#    CONFIG.PCW_MIO_40_SLEW {slow} \
# #TE_MOD#    CONFIG.PCW_MIO_40_PULLUP {disabled} \
# #TE_MOD#    CONFIG.PCW_MIO_40_IOTYPE {LVCMOS 1.8V} \
# #TE_MOD#    CONFIG.PCW_MIO_40_DIRECTION {inout} \
# #TE_MOD#    CONFIG.PCW_MIO_3_SLEW {slow} \
# #TE_MOD#    CONFIG.PCW_MIO_3_PULLUP {disabled} \
# #TE_MOD#    CONFIG.PCW_MIO_3_IOTYPE {LVCMOS 3.3V} \
# #TE_MOD#    CONFIG.PCW_MIO_3_DIRECTION {inout} \
# #TE_MOD#    CONFIG.PCW_MIO_39_SLEW {slow} \
# #TE_MOD#    CONFIG.PCW_MIO_39_PULLUP {enabled} \
# #TE_MOD#    CONFIG.PCW_MIO_39_IOTYPE {LVCMOS 1.8V} \
# #TE_MOD#    CONFIG.PCW_MIO_39_DIRECTION {inout} \
# #TE_MOD#    CONFIG.PCW_MIO_38_SLEW {slow} \
# #TE_MOD#    CONFIG.PCW_MIO_38_PULLUP {enabled} \
# #TE_MOD#    CONFIG.PCW_MIO_38_IOTYPE {LVCMOS 1.8V} \
# #TE_MOD#    CONFIG.PCW_MIO_38_DIRECTION {inout} \
# #TE_MOD#    CONFIG.PCW_MIO_37_SLEW {slow} \
# #TE_MOD#    CONFIG.PCW_MIO_37_PULLUP {enabled} \
# #TE_MOD#    CONFIG.PCW_MIO_37_IOTYPE {LVCMOS 1.8V} \
# #TE_MOD#    CONFIG.PCW_MIO_37_DIRECTION {inout} \
# #TE_MOD#    CONFIG.PCW_MIO_36_SLEW {slow} \
# #TE_MOD#    CONFIG.PCW_MIO_36_PULLUP {enabled} \
# #TE_MOD#    CONFIG.PCW_MIO_36_IOTYPE {LVCMOS 1.8V} \
# #TE_MOD#    CONFIG.PCW_MIO_36_DIRECTION {in} \
# #TE_MOD#    CONFIG.PCW_MIO_35_SLEW {slow} \
# #TE_MOD#    CONFIG.PCW_MIO_35_PULLUP {enabled} \
# #TE_MOD#    CONFIG.PCW_MIO_35_IOTYPE {LVCMOS 1.8V} \
# #TE_MOD#    CONFIG.PCW_MIO_35_DIRECTION {inout} \
# #TE_MOD#    CONFIG.PCW_MIO_34_SLEW {slow} \
# #TE_MOD#    CONFIG.PCW_MIO_34_PULLUP {enabled} \
# #TE_MOD#    CONFIG.PCW_MIO_34_IOTYPE {LVCMOS 1.8V} \
# #TE_MOD#    CONFIG.PCW_MIO_34_DIRECTION {inout} \
# #TE_MOD#    CONFIG.PCW_MIO_33_SLEW {slow} \
# #TE_MOD#    CONFIG.PCW_MIO_33_PULLUP {enabled} \
# #TE_MOD#    CONFIG.PCW_MIO_33_IOTYPE {LVCMOS 1.8V} \
# #TE_MOD#    CONFIG.PCW_MIO_33_DIRECTION {inout} \
# #TE_MOD#    CONFIG.PCW_MIO_32_SLEW {slow} \
# #TE_MOD#    CONFIG.PCW_MIO_32_PULLUP {enabled} \
# #TE_MOD#    CONFIG.PCW_MIO_32_IOTYPE {LVCMOS 1.8V} \
# #TE_MOD#    CONFIG.PCW_MIO_32_DIRECTION {inout} \
# #TE_MOD#    CONFIG.PCW_MIO_31_SLEW {slow} \
# #TE_MOD#    CONFIG.PCW_MIO_31_PULLUP {enabled} \
# #TE_MOD#    CONFIG.PCW_MIO_31_IOTYPE {LVCMOS 1.8V} \
# #TE_MOD#    CONFIG.PCW_MIO_31_DIRECTION {in} \
# #TE_MOD#    CONFIG.PCW_MIO_30_SLEW {slow} \
# #TE_MOD#    CONFIG.PCW_MIO_30_PULLUP {enabled} \
# #TE_MOD#    CONFIG.PCW_MIO_30_IOTYPE {LVCMOS 1.8V} \
# #TE_MOD#    CONFIG.PCW_MIO_30_DIRECTION {out} \
# #TE_MOD#    CONFIG.PCW_MIO_2_SLEW {slow} \
# #TE_MOD#    CONFIG.PCW_MIO_2_PULLUP {disabled} \
# #TE_MOD#    CONFIG.PCW_MIO_2_IOTYPE {LVCMOS 3.3V} \
# #TE_MOD#    CONFIG.PCW_MIO_2_DIRECTION {inout} \
# #TE_MOD#    CONFIG.PCW_MIO_29_SLEW {slow} \
# #TE_MOD#    CONFIG.PCW_MIO_29_PULLUP {enabled} \
# #TE_MOD#    CONFIG.PCW_MIO_29_IOTYPE {LVCMOS 1.8V} \
# #TE_MOD#    CONFIG.PCW_MIO_29_DIRECTION {in} \
# #TE_MOD#    CONFIG.PCW_MIO_28_SLEW {slow} \
# #TE_MOD#    CONFIG.PCW_MIO_28_PULLUP {enabled} \
# #TE_MOD#    CONFIG.PCW_MIO_28_IOTYPE {LVCMOS 1.8V} \
# #TE_MOD#    CONFIG.PCW_MIO_28_DIRECTION {inout} \
# #TE_MOD#    CONFIG.PCW_MIO_27_SLEW {slow} \
# #TE_MOD#    CONFIG.PCW_MIO_27_PULLUP {enabled} \
# #TE_MOD#    CONFIG.PCW_MIO_27_IOTYPE {LVCMOS 1.8V} \
# #TE_MOD#    CONFIG.PCW_MIO_27_DIRECTION {in} \
# #TE_MOD#    CONFIG.PCW_MIO_26_SLEW {slow} \
# #TE_MOD#    CONFIG.PCW_MIO_26_PULLUP {enabled} \
# #TE_MOD#    CONFIG.PCW_MIO_26_IOTYPE {LVCMOS 1.8V} \
# #TE_MOD#    CONFIG.PCW_MIO_26_DIRECTION {in} \
# #TE_MOD#    CONFIG.PCW_MIO_25_SLEW {slow} \
# #TE_MOD#    CONFIG.PCW_MIO_25_PULLUP {enabled} \
# #TE_MOD#    CONFIG.PCW_MIO_25_IOTYPE {LVCMOS 1.8V} \
# #TE_MOD#    CONFIG.PCW_MIO_25_DIRECTION {in} \
# #TE_MOD#    CONFIG.PCW_MIO_24_SLEW {slow} \
# #TE_MOD#    CONFIG.PCW_MIO_24_PULLUP {enabled} \
# #TE_MOD#    CONFIG.PCW_MIO_24_IOTYPE {LVCMOS 1.8V} \
# #TE_MOD#    CONFIG.PCW_MIO_24_DIRECTION {in} \
# #TE_MOD#    CONFIG.PCW_MIO_23_SLEW {slow} \
# #TE_MOD#    CONFIG.PCW_MIO_23_PULLUP {enabled} \
# #TE_MOD#    CONFIG.PCW_MIO_23_IOTYPE {LVCMOS 1.8V} \
# #TE_MOD#    CONFIG.PCW_MIO_23_DIRECTION {in} \
# #TE_MOD#    CONFIG.PCW_MIO_22_SLEW {slow} \
# #TE_MOD#    CONFIG.PCW_MIO_22_PULLUP {enabled} \
# #TE_MOD#    CONFIG.PCW_MIO_22_IOTYPE {LVCMOS 1.8V} \
# #TE_MOD#    CONFIG.PCW_MIO_22_DIRECTION {in} \
# #TE_MOD#    CONFIG.PCW_MIO_21_SLEW {slow} \
# #TE_MOD#    CONFIG.PCW_MIO_21_PULLUP {enabled} \
# #TE_MOD#    CONFIG.PCW_MIO_21_IOTYPE {LVCMOS 1.8V} \
# #TE_MOD#    CONFIG.PCW_MIO_21_DIRECTION {out} \
# #TE_MOD#    CONFIG.PCW_MIO_20_SLEW {slow} \
# #TE_MOD#    CONFIG.PCW_MIO_20_PULLUP {enabled} \
# #TE_MOD#    CONFIG.PCW_MIO_20_IOTYPE {LVCMOS 1.8V} \
# #TE_MOD#    CONFIG.PCW_MIO_20_DIRECTION {out} \
# #TE_MOD#    CONFIG.PCW_MIO_1_SLEW {slow} \
# #TE_MOD#    CONFIG.PCW_MIO_1_PULLUP {enabled} \
# #TE_MOD#    CONFIG.PCW_MIO_1_IOTYPE {LVCMOS 3.3V} \
# #TE_MOD#    CONFIG.PCW_MIO_1_DIRECTION {out} \
# #TE_MOD#    CONFIG.PCW_MIO_19_SLEW {slow} \
# #TE_MOD#    CONFIG.PCW_MIO_19_PULLUP {enabled} \
# #TE_MOD#    CONFIG.PCW_MIO_19_IOTYPE {LVCMOS 1.8V} \
# #TE_MOD#    CONFIG.PCW_MIO_19_DIRECTION {out} \
# #TE_MOD#    CONFIG.PCW_MIO_18_SLEW {slow} \
# #TE_MOD#    CONFIG.PCW_MIO_18_PULLUP {enabled} \
# #TE_MOD#    CONFIG.PCW_MIO_18_IOTYPE {LVCMOS 1.8V} \
# #TE_MOD#    CONFIG.PCW_MIO_18_DIRECTION {out} \
# #TE_MOD#    CONFIG.PCW_MIO_17_SLEW {slow} \
# #TE_MOD#    CONFIG.PCW_MIO_17_PULLUP {enabled} \
# #TE_MOD#    CONFIG.PCW_MIO_17_IOTYPE {LVCMOS 1.8V} \
# #TE_MOD#    CONFIG.PCW_MIO_17_DIRECTION {out} \
# #TE_MOD#    CONFIG.PCW_MIO_16_SLEW {slow} \
# #TE_MOD#    CONFIG.PCW_MIO_16_PULLUP {enabled} \
# #TE_MOD#    CONFIG.PCW_MIO_16_IOTYPE {LVCMOS 1.8V} \
# #TE_MOD#    CONFIG.PCW_MIO_16_DIRECTION {out} \
# #TE_MOD#    CONFIG.PCW_MIO_15_SLEW {slow} \
# #TE_MOD#    CONFIG.PCW_MIO_15_PULLUP {enabled} \
# #TE_MOD#    CONFIG.PCW_MIO_15_IOTYPE {LVCMOS 3.3V} \
# #TE_MOD#    CONFIG.PCW_MIO_15_DIRECTION {out} \
# #TE_MOD#    CONFIG.PCW_MIO_14_SLEW {slow} \
# #TE_MOD#    CONFIG.PCW_MIO_14_PULLUP {enabled} \
# #TE_MOD#    CONFIG.PCW_MIO_14_IOTYPE {LVCMOS 3.3V} \
# #TE_MOD#    CONFIG.PCW_MIO_14_DIRECTION {in} \
# #TE_MOD#    CONFIG.PCW_MIO_13_SLEW {slow} \
# #TE_MOD#    CONFIG.PCW_MIO_13_PULLUP {enabled} \
# #TE_MOD#    CONFIG.PCW_MIO_13_IOTYPE {LVCMOS 3.3V} \
# #TE_MOD#    CONFIG.PCW_MIO_13_DIRECTION {in} \
# #TE_MOD#    CONFIG.PCW_MIO_12_SLEW {slow} \
# #TE_MOD#    CONFIG.PCW_MIO_12_PULLUP {enabled} \
# #TE_MOD#    CONFIG.PCW_MIO_12_IOTYPE {LVCMOS 3.3V} \
# #TE_MOD#    CONFIG.PCW_MIO_12_DIRECTION {out} \
# #TE_MOD#    CONFIG.PCW_MIO_11_SLEW {slow} \
# #TE_MOD#    CONFIG.PCW_MIO_11_PULLUP {enabled} \
# #TE_MOD#    CONFIG.PCW_MIO_11_IOTYPE {LVCMOS 3.3V} \
# #TE_MOD#    CONFIG.PCW_MIO_11_DIRECTION {inout} \
# #TE_MOD#    CONFIG.PCW_MIO_10_SLEW {slow} \
# #TE_MOD#    CONFIG.PCW_MIO_10_PULLUP {enabled} \
# #TE_MOD#    CONFIG.PCW_MIO_10_IOTYPE {LVCMOS 3.3V} \
# #TE_MOD#    CONFIG.PCW_MIO_10_DIRECTION {inout} \
# #TE_MOD#    CONFIG.PCW_MIO_0_SLEW {slow} \
# #TE_MOD#    CONFIG.PCW_MIO_0_PULLUP {enabled} \
# #TE_MOD#    CONFIG.PCW_MIO_0_IOTYPE {LVCMOS 3.3V} \
# #TE_MOD#    CONFIG.PCW_MIO_0_DIRECTION {inout} \
# #TE_MOD#    CONFIG.PCW_IO_IO_PLL_FREQMHZ {1000.000} \
# #TE_MOD#    CONFIG.PCW_IOPLL_CTRL_FBDIV {30} \
# #TE_MOD#    CONFIG.PCW_I2C_RESET_ENABLE {0} \
# #TE_MOD#    CONFIG.PCW_I2C_PERIPHERAL_FREQMHZ {111.111115} \
# #TE_MOD#    CONFIG.PCW_I2C1_RESET_ENABLE {0} \
# #TE_MOD#    CONFIG.PCW_I2C1_PERIPHERAL_ENABLE {1} \
# #TE_MOD#    CONFIG.PCW_I2C1_I2C1_IO {EMIO} \
# #TE_MOD#    CONFIG.PCW_I2C1_GRP_INT_IO {EMIO} \
# #TE_MOD#    CONFIG.PCW_I2C1_GRP_INT_ENABLE {1} \
# #TE_MOD#    CONFIG.PCW_I2C0_RESET_ENABLE {0} \
# #TE_MOD#    CONFIG.PCW_I2C0_PERIPHERAL_ENABLE {1} \
# #TE_MOD#    CONFIG.PCW_I2C0_I2C0_IO {MIO 10 .. 11} \
# #TE_MOD#    CONFIG.PCW_I2C0_GRP_INT_ENABLE {0} \
# #TE_MOD#    CONFIG.PCW_GPIO_MIO_GPIO_IO {MIO} \
# #TE_MOD#    CONFIG.PCW_GPIO_MIO_GPIO_ENABLE {1} \
# #TE_MOD#    CONFIG.PCW_FPGA_FCLK3_ENABLE {0} \
# #TE_MOD#    CONFIG.PCW_FPGA_FCLK2_ENABLE {0} \
# #TE_MOD#    CONFIG.PCW_FPGA_FCLK1_ENABLE {0} \
# #TE_MOD#    CONFIG.PCW_FPGA_FCLK0_ENABLE {1} \
# #TE_MOD#    CONFIG.PCW_FPGA0_PERIPHERAL_FREQMHZ {100} \
# #TE_MOD#    CONFIG.PCW_FCLK3_PERIPHERAL_DIVISOR1 {1} \
# #TE_MOD#    CONFIG.PCW_FCLK3_PERIPHERAL_DIVISOR0 {1} \
# #TE_MOD#    CONFIG.PCW_FCLK2_PERIPHERAL_DIVISOR1 {1} \
# #TE_MOD#    CONFIG.PCW_FCLK2_PERIPHERAL_DIVISOR0 {1} \
# #TE_MOD#    CONFIG.PCW_FCLK1_PERIPHERAL_DIVISOR1 {1} \
# #TE_MOD#    CONFIG.PCW_FCLK1_PERIPHERAL_DIVISOR0 {1} \
# #TE_MOD#    CONFIG.PCW_FCLK0_PERIPHERAL_DIVISOR1 {2} \
# #TE_MOD#    CONFIG.PCW_FCLK0_PERIPHERAL_DIVISOR0 {5} \
# #TE_MOD#    CONFIG.PCW_EN_WDT {1} \
# #TE_MOD#    CONFIG.PCW_EN_USB0 {1} \
# #TE_MOD#    CONFIG.PCW_EN_UART1 {1} \
# #TE_MOD#    CONFIG.PCW_EN_UART0 {1} \
# #TE_MOD#    CONFIG.PCW_EN_TTC1 {1} \
# #TE_MOD#    CONFIG.PCW_EN_TTC0 {1} \
# #TE_MOD#    CONFIG.PCW_EN_SDIO1 {1} \
# #TE_MOD#    CONFIG.PCW_EN_SDIO0 {1} \
# #TE_MOD#    CONFIG.PCW_EN_QSPI {1} \
# #TE_MOD#    CONFIG.PCW_EN_I2C1 {1} \
# #TE_MOD#    CONFIG.PCW_EN_I2C0 {1} \
# #TE_MOD#    CONFIG.PCW_EN_GPIO {1} \
# #TE_MOD#    CONFIG.PCW_EN_ENET0 {1} \
# #TE_MOD#    CONFIG.PCW_EN_EMIO_WP_SDIO1 {0} \
# #TE_MOD#    CONFIG.PCW_EN_EMIO_WDT {1} \
# #TE_MOD#    CONFIG.PCW_EN_EMIO_UART0 {0} \
# #TE_MOD#    CONFIG.PCW_EN_EMIO_TTC1 {1} \
# #TE_MOD#    CONFIG.PCW_EN_EMIO_TTC0 {1} \
# #TE_MOD#    CONFIG.PCW_EN_EMIO_SDIO1 {0} \
# #TE_MOD#    CONFIG.PCW_EN_EMIO_I2C1 {1} \
# #TE_MOD#    CONFIG.PCW_EN_EMIO_CD_SDIO1 {0} \
# #TE_MOD#    CONFIG.PCW_ENET_RESET_ENABLE {0} \
# #TE_MOD#    CONFIG.PCW_ENET1_RESET_ENABLE {0} \
# #TE_MOD#    CONFIG.PCW_ENET1_PERIPHERAL_DIVISOR1 {1} \
# #TE_MOD#    CONFIG.PCW_ENET1_PERIPHERAL_DIVISOR0 {1} \
# #TE_MOD#    CONFIG.PCW_ENET0_RESET_ENABLE {0} \
# #TE_MOD#    CONFIG.PCW_ENET0_PERIPHERAL_FREQMHZ {1000 Mbps} \
# #TE_MOD#    CONFIG.PCW_ENET0_PERIPHERAL_ENABLE {1} \
# #TE_MOD#    CONFIG.PCW_ENET0_PERIPHERAL_DIVISOR1 {1} \
# #TE_MOD#    CONFIG.PCW_ENET0_PERIPHERAL_DIVISOR0 {8} \
# #TE_MOD#    CONFIG.PCW_ENET0_GRP_MDIO_IO {MIO 52 .. 53} \
# #TE_MOD#    CONFIG.PCW_ENET0_GRP_MDIO_ENABLE {1} \
# #TE_MOD#    CONFIG.PCW_ENET0_ENET0_IO {MIO 16 .. 27} \
# #TE_MOD#    CONFIG.PCW_DDR_RAM_HIGHADDR {0x1FFFFFFF} \
# #TE_MOD#    CONFIG.PCW_DDR_PERIPHERAL_DIVISOR0 {2} \
# #TE_MOD#    CONFIG.PCW_DDR_DDR_PLL_FREQMHZ {1066.667} \
# #TE_MOD#    CONFIG.PCW_DDRPLL_CTRL_FBDIV {32} \
# #TE_MOD#    CONFIG.PCW_DCI_PERIPHERAL_DIVISOR1 {7} \
# #TE_MOD#    CONFIG.PCW_DCI_PERIPHERAL_DIVISOR0 {15} \
# #TE_MOD#    CONFIG.PCW_CRYSTAL_PERIPHERAL_FREQMHZ {33.333333} \
# #TE_MOD#    CONFIG.PCW_CPU_PERIPHERAL_DIVISOR0 {2} \
# #TE_MOD#    CONFIG.PCW_CPU_CPU_PLL_FREQMHZ {1333.333} \
# #TE_MOD#    CONFIG.PCW_CLK3_FREQ {10000000} \
# #TE_MOD#    CONFIG.PCW_CLK2_FREQ {10000000} \
# #TE_MOD#    CONFIG.PCW_CLK1_FREQ {10000000} \
# #TE_MOD#    CONFIG.PCW_CLK0_FREQ {100000000} \
# #TE_MOD#    CONFIG.PCW_CAN_PERIPHERAL_DIVISOR1 {1} \
# #TE_MOD#    CONFIG.PCW_CAN_PERIPHERAL_DIVISOR0 {1} \
# #TE_MOD#    CONFIG.PCW_ARMPLL_CTRL_FBDIV {40} \
# #TE_MOD#    CONFIG.PCW_ACT_WDT_PERIPHERAL_FREQMHZ {111.111115} \
# #TE_MOD#    CONFIG.PCW_ACT_UART_PERIPHERAL_FREQMHZ {100.000000} \
# #TE_MOD#    CONFIG.PCW_ACT_TTC1_CLK2_PERIPHERAL_FREQMHZ {111.111115} \
# #TE_MOD#    CONFIG.PCW_ACT_TTC1_CLK1_PERIPHERAL_FREQMHZ {111.111115} \
# #TE_MOD#    CONFIG.PCW_ACT_TTC1_CLK0_PERIPHERAL_FREQMHZ {111.111115} \
# #TE_MOD#    CONFIG.PCW_ACT_TTC0_CLK2_PERIPHERAL_FREQMHZ {111.111115} \
# #TE_MOD#    CONFIG.PCW_ACT_TTC0_CLK1_PERIPHERAL_FREQMHZ {111.111115} \
# #TE_MOD#    CONFIG.PCW_ACT_TTC0_CLK0_PERIPHERAL_FREQMHZ {111.111115} \
# #TE_MOD#    CONFIG.PCW_ACT_TPIU_PERIPHERAL_FREQMHZ {200.000000} \
# #TE_MOD#    CONFIG.PCW_ACT_SPI_PERIPHERAL_FREQMHZ {10.000000} \
# #TE_MOD#    CONFIG.PCW_ACT_SMC_PERIPHERAL_FREQMHZ {10.000000} \
# #TE_MOD#    CONFIG.PCW_ACT_SDIO_PERIPHERAL_FREQMHZ {100.000000} \
# #TE_MOD#    CONFIG.PCW_ACT_QSPI_PERIPHERAL_FREQMHZ {200.000000} \
# #TE_MOD#    CONFIG.PCW_ACT_PCAP_PERIPHERAL_FREQMHZ {200.000000} \
# #TE_MOD#    CONFIG.PCW_ACT_FPGA3_PERIPHERAL_FREQMHZ {10.000000} \
# #TE_MOD#    CONFIG.PCW_ACT_FPGA2_PERIPHERAL_FREQMHZ {10.000000} \
# #TE_MOD#    CONFIG.PCW_ACT_FPGA1_PERIPHERAL_FREQMHZ {10.000000} \
# #TE_MOD#    CONFIG.PCW_ACT_FPGA0_PERIPHERAL_FREQMHZ {100.000000} \
# #TE_MOD#    CONFIG.PCW_ACT_ENET1_PERIPHERAL_FREQMHZ {10.000000} \
# #TE_MOD#    CONFIG.PCW_ACT_ENET0_PERIPHERAL_FREQMHZ {125.000000} \
# #TE_MOD#    CONFIG.PCW_ACT_DCI_PERIPHERAL_FREQMHZ {10.158730} \
# #TE_MOD#    CONFIG.PCW_ACT_CAN_PERIPHERAL_FREQMHZ {10.000000} \
# #TE_MOD#    CONFIG.PCW_ACT_APU_PERIPHERAL_FREQMHZ {666.666687} \
# #TE_MOD# #Empty Line
  # Create instance: vio_0, and set properties
  set vio_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:vio:3.0 vio_0 ]
  set_property -dict [ list \
   CONFIG.C_NUM_PROBE_OUT {0} \
 ] $vio_0

  # Create instance: xlconcat_0, and set properties
  set xlconcat_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 xlconcat_0 ]
  set_property -dict [ list \
   CONFIG.NUM_PORTS {3} \
 ] $xlconcat_0

  # Create interface connections
# #TE_MOD#   connect_bd_intf_net -intf_net processing_system7_0_DDR [get_bd_intf_ports DDR] [get_bd_intf_pins processing_system7_0/DDR]
# #TE_MOD#   connect_bd_intf_net -intf_net processing_system7_0_FIXED_IO [get_bd_intf_ports FIXED_IO] [get_bd_intf_pins processing_system7_0/FIXED_IO]
  connect_bd_intf_net -intf_net processing_system7_0_IIC_1 [get_bd_intf_pins SC0720_0/EMIO_I2C1] [get_bd_intf_pins processing_system7_0/IIC_1]

  # Create port connections
  connect_bd_net -net PHY_LEDs [get_bd_pins vio_0/probe_in0] [get_bd_pins xlconcat_0/dout]
  connect_bd_net -net PL_pin_K16_1 [get_bd_ports PL_pin_K16] [get_bd_pins SC0720_0/PL_pin_K16]
  connect_bd_net -net PL_pin_K19_1 [get_bd_ports PL_pin_K19] [get_bd_pins SC0720_0/PL_pin_K19]
  connect_bd_net -net PL_pin_M15_1 [get_bd_ports PL_pin_M15] [get_bd_pins SC0720_0/PL_pin_M15]
  connect_bd_net -net PL_pin_N15_1 [get_bd_ports PL_pin_N15] [get_bd_pins SC0720_0/PL_pin_N15]
  connect_bd_net -net PL_pin_P16_1 [get_bd_ports PL_pin_P16] [get_bd_pins SC0720_0/PL_pin_P16]
  connect_bd_net -net PL_pin_P22_1 [get_bd_ports PL_pin_P22] [get_bd_pins SC0720_0/PL_pin_P22]
  connect_bd_net -net SC0720_0_PHY_LED0 [get_bd_pins SC0720_0/PHY_LED0] [get_bd_pins xlconcat_0/In0]
  connect_bd_net -net SC0720_0_PHY_LED1 [get_bd_pins SC0720_0/PHY_LED1] [get_bd_pins xlconcat_0/In1]
  connect_bd_net -net SC0720_0_PHY_LED2 [get_bd_pins SC0720_0/PHY_LED2] [get_bd_pins xlconcat_0/In2]
  connect_bd_net -net SC0720_0_PL_pin_K20 [get_bd_ports PL_pin_K20] [get_bd_pins SC0720_0/PL_pin_K20]
  connect_bd_net -net SC0720_0_PL_pin_L16 [get_bd_ports PL_pin_L16] [get_bd_pins SC0720_0/PL_pin_L16]
  connect_bd_net -net SC0720_0_PL_pin_N22 [get_bd_ports PL_pin_N22] [get_bd_pins SC0720_0/PL_pin_N22]
  connect_bd_net -net processing_system7_0_FCLK_CLK0 [get_bd_pins processing_system7_0/FCLK_CLK0] [get_bd_pins processing_system7_0/M_AXI_GP0_ACLK] [get_bd_pins vio_0/clk]

  # Create address segments


  # Restore current instance
  current_bd_instance $oldCurInst

  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""



