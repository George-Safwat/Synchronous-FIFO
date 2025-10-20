package scoreboard_pkg;
import transaction_pkg::*;
import shared_pkg::*;
import func_pkg::*;
class FIFO_scoreboard;
localparam max_fifo_addr = $clog2(FIFO_DEPTH);
logic [FIFO_WIDTH-1:0] data_out_ref;
logic full_ref,empty_ref,almostfull_ref,almostempty_ref,overflow_ref,underflow_ref,wr_ack_ref;
reg [FIFO_WIDTH-1:0] mem [FIFO_DEPTH-1:0]; 
reg [max_fifo_addr-1:0] wr_ptr, rd_ptr;
reg [max_fifo_addr:0] count; 

function void comb_flags();
   full_ref       = (count == FIFO_DEPTH) ? 1 : 0;
   empty_ref      = (count == 0) ? 1 : 0;
   almostfull_ref = (count == FIFO_DEPTH-1) ? 1 : 0;
   almostempty_ref= (count == 1) ? 1 : 0;
endfunction



function void check_data(FIFO_transaction tr);
      // Run the reference model
      reference_model(tr);
      if((data_out_ref==tr.data_out)&&({full_ref,empty_ref,almostfull_ref,almostempty_ref,underflow_ref,overflow_ref}=={tr.full,tr.empty,tr.almostfull,tr.almostempty,tr.underflow,tr.overflow}))
      begin
            correct_count++;
$display("rst_n=%0d data_in=%0d data_out=%0d data_out_ref=%0d wr_ack=%0d wr_ack_ref=%0d overflow=%0d overflow_ref=%0d full=%0d full_ref=%0d empty=%0d empty_ref=%0d almostfull=%0d almostfull_ref=%0d almostempty=%0d almostempty_ref=%0d underflow=%0d underflow_ref=%0d wr_en=%0d rd_en=%0d count=%0d",
         tr.rst_n, tr.data_in, tr.data_out, data_out_ref,
         tr.wr_ack, wr_ack_ref, tr.overflow, overflow_ref,
         tr.full, full_ref, tr.empty, empty_ref,
         tr.almostfull, almostfull_ref, tr.almostempty, almostempty_ref,
         tr.underflow, underflow_ref, tr.wr_en, tr.rd_en, count);


      end
      else begin
             error_count++;
            $display("Error ==> correct_count=%d, error_count=%d, data_in=%d, data_out_ref=%d, tr.data_out=%d ",correct_count,error_count,tr.data_in,data_out_ref,tr.data_out);
      end
endfunction

function void reference_model(FIFO_transaction ref_tr);
//REFRENCE FOR WRITE

if (!ref_tr.rst_n) begin
            wr_ptr=0;
            full_ref=0;
            wr_ack_ref=0;
		empty_ref=1;
            overflow_ref=0; 
            
	end
	else if (ref_tr.wr_en && !full_ref) 
      begin 
		mem[wr_ptr] = ref_tr.data_in;
		wr_ack_ref = 1;
		wr_ptr <= wr_ptr + 1;
		overflow_ref=0;
	end
	else begin 
		wr_ack_ref = 0; 
		if (full_ref & ref_tr.wr_en)
			overflow_ref = 1;
		else
			overflow_ref = 0;
	end

//REFRENCE FOR READ
	if (!ref_tr.rst_n) begin
            rd_ptr = 0;
		data_out_ref = 0; 
            empty_ref = 1; 
            almostempty_ref = 0; 
            underflow_ref = 0; 
	end
      else if(empty_ref && ref_tr.rd_en)
 			underflow_ref  = 1; 
	else if (ref_tr.rd_en && (!empty_ref || full_ref)) begin
            data_out_ref = mem[rd_ptr];
		rd_ptr = rd_ptr + 1;
		underflow_ref=0;
	end
   


//COUNTER
if (!ref_tr.rst_n) begin
		count = 0;
	end
	else begin
		if	( ({ref_tr.wr_en, ref_tr.rd_en} == 2'b10) && !full_ref) 
			count = count + 1;
		else if ( ({ref_tr.wr_en, ref_tr.rd_en} == 2'b01) && !empty_ref)
			count = count - 1;
            else if	( ({ref_tr.wr_en, ref_tr.rd_en} == 2'b11) && empty_ref) 
			count = count + 1;
            else if	( ({ref_tr.wr_en, ref_tr.rd_en} == 2'b11) && full_ref) 
			count = count - 1;

	end
      //calling flags
            comb_flags();
endfunction
endclass
endpackage

