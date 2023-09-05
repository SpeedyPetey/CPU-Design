module vDFFE(clk, en, in, out);
    parameter n = 1;
    // I/O declarations
    input clk, en;
    input [n-1:0] in;
    output [n-1:0] out;
    reg [n-1:0] out;
    wire [n-1:0] next_out;

    // Enabled vDFFE function
    assign next_out = en?in:out;
    always @(posedge clk)
	out = next_out;
endmodule
