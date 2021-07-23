module mux_Exception(
    input wire         [1:0] selector,
    output wire          [31:0] Data_out
);

    wire [31:0] A1;

    assign A1 = (selector[0]) ? 32'b000000000000000000000000011111101 : 32'b000000000000000000000000011111110;
    assign  Data_out = (selector[1]) ? A1 : 32'b000000000000000000000000011111111 ;
    
endmodule;