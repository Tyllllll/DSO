vlog -work work FIFO_sim.vwf.vtvsim -novopt -c -t 1ps -L cyclonev_ver -L altera_ver -L altera_mf_ver -L 220model_ver -L sgate work.FIFO_vlg_vec_tst -voptargs="+acc"
add wave /*
run -all
