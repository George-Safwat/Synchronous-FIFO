module top();
bit clk;
initial begin
clk=0;
forever #1 clk=~clk;
end

fifo_intf intf(clk);
FIFO DUT(intf);
FIFO_tb TEST(intf);
monitor mon(intf);
endmodule