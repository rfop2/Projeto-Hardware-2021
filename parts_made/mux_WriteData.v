module mux_WriteData(
    input wire          [1:0] selector,
    input wire          [31:0] Data_0,
    input wire          [31:0] Data_1,
    input wire          [31:0] Data_2,
    output wire          [31:0] Data_out
);

    wire [31:0] A1;
    wire [31:0] A2;

    assign A1 = (selector[0]) ?  Data_1 : Data_0;
    assign Data_out = (selector[1]) ?  Data_2 : A1;
    
endmodule;