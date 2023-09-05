// Memory commands available 
`define MNONE 2'b00
`define MREAD 2'b01
`define MWRITE 2'b10

module lab7_top(KEY,SW,LEDR,HEX0,HEX1,HEX2,HEX3,HEX4,HEX5);

    // I/O declarations
    input [3:0] KEY;
    input [9:0] SW;
    output [9:0] LEDR;
    output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;

    // Internal wires carrying control signals and calculated outputs
    wire [1:0] mem_cmd;
    wire [8:0] mem_addr;
    wire [15:0] read_data, dout, write_data;
    wire msel, readcheck, writecheck, write, N, V, Z, enabler, loadLEDS, enable;
    wire [9:0] LEDR;
    wire [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5; 


    // Module instansiation of the RAM
    RAM #(16, 8) MEM(
	.clk(~KEY[0]),
	.read_address(mem_addr[7:0]),
	.write_address(mem_addr[7:0]),
	.write(write),
	.din(write_data),
	.dout(dout)
    );

    // Module instansiation of the CPU
    cpu CPU(
	.clk(~KEY[0]),
	.reset(~KEY[1]),
	.read_data(read_data),
	.mem_addr(mem_addr),
	.mem_cmd(mem_cmd),
	.datapath_out(write_data),
	.N(N),
	.V(V),
	.Z(Z)
    );
    
    // Determining msel based of the MSB of mem_addr
    assign msel = ~mem_addr[8];

    // Reading and writing to RAM checks 
    assign readcheck = (mem_cmd===`MREAD) ? 1'b1 : 1'b0;
    assign writecheck = (mem_cmd===`MWRITE) ? 1'b1 : 1'b0; 

    // Determining of control signal for if we are writing to the RAM
    assign write = msel & writecheck;

    // Assignment of the enable for the RAM output tri state driver
    assign enable = msel & readcheck;

    // Tri state driver for the RAM output
    assign read_data = enable ? dout : {16{1'bz}};

    // Assignment of the enable for the tri state driver for read_data to go to mdata
    assign enabler = ((mem_cmd === `MREAD) & (mem_addr === 9'b101000000));

    // Assignment of read_data/mdata by tri state drivers
    assign read_data[15:8] = enabler ? 8'h00 : {8{1'bz}};
    assign read_data[7:0] = enabler ? SW[7:0] : {8{1'bz}};

    // Assignment of the LED VDFFE load enable
    assign loadLEDS = ((mem_cmd === `MWRITE) & (mem_addr === 9'b100000000));

    // Module instansiation for the LEDS taking the value of what is being stored into them
    vDFFE #(8) LEDS(~KEY[0], loadLEDS, write_data[7:0], LEDR[7:0]);


  // Assignment of status flags
  assign HEX5[0] = ~Z;
  assign HEX5[6] = ~N;
  assign HEX5[3] = ~V;

  // Assignment of HEXes with the datapath_out value
  sseg H0(write_data[3:0],   HEX0);
  sseg H1(write_data[7:4],   HEX1);
  sseg H2(write_data[11:8],  HEX2);
  sseg H3(write_data[15:12], HEX3);
  assign HEX4 = 7'b1111111; // disabled
  assign {HEX5[2:1],HEX5[5:4]} = 4'b1111; // disabled

endmodule

// Module for determining the output on the HEX 
module sseg(in,segs);

  // I/O declarations
  input [3:0] in;
  output [6:0] segs;
  reg[6:0] segs;

  // Determination of output based on input
  always @(in) begin
    case (in)
	0: segs = 7'b1000000;
	1: segs = 7'b1001111;
	2: segs = 7'b0100100;
	3: segs = 7'b0110000;
	4: segs = 7'b0011001;
	5: segs = 7'b0010010;
	6: segs = 7'b0000010;
	7: segs = 7'b1111000;
	8: segs = 7'b0000000;
	9: segs = 7'b0011000;
	10: segs = 7'b0001000;
	11: segs = 7'b0000011;
	12: segs = 7'b1000110;
	13: segs = 7'b0100001;
	14: segs = 7'b0000110;
	15: segs = 7'b0001110;
	default: segs = 7'b1000000;
    endcase
  end
endmodule
   