module mux_Iord(
    input wire         [1:0] selector,
    input wire          [31:0] Data_0,
    input wire          [31:0] Data_1,
    input wire          [31:0] Data_2,
    output wire          [31:0] Data_out
);

    wire [31:0] A1;

    assign A1 = (selector[0]) ? Data_0 : Data_1;
    assign  Data_out = (selector[1]) ? A1 : Data_2;
    
endmodule;