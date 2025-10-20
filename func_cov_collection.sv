package func_pkg;
import transaction_pkg::*;
class FIFO_coverage ;

FIFO_transaction F_cvg_txn=new();

covergroup cvr_grp;

write_enable: coverpoint F_cvg_txn.wr_en {
    bins wr_enable_low={0};
    bins wr_enable_high={1};
}
read_enable: coverpoint F_cvg_txn.rd_en{
    bins rd_enable_low={0};
    bins rd_enable_high={1};
}
FULL: coverpoint F_cvg_txn.full{
    bins Full_low={0};
    bins Full_high={1};
}
EMPTY: coverpoint F_cvg_txn.empty{
    bins Empty_low={0};
    bins Empty_high={1};
}
ALMOSTFULL: coverpoint F_cvg_txn.almostfull{
    bins Almostfull_low={0};
    bins Almostfull_high={1};
}
ALMOSTEMPTY: coverpoint F_cvg_txn.almostempty{
    bins Almostempty_low={0};
    bins Almostempty_high={1};
}
OVERFLOW: coverpoint F_cvg_txn.overflow{
    bins Overflow_low={0};
    bins Overflow_high={1};
}
UNDERFLOW: coverpoint F_cvg_txn.underflow{
    bins Underflow_low={0};
    bins Underflow_high={1};
}
Write_ack: coverpoint F_cvg_txn.wr_ack{
    bins write_acknowledge_low={0};
    bins write_acknowledge_high={1};
}

rd_en_with_wr_enable_full: cross read_enable, write_enable, FULL {
    ignore_bins read_enable_with_full_high= 
       binsof(read_enable) intersect {1} && binsof(FULL) intersect {1};
}

rd_en_with_wr_enable_empty: cross read_enable,write_enable,EMPTY{
    ignore_bins write_enable_with_empty_high= 
       binsof(write_enable) intersect {1} && binsof(EMPTY) intersect {1};
       }
rd_en_with_wr_enable_almostfull: cross read_enable, write_enable,ALMOSTFULL;
rd_en_with_wr_enable_almostempty: cross read_enable,write_enable,ALMOSTEMPTY;

rd_en_with_wr_enable_underflow: cross read_enable, write_enable, UNDERFLOW {
   ignore_bins read_with_underflow = 
       binsof(read_enable) intersect {0} && 
       binsof(UNDERFLOW) intersect {1};
}

rd_en_with_wr_enable_overflow: cross read_enable, write_enable, OVERFLOW {
   ignore_bins write_with_overflow = 
       binsof(write_enable) intersect {0} && 
       binsof(OVERFLOW) intersect {1};
}

rd_en_with_wr_enable_wr_ack: cross read_enable, write_enable, Write_ack {
   ignore_bins write_with_wr_ack = 
       binsof(write_enable) intersect {0} && 
       binsof(Write_ack) intersect {1};
}

endgroup
//CONSTRUCTOR
function new();
cvr_grp=new();
endfunction

function void sample_data(FIFO_transaction F_txn);
F_cvg_txn=F_txn;
cvr_grp.sample();
endfunction

endclass
endpackage