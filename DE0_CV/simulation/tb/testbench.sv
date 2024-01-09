module testbench;


	logic clk,rst;
	logic [7:0]w_q;
	
CPU a1(
	.clk(clk),
	.rst(rst),
	.w_q(w_q)
	);

	always begin
		#5 clk = ~clk;
	end
	
	initial begin
		clk = 0;
		rst = 1;
		#10 rst = 0;
		#1000 $stop;
	end
endmodule