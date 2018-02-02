transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+C:/Users/yl/Desktop/IIC/ADS_IIC_SEG_VGA/M_bin_to_bcd {C:/Users/yl/Desktop/IIC/ADS_IIC_SEG_VGA/M_bin_to_bcd/SHIFT.v}
vlog -vlog01compat -work work +incdir+C:/Users/yl/Desktop/IIC/ADS_IIC_SEG_VGA/M_bin_to_bcd {C:/Users/yl/Desktop/IIC/ADS_IIC_SEG_VGA/M_bin_to_bcd/CMP.v}
vlog -vlog01compat -work work +incdir+C:/Users/yl/Desktop/IIC/ADS_IIC_SEG_VGA/M_bin_to_bcd {C:/Users/yl/Desktop/IIC/ADS_IIC_SEG_VGA/M_bin_to_bcd/BIN_TO_BCD.v}
vlog -vlog01compat -work work +incdir+C:/Users/yl/Desktop/IIC/ADS_IIC_SEG_VGA/M_top {C:/Users/yl/Desktop/IIC/ADS_IIC_SEG_VGA/M_top/ADS_IIC_SEG_VGA.v}
vlog -vlog01compat -work work +incdir+C:/Users/yl/Desktop/IIC/ADS_IIC_SEG_VGA/M_iic {C:/Users/yl/Desktop/IIC/ADS_IIC_SEG_VGA/M_iic/IIC.v}
vlog -vlog01compat -work work +incdir+C:/Users/yl/Desktop/IIC/ADS_IIC_SEG_VGA/M_seg7 {C:/Users/yl/Desktop/IIC/ADS_IIC_SEG_VGA/M_seg7/SEG7.v}
vlog -vlog01compat -work work +incdir+C:/Users/yl/Desktop/IIC/ADS_IIC_SEG_VGA/M_seg7 {C:/Users/yl/Desktop/IIC/ADS_IIC_SEG_VGA/M_seg7/FRE_DIV.v}
vlog -vlog01compat -work work +incdir+C:/Users/yl/Desktop/IIC/ADS_IIC_SEG_VGA/M_seg7 {C:/Users/yl/Desktop/IIC/ADS_IIC_SEG_VGA/M_seg7/SEG7_TOP.v}
vlog -vlog01compat -work work +incdir+C:/Users/yl/Desktop/IIC/ADS_IIC_SEG_VGA/M_vga {C:/Users/yl/Desktop/IIC/ADS_IIC_SEG_VGA/M_vga/KEY.v}
vlog -vlog01compat -work work +incdir+C:/Users/yl/Desktop/IIC/ADS_IIC_SEG_VGA/M_vga {C:/Users/yl/Desktop/IIC/ADS_IIC_SEG_VGA/M_vga/VGA.v}
vlog -vlog01compat -work work +incdir+C:/Users/yl/Desktop/IIC/ADS_IIC_SEG_VGA/M_vga {C:/Users/yl/Desktop/IIC/ADS_IIC_SEG_VGA/M_vga/DATA.v}
vlog -vlog01compat -work work +incdir+C:/Users/yl/Desktop/IIC/ADS_IIC_SEG_VGA/M_ip {C:/Users/yl/Desktop/IIC/ADS_IIC_SEG_VGA/M_ip/pll.v}
vlog -vlog01compat -work work +incdir+C:/Users/yl/Desktop/IIC/ADS_IIC_SEG_VGA/M_vga {C:/Users/yl/Desktop/IIC/ADS_IIC_SEG_VGA/M_vga/VGA_TOP.v}
vlog -vlog01compat -work work +incdir+C:/Users/yl/Desktop/IIC/ADS_IIC_SEG_VGA/db {C:/Users/yl/Desktop/IIC/ADS_IIC_SEG_VGA/db/pll_altpll.v}

vlog -vlog01compat -work work +incdir+C:/Users/yl/Desktop/IIC/ADS_IIC_SEG_VGA/simulation/modelsim {C:/Users/yl/Desktop/IIC/ADS_IIC_SEG_VGA/simulation/modelsim/SEG7_TOP_tb.vt}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cycloneive_ver -L rtl_work -L work -voptargs="+acc"  SEG7_TOP_vlg_tst

add wave *
view structure
view signals
run 1 sec
