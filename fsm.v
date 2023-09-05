// Declaration of the states of the finite state machine

`define RST 5'b00000 // Reset state

// Instruction fetch states
`define IF1 5'b00001
`define IF2 5'b00010

`define UPDATEPC 5'b00011 // Update PC state

`define DECODE 5'b00100 // Decode state

// ALU Instruction states
`define GETB 5'b00101
`define GETA 5'b00110
`define COMPUTE 5'b00111
`define COMPARE 5'b01000
`define WRITEREG 5'b01001

// Move Instruction states
`define LOADB 5'b01010
`define UPDATE 5'b01011
`define WRITEBACK 5'b01100
`define WRITEIMM 5'b01101

// Memory Instruction states
`define GETRN 5'b01110
`define COMPUTEMEM 5'b01111
`define LOADADD 5'b10000
`define STOREADD 5'b10001
`define DATABACK 5'b10010
`define DELAY 5'b10100
`define WRITEMEM 5'b10101

// Special Instruction state
`define HALT 5'b10011

module fsm(clk, reset, op, opcode, nsel, vsel, loada, 
	    loadb, asel, bsel, loadc, loads, write, load_ir, load_pc, reset_pc, addr_sel, mem_cmd, load_addr);

    // I/O declarations
    input clk, reset;
    input[1:0] op;
    input[2:0] opcode;

    // control signals sent to instruction decoder and datapath
    output loada, loadb, loadc, loads, load_ir, load_pc, load_addr, asel, bsel, addr_sel, write, reset_pc; 
    output[1:0] vsel, mem_cmd;
    output[2:0] nsel;

    reg[4:0] present_state; // Present state reg
    reg[18:0] finaloutput; // Concactenation of all outputs


    always @(posedge clk) begin

	// Resets to wait state if reset is 1
	if (reset)
	    present_state = `RST;
        else begin

	    // Decides the next state based on the current state, opcode, and op
            case(present_state) 
		`RST: present_state = `IF1; 
		`IF1: present_state = `IF2; 
		`IF2: present_state = `UPDATEPC; 
		`UPDATEPC: present_state = `DECODE; 
		`DECODE: casex({opcode, op})
				5'b111xx: present_state = `HALT;
				5'b101xx: present_state = `GETB;
				5'b11000: present_state = `LOADB;
				5'b11010: present_state = `WRITEIMM;
				5'b10000, 5'b01100: present_state = `GETRN;
				default: present_state = {5{1'bx}};
			  endcase
		`HALT: present_state = `HALT; 
		`GETB: if (op === 2'b11)
			  	present_state = `COMPUTE; 
			else
				present_state = `GETA;
		`COMPUTE: present_state = `WRITEREG;
		`GETA: if (op === 2'b01)
			  	present_state = `COMPARE; 
			else
				present_state = `COMPUTE;
		`LOADB: present_state = `UPDATE; 
		`UPDATE: present_state = `WRITEBACK; 
		`GETRN: present_state = `COMPUTEMEM; 
		`COMPUTEMEM: if (opcode === 3'b011)
				present_state = `LOADADD; 
			     else
				present_state = `STOREADD;
		`LOADADD: present_state = `DELAY; 
		`STOREADD: present_state = `WRITEMEM;
		`DELAY: present_state = `DATABACK; 
		`WRITEREG, `COMPARE, `WRITEBACK, `WRITEIMM, `DATABACK,`WRITEMEM: present_state = `IF1; 
		default: present_state = {5{1'bx}};
	    endcase
        end

        // Sets  specific output signals to 1 based on the current state of the FSM, and sets the rest to 0
	finaloutput = 19'b0;
	case(present_state)
	    `RST: {finaloutput[18], finaloutput[12]} = {2{1'b1}};
	    `IF1: {finaloutput[8], finaloutput[0]} = {2{1'b1}};
	    `IF2: {finaloutput[13], finaloutput[8], finaloutput[0]} = {3{1'b1}};
	    `UPDATEPC: {finaloutput[12]} = {1{1'b1}};
	    `DECODE: finaloutput = 19'b0;
	    `GETB: {finaloutput[16], finaloutput[5]} = {2{1'b1}};
	    `GETA: {finaloutput[17], finaloutput[3]} = {2{1'b1}};
	    `COMPUTE: {finaloutput[15]} = {1{1'b1}};
	    `COMPARE: {finaloutput[14]} = {1{1'b1}};
	    `WRITEREG: {finaloutput[4], finaloutput[2]} = {2{1'b1}};
	    `LOADB: {finaloutput[16], finaloutput[5]} = {2{1'b1}};
	    `UPDATE: {finaloutput[15], finaloutput[10]} = {2{1'b1}};
	    `WRITEBACK: {finaloutput[4], finaloutput[2]} = {2{1'b1}};
	    `WRITEIMM: {finaloutput[7], finaloutput[3], finaloutput[2]} = {3{1'b1}};
	    `GETRN: {finaloutput[17], finaloutput[3]} = {2{1'b1}};
	    `COMPUTEMEM: {finaloutput[16], finaloutput[15], finaloutput[9], finaloutput[4]} = {4{1'b1}};
	    `LOADADD: {finaloutput[11], finaloutput[0]} = {2{1'b1}};
	    `STOREADD: {finaloutput[15], finaloutput[11:10]} = {3{1'b1}};
	    `WRITEMEM: 	{finaloutput[1]} = {1{1'b1}};
	    `DATABACK: {finaloutput[7], finaloutput[6], finaloutput[4], finaloutput[2], finaloutput[0]} = {5{1'b1}};
	    `DELAY: finaloutput = 19'b0; 	
	    `HALT: finaloutput = 19'b0;
	    default: finaloutput = {19{1'bx}};
	endcase
    end

    // Assigning the concactenated output signals to the final output reg
    assign {reset_pc, loada, loadb, loadc, loads, load_ir, load_pc, load_addr, 
	    asel, bsel, addr_sel, vsel, nsel, write, mem_cmd} = finaloutput;
endmodule


