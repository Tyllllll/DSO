transcript on
if ![file isdirectory DSO_iputf_libs] {
	file mkdir DSO_iputf_libs
}

if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

###### Libraries for IPUTF cores 
###### End libraries for IPUTF cores 
###### MIF file copy and HDL compilation commands for IPUTF cores 


vlog "E:/Quartus/VHDL/DSO/PLL_sim/PLL.vo"

vlog -vlog01compat -work work +incdir+E:/Quartus/VHDL/DSO {E:/Quartus/VHDL/DSO/FIFO.v}

vlog -vlog01compat -work work +incdir+E:/Quartus/VHDL/DSO/simulation/modelsim {E:/Quartus/VHDL/DSO/simulation/modelsim/FIFO_sim.vwf.vt}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cyclonev_ver -L cyclonev_hssi_ver -L cyclonev_pcie_hip_ver -L rtl_work -L work -voptargs="+acc"  FIFO_vlg_vec_tst

add wave *
view structure
view signals
run -all
