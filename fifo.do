vlib work
vlog +define+SIM shared_pkg.sv interface.sv FIFO.sv FIFO_TRANSACTIONS.sv func_cov_collection.sv  Monitor.sv  scoreboard.sv testbench_fifo.sv top.sv +cover -covercells 
vsim -voptargs=+acc work.top -cover
coverage save FIFO.ucdb -onexit -du work.FIFO
add wave -position insertpoint sim:/top/intf/*
add wave /top/DUT/reset /top/DUT/wr_ack_assert /top/DUT/overflow_assert /top/DUT/underflow_assert /top/DUT/empty_assert /top/DUT/full_assert /top/DUT/almostfull_assert /top/DUT/almostempty_assert /top/DUT/pointer_wraparound_assert_write /top/DUT/pointer_wraparound_assert_read /top/DUT/threshold_assert /top/TEST/#ublk#182146786#19/immed__20 /top/TEST/#ublk#182146786#35/immed__36 /top/TEST/#ublk#182146786#51/immed__52
run -all
coverage report -detail -cvg -directive -comments -file F_cover_fifo.txt -noa -all
quit -sim
vcover report FIFO.ucdb -details -all -output coverage_rpt_FIFO.txt



