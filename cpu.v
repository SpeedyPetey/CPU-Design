module cpu(clk,reset,read_data,mem_addr,mem_cmd,datapath_out,N,V,Z); 

    // I/O declarations
    input clk, reset;
    input [15:0] read_data;
    output N, V, Z; // status flags and wait signal
    output [1:0] mem_cmd;
    output [8:0] mem_addr;
    output [15:0] datapath_out;

    // Internal wires carrying data
    wire [15:0] instruction, sximm8, sximm5, datapath_out, mdata;
    wire [2:0] opcode, rwnum, nsel, Z_out;  
    wire [1:0] op, sh, vsel, mem_cmd;
    wire loada, loadb, asel, bsel, loadc, loads, write, reset_pc, load_pc, load_ir, addr_sel, load_addr;
    wire [8:0] PC, next_pc, address;


    // Assigned value from the RAM 
    assign mdata = read_data;

    // Assigning the status register the 3 status flags
    assign {Z, N, V} = Z_out;

    // Module instansiation of the instruction load enabled register
    vDFFE #(16) LOADINGINSTR(clk,load_ir, read_data, instruction);

    // Module instansiation of the instruction decoder
    instrdecoder INSTRDEC(
	.nsel(nsel), 
	.instruction(instruction),
 	.opcode(opcode),
	.op(op), 
	.rwnum(rwnum),
	.sh(sh),
	.sximm8(sximm8),
	.sximm5(sximm5)
    );

    // Module instansiation of the finite state machine
    fsm FSM(
	.clk(clk), 
	.reset(reset), 
	.op(op), 
	.opcode(opcode), 
	.nsel(nsel),
	.vsel(vsel), 
	.loada(loada), 
	.loadb(loadb), 
	.asel(asel), 
	.bsel(bsel), 
	.loadc(loadc), 
	.loads(loads), 
	.write(write),
	.load_ir(load_ir),
	.load_pc(load_pc),
	.reset_pc(reset_pc),
	.addr_sel(addr_sel),
	.mem_cmd(mem_cmd),
	.load_addr(load_addr)
    );

    // Module instansiation of the datapath
    datapath DP(
	.clk(clk), 
	.readnum(rwnum), 
	.vsel(vsel), 
	.loada(loada), 
	.loadb(loadb), 
	.shift(sh), 
	.asel(asel), 
	.bsel(bsel), 
	.ALUop(op),
	.loadc(loadc), 
	.loads(loads), 
	.writenum(rwnum), 
	.write(write), 
	.Z_out(Z_out), 
	.datapath_out(datapath_out),
 	.sximm8(sximm8),
	.PC(PC[7:0]),
	.mdata(mdata), 
	.sximm5(sximm5)
    );

    // Updating program counter by an enabled VDFF
    vDFFE #(9) PROGRAMCOUNTER(clk, load_pc, next_pc, PC);

    // Updating the data address to read from/write to by an enabled VDFF
    vDFFE #(9) DataAddress(clk, load_addr, datapath_out[8:0], address);

    // Multiplexer for reseting the PC
    assign next_pc = reset_pc ? 9'b0 : PC + 1'b1;

    // Multiplexer for the memory address to be read from/ written to
    assign mem_addr = addr_sel ? PC : address;

endmodule
