import scoreboard_pkg::*;
import transaction_pkg::*;
import shared_pkg::*;
module FIFO_tb(fifo_intf.TEST intf);  
FIFO_transaction fifo_tr;
integer i;

initial begin
    fifo_tr=new();
            intf.rst_n = 1;
            intf.rst_n = 0; 
            -> trigger;    
         @(negedge intf.clk);  
            intf.rst_n = 1;
        //write only
        $display("START OF WRITE ONLY");
        fifo_tr.write_enable.constraint_mode(1);
        fifo_tr.read_enable.constraint_mode(0);
        for (i=0;i<10000;i=i+1)begin
        assert(fifo_tr.randomize());
        intf.data_in=fifo_tr.data_in;
        intf.rst_n = fifo_tr.rst_n; 
        intf.rd_en = fifo_tr.rd_en; 
        intf.wr_en = fifo_tr.wr_en;
        -> trigger; 
        //$display("rd_en=%d,wr_en=%d",fifo_tr.rd_en,fifo_tr.wr_en);
        @(negedge intf.clk);
        end
         $display("END OF WRITE ONLY");

        //READ ONLY
        $display("START OF READ ONLY");
        fifo_tr.write_enable.constraint_mode(0);
        fifo_tr.read_enable.constraint_mode(1);
        for (i=0;i<10000;i=i+1)begin
        assert(fifo_tr.randomize());
        intf.data_in=fifo_tr.data_in;
        intf.rst_n = fifo_tr.rst_n; 
        intf.rd_en = fifo_tr.rd_en; 
        intf.wr_en = fifo_tr.wr_en;
        -> trigger; 
        //$display("rd_en=%d,wr_en=%d",fifo_tr.rd_en,fifo_tr.wr_en);
        @(negedge intf.clk);
        end
        $display("END OF READ ONLY");

        //WRITE AND READ 
         $display("START OF WRITE AND READ");
        fifo_tr.write_enable.constraint_mode(1);
        fifo_tr.read_enable.constraint_mode(1);
        for (i=0;i<10000;i=i+1)begin
        assert(fifo_tr.randomize());
        intf.data_in=fifo_tr.data_in;
        intf.rst_n = fifo_tr.rst_n; 
        intf.rd_en = fifo_tr.rd_en; 
        intf.wr_en = fifo_tr.wr_en;
        -> trigger; 
        //$display("rd_en=%d,wr_en=%d",fifo_tr.rd_en,fifo_tr.wr_en);
        @(negedge intf.clk);
        end
        $display("END OF WRITE AND READ");
    test_finished=1;
    -> trigger; 
    end
endmodule

