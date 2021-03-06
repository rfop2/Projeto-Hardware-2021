module mux_PCSource(
    input wire          [2:0] selector,
    input wire          [31:0] Data_0,
    input wire          [31:0] Data_1,
    input wire          [31:0] Data_2,
    input wire          [31:0] Data_3,
    input wire          [31:0] Data_4,
    output wire          [31:0] Data_out
);

    wire [31:0] A1;
    wire [31:0] A2;
    wire [31:0] A3;

    assign A1 = (selector[0]) ? Data_1 : Data_0;
    assign A2 = (selector[0]) ? Data_3 : Data_2;
    assign A3 = (selector[1]) ? A2 : A1;
    assign  Data_out = (selector[2]) ? Data_4 : A3;
    
endmodule;