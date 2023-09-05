module shifter(in, shift, sout);
    // I/O declarations
    input [15:0] in;
    input [1:0] shift;
    output [15:0] sout;
    reg [15:0] sout;

    // Shifter opertions
    always @(*) begin
	case (shift)
	    2'b00 : sout = in;
	    2'b01 : sout = in << 1;
	    2'b10 : sout = in >> 1;
	    2'b11 : begin
			sout = in >> 1;
			sout[15] = in[15];
		    end
	    default : sout = {16{1'bx}};
	endcase
    end
endmodule
