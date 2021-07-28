module mux_ulaB(
    input wire         [1:0] selector,
    input wire          [31:0] Data_0,  // 10
    input wire          [31:0] Data_1, // 01
    input wire          [31:0] Data_2, // 00
    output wire          [31:0] Data_out
);

     

    wire [31:0] A1;
    wire [31:0] A2;

    assign A1 = (selector[0]) ? 32'b00000000000000000000000000000100 : Data_0; // numero 4(11) - Data_ 0 (10)
    assign A2 = (selector[0]) ? Data_1 : Data_2; // Data_ 1 (01) - Data_2 (00)

    assign  Data_out = (selector[1]) ? A1 : A2;
    
endmodule;