module mux_writeRegister(
    input wire           [1:0] selector,
    input wire           [4:0] input_one,
    input wire           [15:0] offset,
    input wire           [4:0] input_three,
    output wire          [4:0] Data_out
);

    // fios internos
    wire [4:0] A1;
    wire [4:0] A2;
    wire [4:0] input_two;

    assign input_two = offset[15:11];

    assign A1 = (selector[0]) ? input_two : input_one;
    assign A2 = (selector[0]) ? 5'b11111 : input_three; // 5'b11111 eh ra
    assign  Data_out = (selector[1]) ? A2 : A1;
    
endmodule;