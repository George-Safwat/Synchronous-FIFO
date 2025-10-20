package transaction_pkg;
parameter FIFO_WIDTH = 16; 
parameter FIFO_DEPTH = 8;
class FIFO_transaction;
//INPUTS
rand bit clk;
rand bit [FIFO_WIDTH-1:0] data_in;
rand bit wr_en,rst_n,rd_en;
//OUTPUTS
logic [FIFO_WIDTH-1:0] data_out;
logic full,empty,almostfull,almostempty,overflow,underflow,wr_ack;

int RD_EN_ON_DIST , WR_EN_ON_DIST;
//CONSTRUCTOR
function new(int Read=30, int Write=70);
RD_EN_ON_DIST=Read;
WR_EN_ON_DIST=Write;
endfunction

//CONSTRAINTS
constraint reset{
    rst_n dist{1:/90,0:/10};
}
constraint write_enable{
    wr_en dist{1:/WR_EN_ON_DIST, 0:/(100-WR_EN_ON_DIST)};
}
constraint read_enable{
    rd_en dist{1:/RD_EN_ON_DIST, 0:/(100-RD_EN_ON_DIST)};
}

endclass
endpackage