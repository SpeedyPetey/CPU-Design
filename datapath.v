module datapath(clk, readnum, vsel, loada, loadb, shift, asel, bsel, ALUop, loadc, 
		loads, writenum, write, sximm8, PC, mdata, sximm5, Z_out, datapath_out);

    // I/O declarations
    input clk, loada, loadb, asel, bsel, loadc, loads, write;
    input[1:0] vsel, shift, ALUop; 
    input[2:0] readnum, writenum;
    input[7:0] PC;
    input[15:0] mdata, sximm8, sximm5;
    output[2:0] Z_out;
    output[15:0] datapath_out;

    // Internal wires
    wire[2:0] Z, Z_out;
    wire[15:0] data_out, out, sout, A, B;
    reg[15:0] Ain, Bin, data_in, datapath_out;
    
    
    // Multiplexers for data_in, Bin, Ain
    always @* begin
	case(vsel)
	    2'b00: data_in = datapath_out;
    	    2'b01: data_in = {{8{1'b0}}, PC}; 
	    2'b10: data_in = sximm8;
	    2'b11: data_in = mdata; 
	    default: data_in = {16{1'bx}};
	endcase
	case(bsel)
	    0: Bin = sout;
	    1: Bin = sximm5;
	    default: Bin = {16{1'bx}};
	endcase
	case(asel)
	    0: Ain = A;
	    1: Ain = 16'b0;
	    default: Ain = {16{1'bx}};
	endcase
    end

    // Regfile module instansiation for reading and writing
    regfile REGFILE(
	.data_in(data_in),
	.writenum(writenum),
	.write(write),
	.readnum(readnum),
	.clk(clk),
	.data_out(data_out)
    );

    // vDFFE loading for A and B
    vDFFE #(16) LOADINGA(clk, loada, data_out, A);
    vDFFE #(16) LOADINGB(clk, loadb, data_out, B);

    // Shifter module instansiation
    shifter SHIFTER(
	.in(B),
	.shift(shift),
	.sout(sout)
    );

    // ALU module instansiation
    ALU alu(
	.Ain(Ain),
	.Bin(Bin),
	.ALUop(ALUop),
	.out(out),
	.Z(Z)
    );

   
    // vDFFE module for the datapath_out
    always @(posedge clk) begin
	if (loadc == 1)
	    datapath_out = out;
        else if (loadc == 0)
	    datapath_out = datapath_out;
	else 
	    datapath_out = {16{1'b0}};
    end

    // Enabled loading of the status output
    vDFFE #(3) LOADINGZ(clk, loads, Z, Z_out);
       
endmodule


