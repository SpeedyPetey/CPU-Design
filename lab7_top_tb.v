module lab7_top_tb;

    // Inputs to the module instansiation and wires for the outputs
    reg CLK, RESET;
    reg [9:0] SW;
    wire [9:0] LEDR;
    wire [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;

    // Module instansiation of the top module
    lab7_top DUT(
	.KEY({2'b0, ~RESET, ~CLK}),
	.SW(SW),
	.LEDR(LEDR),
	.HEX0(HEX0),
	.HEX1(HEX1),
	.HEX2(HEX2),
	.HEX3(HEX3),
	.HEX4(HEX4),
	.HEX5(HEX5)
    );

    // Initiation of the clock cycle 
    initial begin
	CLK = 1'b0;
	#10;
	forever begin
	    CLK = 1'b1;
	    #10;
	    CLK = 1'b0;
	    #10;
	end
    end
	
    // Resets the state, inputs a number to the switches, and allocates enough time for the CPU to finish
    initial begin
	RESET = 1'b1;
	#15;
	RESET = 1'b0;
	SW[7:0] = 8'b00000101;
	#10000;
	$stop;
    end

endmodule
	 




