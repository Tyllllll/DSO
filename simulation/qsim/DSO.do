onerror {exit -code 1}
vlib work
vlog -work work DSO.vo
vlog -work work measuring_sim.vwf.vt
vsim -novopt -c -t 1ps -L cyclonev_ver -L altera_ver -L altera_mf_ver -L 220model_ver -L sgate work.measuring_vlg_vec_tst -voptargs="+acc"
vcd file -direction DSO.msim.vcd
vcd add -internal measuring_vlg_vec_tst/*
vcd add -internal measuring_vlg_vec_tst/i1/*
run -all
quit -f
