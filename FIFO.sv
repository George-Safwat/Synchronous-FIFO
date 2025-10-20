module FIFO(fifo_intf.DUT intf); 
localparam max_fifo_addr = $clog2( intf.FIFO_DEPTH); //ceiling log with base 2 
//Depth mem word
reg [ intf.FIFO_WIDTH-1:0] mem [intf.FIFO_DEPTH-1:0];

reg [max_fifo_addr-1:0] wr_ptr, rd_ptr;
reg [max_fifo_addr:0] count; //4-bits
//WRITE
always @(posedge intf.clk or negedge intf.rst_n) begin 
	if (!intf.rst_n) begin
		wr_ptr <= 0; 
		intf.overflow<=0;
		intf.wr_ack<=0;
		intf.wr_en<=0;
	end
	else if(intf.wr_en && intf.rd_en && intf.empty )begin
		mem[wr_ptr] <= intf.data_in;
		intf.wr_ack <= 1;
		wr_ptr <= wr_ptr + 1;
		intf.overflow<=0;

	end
	else if (intf.wr_en && !intf.full)
	 begin 
		mem[wr_ptr] <= intf.data_in;
		intf.wr_ack <= 1;
		wr_ptr <= (wr_ptr == intf.FIFO_DEPTH-1) ? 0 : wr_ptr + 1;//adding checker to check the wraparound
		wr_ptr <= wr_ptr + 1;
		intf.overflow<=0;
	end
	else begin 
		intf.wr_ack <= 0; 
		if (intf.full && intf.wr_en)
			intf.overflow <= 1;
		else
			intf.overflow <= 0;
	end
end
//READ
always @(posedge intf.clk or negedge intf.rst_n) begin
	if (!intf.rst_n) begin
		rd_ptr <= 0;
		intf.underflow<=0;
		intf.data_out<=0;
		intf.rd_en<=0;
	end 
	else if (intf.rd_en && (intf.full || !intf.empty)) 
	begin //read
		intf.data_out <= mem[rd_ptr];
		rd_ptr <= (rd_ptr == intf.FIFO_DEPTH-1) ? 0 : rd_ptr + 1;//adding checker to check the wraparound
		rd_ptr <= rd_ptr + 1;
		intf.underflow<=0;	
	end
		else if (intf.empty && intf.rd_en) //bug==>adding underflow here not below
 			intf.underflow  <= 1; 
end

always @(posedge intf.clk or negedge intf.rst_n) begin
	if (!intf.rst_n) begin
		count <= 0;
	end
	else begin
		if	( ({intf.wr_en, intf.rd_en} == 2'b10) && !intf.full) 
			count <= count + 1;
		else if ( ({intf.wr_en, intf.rd_en} == 2'b01) && !intf.empty)
			count <= count - 1; //bug==>adding 2 cases when write and read enable are asserted
		else if ( ({ intf.wr_en,  intf.rd_en} == 2'b11) && intf.full)  
            count <= count - 1; 
        else if ( ({ intf.wr_en,  intf.rd_en} == 2'b11) && intf.empty) 
            count <= count + 1;

	end
end


assign intf.full = (count ==  intf.FIFO_DEPTH)? 1 : 0;
assign intf.empty = (count == 0)? 1 : 0; 
assign intf.almostfull = (count ==  intf.FIFO_DEPTH-1)? 1 : 0; //bug FIFO_DEPTH-2 should be -1
assign intf.almostempty = (count == 1)? 1 : 0;

//Add assertions only in simulation, not in synthesis.
`ifdef SIM
//ASSERTIONS
always_comb begin 
if(!intf.rst_n) begin
reset: assert final(count == 0 && wr_ptr==0 && rd_ptr==0 );  
cvr_reset:cover final(count == 0 && wr_ptr==0 && rd_ptr==0); 
end 
end
property p1;
@(posedge intf.clk) disable iff(!intf.rst_n) (intf.wr_en && !intf.full) |=>(intf.wr_ack)
endproperty
wr_ack_assert: assert property(p1);
wr_ack_cvr: cover property(p1);

property p2;
@(posedge intf.clk) disable iff(!intf.rst_n) (intf.wr_en && intf.full) |=>(intf.overflow);
endproperty
overflow_assert: assert property(p2);
overflow_cvr: cover property(p2);

property p3;
@(posedge intf.clk) disable iff(!intf.rst_n) (intf.rd_en && intf.empty) |=>(intf.underflow);
endproperty
underflow_assert: assert property(p3);
underflow_cvr: cover property(p3);

property p4;
@(posedge intf.clk) disable iff(!intf.rst_n) (!count) |->(intf.empty);
endproperty
empty_assert: assert property(p4);
empty_cvr: cover property(p4);

property p5;
@(posedge intf.clk) disable iff(!intf.rst_n) (count===intf.FIFO_DEPTH) |->(intf.full);
endproperty
full_assert: assert property(p5);
full_cvr: cover property(p5);

property p6;
@(posedge intf.clk) disable iff(!intf.rst_n) (count===(intf.FIFO_DEPTH-1)) |->(intf.almostfull);
endproperty
almostfull_assert: assert property(p6);
almostfull_cvr: cover property(p6);

property p7;
@(posedge intf.clk) disable iff(!intf.rst_n) (count===1) |->(intf.almostempty);
endproperty
almostempty_assert: assert property(p7);
almostempty_cvr: cover property(p7);

// Write pointer wraparound
property p8;
  @(posedge intf.clk) disable iff(!intf.rst_n)
    (wr_ptr == intf.FIFO_DEPTH-1 && intf.wr_en && !intf.full) |=> (wr_ptr == 0);
endproperty
pointer_wraparound_assert_write: assert property(p8);
pointer_wraparound_cvr_write:   cover property(p8);

// Read pointer wraparound
property p9;
  @(posedge intf.clk) disable iff(!intf.rst_n)
    (rd_ptr == intf.FIFO_DEPTH-1 && intf.rd_en && !intf.empty) |=> (rd_ptr == 0);
endproperty
pointer_wraparound_assert_read: assert property(p9);
pointer_wraparound_cvr_read:   cover property(p9);


property p10;
@(posedge intf.clk) disable iff(!intf.rst_n) (wr_ptr<intf.FIFO_DEPTH) && (rd_ptr<intf.FIFO_DEPTH) && (count<=intf.FIFO_DEPTH);
endproperty
threshold_assert: assert property(p10);
threshold_cvr: cover property(p10);

`endif 

endmodule