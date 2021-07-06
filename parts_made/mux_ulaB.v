module mux_ulaA(
    input wire          selector,
    input wire          [31:0] Data_0,
    input wire          [31:0] Data_1,
    input wire          [31:0] Data_2,

    output wire          [31:0] Data_out,
);

     

    wire [31:0] A1;
    wire [31:0] A2;

    assign A1 = (selector[0]) ? 32'b00000000000000000000000000000100 : Data_0;
    assign A2 = (selector[0]) ? Data_1 : Data_2

    assign  Data_out = (selector[1]) ? A1 : A2;
    
endmodule;