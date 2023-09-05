module Adder1(a,b,cin,cout,s) ;
    parameter n = 8 ;

    // I/O declarations
    input [n-1:0] a, b ;
    input cin ;
    output [n-1:0] s ;
    output cout ;

    wire [n-1:0] s;
    wire cout ;
    
    // Assignment of the addition with the carry in
    assign {cout, s} = a + b + cin ;

endmodule 