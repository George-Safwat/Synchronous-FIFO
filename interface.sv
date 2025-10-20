interface fifo_intf#(parameter FIFO_WIDTH = 16, parameter FIFO_DEPTH = 8)(clk);
//INPUTS
input bit clk;
bit [FIFO_WIDTH-1:0] data_in;
bit wr_en,rst_n,rd_en;
//OUTPUTS
logic [FIFO_WIDTH-1:0] data_out;
logic full,empty,almostfull,almostempty,overflow,underflow,wr_ack;

modport DUT (input clk,data_in,rst_n,wr_en,rd_en, 
 output data_out,wr_ack,overflow,full,empty,almostfull,almostempty,underflow); 

modport TEST (input clk,data_out,wr_ack,overflow,full,empty,almostfull,almostempty,  
underflow,output data_in,rst_n,wr_en,rd_en); 

modport mon (input clk,data_in,rst_n,wr_en,rd_en,data_out,wr_ack,overflow,full,  
empty,almostfull,almostempty,underflow); 

endinterface