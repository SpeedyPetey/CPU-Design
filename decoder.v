module Dec(a, b);
    parameter n = 3;
    parameter m = 8;
    
    // I/O declarations
    input [n-1:0] a;
    output [m-1:0] b;
    
    //Decoder function
    wire [m-1:0] b = 1 << a;

endmodule 