module instrdecoder(nsel, instruction, opcode, op, rwnum, sh, sximm8, sximm5);

    // I/O declarations
    input[2:0] nsel; // gives an address to the datapath based on nsel
    input[15:0] instruction; // 16-bit instruction
    output[2:0] opcode, rwnum;
    output[1:0] op, sh;
    output[15:0] sximm8, sximm5;

    // Assigning opcode and op their respective bits
    assign opcode = instruction[15:13];
    assign op = instruction[12:11];

    // Decides which address the datapath should read/write from based on nsel
    reg[2:0] rwnum;
    always @* begin
	case(nsel)
	    3'b001: rwnum = instruction[10:8]; //rn
	    3'b010: rwnum = instruction[7:5]; //rd
	    3'b100: rwnum = instruction[2:0]; //rm
	    default: rwnum = {3{1'bx}};
	endcase
    end

    assign sh = instruction[4:3]; // Assigning the shift its respective bits

    // Sign extending given constants
    assign sximm8 = instruction[7]? {{8{1'b1}}, instruction[7:0]}:{{8{1'b0}}, instruction[7:0]};
    assign sximm5 = instruction[4]? {{11{1'b1}}, instruction[4:0]}:{{11{1'b0}}, instruction[4:0]};

endmodule


