# Copyright (C) 1991-2012 Altera Corporation
# Your use of Altera Corporation's design tools, logic functions 
# and other software and tools, and its AMPP partner logic 
# functions, and any output files from any of the foregoing 
# (including device programming or simulation files), and any 
# associated documentation or information are expressly subject 
# to the terms and conditions of the Altera Program License 
# Subscription Agreement, Altera MegaCore Function License 
# Agreement, or other applicable license agreement, including, 
# without limitation, that your use is for the sole purpose of 
# programming logic devices manufactured by Altera and sold by 
# Altera or its authorized distributors.  Please refer to the 
# applicable agreement for further details.

# Quartus II 64-Bit Version 12.1 Build 177 11/07/2012 SJ Full Version
# File: C:\Users\yl\Desktop\IIC\ADS_IIC_SEG_VGA\M_top\ADS_IIC_SEG_VGA.tcl
# Generated on: Fri Jan 12 21:09:31 2018

# clk, rst_n, key_in        
# seg, sel, sda, scl, hsync, vsync, DATA

package require ::quartus::project

set_location_assignment PIN_E1  -to clk
set_location_assignment PIN_N13 -to rst_n
set_location_assignment PIN_M15 -to key_in
set_location_assignment PIN_M16 -to key_seg

set_location_assignment PIN_R16 -to seg[7]
set_location_assignment PIN_N15 -to seg[6]
set_location_assignment PIN_N12 -to seg[5]
set_location_assignment PIN_P15 -to seg[4]
set_location_assignment PIN_T15 -to seg[3]
set_location_assignment PIN_P16 -to seg[2]
set_location_assignment PIN_N16 -to seg[1]
set_location_assignment PIN_R14 -to seg[0]

set_location_assignment PIN_M11 -to sel[5]
set_location_assignment PIN_P11 -to sel[4]
set_location_assignment PIN_N11 -to sel[3]
set_location_assignment PIN_M10 -to sel[2]
set_location_assignment PIN_P9  -to sel[1]
set_location_assignment PIN_N9  -to sel[0]

set_location_assignment PIN_R13 -to sda
set_location_assignment PIN_N2  -to scl

set_location_assignment PIN_L6 -to hsync
set_location_assignment PIN_N3 -to vsync

set_location_assignment PIN_L4 -to DATA[15]
set_location_assignment PIN_L3 -to DATA[14]
set_location_assignment PIN_L7 -to DATA[13]
set_location_assignment PIN_K5 -to DATA[12]
set_location_assignment PIN_K6 -to DATA[11]
set_location_assignment PIN_J6 -to DATA[10]
set_location_assignment PIN_L8 -to DATA[9]
set_location_assignment PIN_K8 -to DATA[8]
set_location_assignment PIN_F7 -to DATA[7]
set_location_assignment PIN_G5 -to DATA[6]
set_location_assignment PIN_F5 -to DATA[5]
set_location_assignment PIN_F6 -to DATA[4]
set_location_assignment PIN_E5 -to DATA[3]
set_location_assignment PIN_D3 -to DATA[2]
set_location_assignment PIN_D4 -to DATA[1]
set_location_assignment PIN_C3 -to DATA[0]

