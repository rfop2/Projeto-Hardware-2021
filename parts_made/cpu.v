module cpu (
    input wire clk,
    input wire reset
);
    // Control wires
    wire PC_w;
    wire MEM_w;
    wire IR_w;
    wire BR_w;
    wire AB_w;
    wire EPC_w;
    wire MDR_w;
    wire ALUOut_w;
    wire [2:0] ALU_op;
    wire [1:0] M_SrcA;
    wire [1:0] M_SrcB;
    wire [1:0] M_EXCEPTION;
    wire [1:0] M_IorD;
    wire [1:0] M_WRITE_REG;
    wire [2:0] M_WRITE_DATA;
    wire [2:0] M_PCSource;

    // Data wires
    wire [31:0] PC_input;
    wire [31:0] PC_out;
    wire [31:0] EPC_out;
    wire [31:0] M_EXCEPTION_out;
    wire [31:0] IR_input;
    wire [31:0] MDR_out;
    wire [5:0] OPCODE;
    wire [4:0] RS;
    wire [4:0] RT;
    wire [15:0] OFFSET;
    wire [31:0] SE_16_32_out;
    wire [31:0] SE_1_32_out;
    wire [31:0] SL_32_out;
    wire [31:0] M_IorD_out;
    wire [4:0] WriteReg_input;
    wire [31:0] WriteData_input;
    wire [31:0] BR_A_out;
    wire [31:0] BR_B_out;
    wire [31:0] A_out;
    wire [31:0] B_out;
    wire [31:0] ALU_A_input;
    wire [31:0] ALU_B_input;
    wire [31:0] ALU_out;
    wire [31:0] ALUOut_out;
    wire [25:0] jump_wire;
    wire [31:0] jump_out;
    wire O;
    wire N;
    wire Z;
    wire EQ;
    wire LT;
    wire GT;

    Registrador PC_(
        clk,
        reset,
        PC_w,
        PC_input,
        PC_out
    );

    instruction_25 Instruction_25_(
        OFFSET,
        RS,
        RT,
        jump_wire
    );

    calc_Jump Jump_(
        PC_out,
        jump_wire,
        jump_out
    );

    mux_PCSource M_PCSource_(
        M_PCSource,
        EPC_out,
        ALU_out,
        ALUOut_out,
        jump_out,
        M_EXCEPTION_out,
        PC_input
    );

    Registrador B_(
        clk,
        reset,
        AB_w,
        BR_B_out,
        B_out
    );

    Registrador A_(
        clk,
        reset,
        AB_w,
        BR_A_out,
        A_out
    );


    Registrador EPC_(
        clk,
        reset,
        EPC_w,
        PC_input,
        EPC_out
    );

    Registrador ALUOut_(
        clk,
        reset,
        ALUOut_w,
        ALU_out,
        ALUOut_out
    );

    Registrador MDR_(
        clk,
        reset,
        MDR_w,
        IR_input,
        MDR_out
    );

    Memoria MEM_(
        M_IorD_out,
        clk,
        MEM_w,
        B_out,
        IR_input
    );

    Instr_Reg IR_(
        clk,
        reset,
        IR_w,
        IR_input,
        OPCODE,
        RS,
        RT,
        OFFSET
    );

    sign_extend_16_32 SE_16_32_(
        OFFSET,
        SE_16_32_out
    );

   
    shift_left2_32 SL_32 (
        SE_16_32_out,
        SL_32_out
    );

    ula32 ALU_(
        ALU_A_input,
        ALU_B_input,
        ALU_op,
        ALU_out, // resultado da operacao
        O, //Overflow
        N, //Negativo
        Z, // quando S for zero 
        EQ, // igual
        LT, // menor que
        GT // maior que 
    );

    mux_Exception M_EXCEPTION_(
        M_EXCEPTION,
        M_EXCEPTION_out
    );

    mux_Iord M_Iord_(
        M_IorD,
        PC_out,
        ALU_out,
        M_EXCEPTION_out,
        M_IorD_out
    );
    
    mux_ulaA M_ALUA_(
        M_SrcA,
        PC_out,
        A_out,
        B_out,
        MDR_out,
        ALU_A_input
    );

    mux_ulaB M_ALUB_(
        M_SrcB,
        B_out,
        SE_16_32_out,
        SL_32_out,
        ALU_B_input
    );


    mux_writeRegister M_Write_Register_(
        M_WRITE_REG,
        RT,
        OFFSET,
        RS,
        WriteReg_input
    );

    mux_WriteData M_Write_Data_(
        M_WRITE_DATA,
        ALUOut_out,
        MDR_out,
        SE_1_32_out,
        WriteData_input
    );

    Banco_reg BR_(
        clk,
        reset,
        BR_w,
        RS,
        RT,
        WriteReg_input,
        WriteData_input,
        BR_A_out,
        BR_B_out
    );

    ctrl_unit CTRL_(
        clk,
        reset,
        O, // overflow
        N, // negative
        Z, // zero??
        EQ, // equal
        LT, // menor que
        GT, // maior que
        OPCODE,
        OFFSET,
        PC_w,
        MEM_w,
        IR_w,
        BR_w,
        AB_w,
        EPC_w,
        MDR_w,
        ALUOut_w,
        ALU_op,
        M_IorD,
        M_WRITE_REG,
        M_SrcA,
        M_SrcB,
        M_EXCEPTION,
        M_WRITE_DATA,
        M_PCSource,
        reset
    );

    
endmodule