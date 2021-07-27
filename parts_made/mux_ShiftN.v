module ShiftN(
    input wire         [1:0] selector,
    input wire          [15:0] offset,
    input wire          [31:0] b,
    output wire          [4:0] Data_out
);

    // fios internos
    wire [31:0] input_one;
    wire [31:0] input_two;
    wire [4:0] A1;


    assign input_one = offset[10:6];
    assign input_two = b[4:0];

    assign A1 = (selector[0]) ? input_two : input_one;
    assign  Data_out = (selector[1]) ? A1 : 5'b10000;
    
endmodule;