import shared_pkg::*;
import transaction_pkg::*;
import scoreboard_pkg::*;
import func_pkg::*;
module monitor(fifo_intf.mon intf);

FIFO_transaction tr= new(); 
FIFO_scoreboard sb= new();
FIFO_coverage cov= new();

initial begin
     
    forever begin
       
        wait (trigger.triggered);
            @(negedge intf.clk);
            //input
            tr.data_in=intf.data_in;
            tr.wr_en=intf.wr_en;
            tr.rst_n=intf.rst_n;
            tr.rd_en=intf.rd_en;
            //output
            tr.data_out=intf.data_out;
            tr.full=intf.full;
            tr.empty=intf.empty;
            tr.almostfull=intf.almostfull;
            tr.almostempty=intf.almostempty;
            tr.overflow=intf.overflow;
            tr.underflow=intf.underflow;
            tr.wr_ack=intf.wr_ack;
fork

        //PROCESS_1
        begin
        cov.sample_data(tr);
        end
        //PROCESS_2
        begin
        sb.check_data(tr);
        end

join
    if (test_finished==1)begin
    //$display("tr.data_in=%d,intf.data_in=%d,tr.data_out=%d,intf.data_out=%d",tr.data_in,intf.data_in,tr.data_out,intf.data_out); 
     $display("error_count=%d, correct_count=%d",error_count,correct_count);
     $stop;
                end
        end
    end
endmodule