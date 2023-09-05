module ALU(Ain, Bin, ALUop, out, Z);

    // I/O declarations
    input[15:0] Ain, Bin;
    input[1:0] ALUop;
    output[15:0] out;
    output[2:0] Z;

    reg[15:0] out;
    wire ovf;
    wire[15:0] s;

    // Module instansiation for the addition/subtractor module
    AddSub #(16) addersubber(Ain, Bin, ALUop[0], s, ovf);
	
    // ALU computation
    always @* begin
	casex(ALUop)
	    2'b0x: out = s;
	    2'b10: out = Ain & Bin;
	    2'b11: out = ~Bin;
	    default: out = {16{1'bx}};
	endcase 
    end

    // Assignment of status flags
    assign Z = {|out?1'b0:1'b1, out[15]?1'b1:1'b0, ovf};

endmodule



