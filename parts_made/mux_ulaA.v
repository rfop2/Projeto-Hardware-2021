module mux_ulaA(
    input wire          [1:0]selector,
    input wire          [31:0] Data_0,
    input wire          [31:0] Data_1,
    input wire          [31:0] Data_2,
    input wire          [31:0] Data_3,
    output wire          [31:0] Data_out
);

    wire [31:0] aux_1;
    wire [31:0] aux_2;
    
    assign aux_1 = (selector[0]) ? Data_1 : Data_0;
    assign aux_2 = (selector[0]) ? Data_3 : Data_2;
    assign  Data_out = (selector[1]) ? aux_2 : aux_1;
    
endmodule;