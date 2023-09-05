module regfile(data_in, writenum, write, readnum, clk, data_out);
    // I/O declarations
    input [15:0] data_in;
    input [2:0] writenum, readnum;
    input write, clk;
    output [15:0] data_out;
    wire [15:0] R0, R1, R2, R3, R4, R5, R6, R7; //memory regs
    
    //writing and reading decoding
    wire [7:0] writenumhot, readnumhot;
    Dec writing(writenum, writenumhot);
    Dec reading(readnum, readnumhot);  


    //write function
    
    vDFFE #(16) write0(clk, writenumhot[0]&write, data_in, R0);
    vDFFE #(16) write1(clk, writenumhot[1]&write, data_in, R1);
    vDFFE #(16) write2(clk, writenumhot[2]&write, data_in, R2);
    vDFFE #(16) write3(clk, writenumhot[3]&write, data_in, R3);
    vDFFE #(16) write4(clk, writenumhot[4]&write, data_in, R4);
    vDFFE #(16) write5(clk, writenumhot[5]&write, data_in, R5);
    vDFFE #(16) write6(clk, writenumhot[6]&write, data_in, R6);
    vDFFE #(16) write7(clk, writenumhot[7]&write, data_in, R7);

    //read function
    
    reg [15:0] data_out;
      always @(readnumhot, R0, R1, R2, R3, R4, R5, R6, R7) begin
	case(readnumhot)
	    8'b10000000: data_out = R7;
	    8'b01000000: data_out = R6;
	    8'b00100000: data_out = R5;
	    8'b00010000: data_out = R4;
	    8'b00001000: data_out = R3;
	    8'b00000100: data_out = R2;
	    8'b00000010: data_out = R1;
	    8'b00000001: data_out = R0;
	    default: data_out = {16{1'bx}};
	endcase
    end
endmodule
