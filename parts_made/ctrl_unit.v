module ctrl_unit (
    input wire clk,
    input wire reset,

    //ULA
    input wire       Overflow,
    input wire       NG,
    input wire       ZR,
    input wire       EQ,
    input wire       GT,
    input wire       LT,

    
    input wire       ErroDiv,

    // Instrucoes Especias
    input wire [5:0] OPCODE,
    input wire [15:0] OFFSET,

    // Controle
    output reg   PCwrite,
    output reg   MemWrite,
    output reg   IRWrite,
    output reg   BRWrite,
    output reg   ABWrite,
    output reg   EPCWrite,
    output reg   HIWrite,
    output reg   LOWrite,
    output reg   MDRWrite,
    output reg   ALUOutWrite,

    // Controle com 2 bits
    output reg [2:0] ALUOp,
    output reg [2:0] ShiftCtrl,
    

    // Controle mux
    output reg       MultOrDiv,
    output reg       HiOrLow,
    output reg       Shiftln,
    output reg [1:0] IorD,
    output reg [1:0] RegDst,
    output reg [1:0] ALUSrcA,
    output reg [1:0] ALUSrcB,
    output reg [1:0] ShiftAmt,
    output reg [1:0] Exception,
    output reg [2:0] MemToReg,
    output reg [2:0] PCSource,

    // reset
    output reg       rst_out
);

    // variaveis para estado e contador para qntd de numeros de vza que o estado vai acontencer
    reg [5:0] STATE;
    reg [2:0] COUNTER;

    wire [5:0] FUNCT = OFFSET[5:0];

    // states
    parameter ST_RESET     = 6'b000000;
    parameter ST_COMMON    = 6'b000001;
    parameter ST_ADD       = 6'b000010;
    parameter ST_ADDI      = 6'b000011;
    parameter ST_SUB       = 6'b000100;
    parameter ST_BEQ       = 6'b000111;
    parameter ST_BNE       = 6'b001000;
    parameter ST_BLE       = 6'b001001;
    parameter ST_BGT       = 6'b001010;
    parameter ST_AND       = 6'b001011;
    parameter ST_DIV       = 6'b001100;
    parameter ST_MULT      = 6'b001101;
    parameter ST_BREAK     = 6'b001111;
    parameter ST_RTE       = 6'b010000;
    parameter ST_JR        = 6'b010001;
    parameter ST_SLL       = 6'b010010;
    parameter ST_SLLV      = 6'b010011;
    parameter ST_SRA       = 6'b010100;
    parameter ST_SRAV      = 6'b010101;
    parameter ST_SRL       = 6'b010110;
    parameter ST_SLT       = 6'b010111;
    parameter ST_SLTI      = 6'b011000;
    parameter ST_ADDM      = 6'b011001;
    parameter ST_MFHI      = 6'b011010;
    parameter ST_MFLO      = 6'b011011;
    parameter ST_JUMP      = 6'b011100;
    parameter ST_JAL       = 6'b011101;
    parameter ST_LW        = 6'b011110;
    parameter ST_SW        = 6'b011111;
    parameter ST_OPCODE_EX = 6'b100000;
    parameter ST_ADDIU    =  6'b100001; 

    // opcodes aliases 
    parameter NULL  =   6'b000000;
    parameter BLM   =   6'b000001;
    parameter J     =   6'b000010;
    parameter JAL   =   6'b000011;
    parameter BEQ   =   6'b000100;
    parameter BNE   =   6'b000101;
    parameter BLE   =   6'b000110;
    parameter BGT   =   6'b000111;
    parameter ADDI  =   6'b001000;
    parameter ADDIU =   6'b001001;
    parameter SLTI  =   6'b001010;
    parameter LUI   =   6'b010000;
    parameter LB    =   6'b100000;
    parameter LH    =   6'b100001;
    parameter LW    =   6'b100011;
    parameter SB    =   6'b101000;
    parameter SW    =   6'b101011;

    // functions aliases
    parameter SLL   =   6'b000000;
    parameter SRL   =   6'b000010;
    parameter SRA   =   6'b000011;
    parameter SLLV  =   6'b000100;
    parameter ADDM  =   6'b000101;
    parameter SRAV  =   6'b000111;
    parameter JR    =   6'b001000;
    parameter BREAK =   6'b001011;
    parameter MFHI  =   6'b010000;
    parameter MFLO  =   6'b010010;
    parameter RTE   =   6'b010011;
    parameter MULT  =   6'b011000;
    parameter DIV   =   6'b011010;
    parameter ADD   =   6'b100000;
    parameter SUB   =   6'b100010;
    parameter AND   =   6'b100100;
    parameter SLT   =   6'b101010;

    // reset inicial na maquina
    initial begin
        rst_out = 1'b1;
    end

always @(posedge clk) begin
    if(reset == 1'b1) begin
        if(STATE != ST_RESET) begin
            STATE = ST_RESET;
            // modo de escrita
            PCwrite =  1'b0;
            MemWrite =  1'b0;
            IRWrite =  1'b0;
            BRWrite =  1'b0;
            ABWrite =  1'b0;
            EPCWrite =  1'b0;
            HIWrite =  1'b0;
            LOWrite =  1'b0;
            MDRWrite =  1'b0;
            ALUOutWrite =  1'b0;
            ALUOp = 3'b000;
            ShiftCtrl = 2'b00;
            MultOrDiv = 1'b0;
            HiOrLow = 1'b0;
            Shiftln = 1'b0;
            IorD = 2'b00;
            RegDst = 2'b00;
            ALUSrcA = 2'b00;
            ALUSrcB = 2'b00;
            ShiftAmt = 2'b00;
            Exception = 2'b00;
            MemToReg = 3'b000;
            PCSource = 3'b000;
            rst_out = 1'b1; // aperta o botao de reset
            // set contador para prox operacao
            COUNTER = 3'b000;
        end
        else begin
            // supando que todos foram resetadas
            STATE = ST_COMMON;
            PCwrite =  1'b0;
            MemWrite =  1'b0;
            IRWrite =  1'b0;
            BRWrite =  1'b0;
            ABWrite =  1'b0;
            EPCWrite =  1'b0;
            HIWrite =  1'b0;
            LOWrite =  1'b0;
            MDRWrite =  1'b0;
            ALUOutWrite =  1'b0;
            ALUOp = 3'b000;
            ShiftCtrl = 2'b00;
            MultOrDiv = 1'b0;
            HiOrLow = 1'b0;
            Shiftln = 1'b0;
            IorD = 2'b00;
            RegDst = 2'b00;
            ALUSrcA = 2'b00;
            ALUSrcB = 2'b00;
            ShiftAmt = 2'b00;
            Exception = 2'b00;
            MemToReg = 3'b000;
            PCSource = 3'b000;
            rst_out = 1'b0;  // muda para 0
            // contador para prox operacao
            COUNTER = 3'b000;
        end
    end
    else begin
        case (STATE)
            ST_COMMON: begin
                if (COUNTER == 3'b000 || COUNTER == 3'b001 || COUNTER == 3'b010) begin
                    STATE = ST_COMMON;
                    // 3 ciclos -> lendo memoria e calculando pc + 4
                    PCwrite =  1'b0;
                    MemWrite =  1'b0; ///
                    IRWrite =  1'b0;
                    BRWrite =  1'b0;
                    ABWrite =  1'b0;
                    EPCWrite =  1'b0;
                    HIWrite =  1'b0;
                    LOWrite =  1'b0;
                    MDRWrite =  1'b0;
                    ALUOutWrite =  1'b1;
                    ALUOp = 3'b001; /// soma
                    ShiftCtrl = 2'b00;
                    MultOrDiv = 1'b0;
                    HiOrLow = 1'b0;
                    Shiftln = 1'b0;
                    IorD = 2'b00;
                    RegDst = 2'b00;
                    ALUSrcA = 2'b00;  /// pc
                    ALUSrcB = 2'b001;  /// 4
                    ShiftAmt = 2'b00;
                    Exception = 2'b00;
                    MemToReg = 3'b000;
                    PCSource = 3'b001; /// saida do AluResult
                    rst_out = 1'b0;  
                    // incrementa 
                    COUNTER = COUNTER + 1;
                end
                else if (COUNTER == 3'b011) begin 
                    STATE = ST_COMMON;
                    // 1 ciclo -> escrevendo em PC e IR o pc + 4 e saida da memoria respectivamente
                    PCwrite =  1'b1; // write pc
                    MemWrite =  1'b0; 
                    IRWrite =  1'b1; // write IR
                    BRWrite =  1'b0;
                    ABWrite =  1'b0;
                    EPCWrite =  1'b0;
                    HIWrite =  1'b0;
                    LOWrite =  1'b0;
                    MDRWrite =  1'b0;
                    ALUOutWrite =  1'b1;
                    ALUOp = 3'b000; 
                    ShiftCtrl = 2'b00;
                    MultOrDiv = 1'b0;
                    HiOrLow = 1'b0;
                    Shiftln = 1'b0;
                    IorD = 2'b00;
                    RegDst = 2'b00;
                    ALUSrcA = 2'b00;  
                    ALUSrcB = 2'b000;  
                    ShiftAmt = 2'b00;
                    Exception = 2'b00;
                    MemToReg = 3'b000;
                    PCSource = 3'b010;  
                    rst_out = 1'b0;  
                    // incrementa 
                    COUNTER = COUNTER + 1;
                end
                else if (COUNTER == 3'b100) begin
                     STATE = ST_COMMON;
                     // 1 ciclo -> de acordo com dados do IR vamos buscar registradores no BR e escrever em A e B
                     // monitor disse que era um único ciclo
                     PCwrite =  1'b0; 
                     MemWrite =  1'b0;
                     IRWrite =  1'b0; 
                     BRWrite =  1'b0;
                     ABWrite =  1'b1; // escrita em AB
                     EPCWrite =  1'b0;
                     HIWrite =  1'b0;
                     LOWrite =  1'b0;
                     MDRWrite =  1'b0;
                     ALUOutWrite =  1'b0;
                     ALUOp = 3'b000;
                     ShiftCtrl = 2'b00;
                     MultOrDiv = 1'b0;
                     HiOrLow = 1'b0;
                     Shiftln = 1'b0;
                     IorD = 2'b00;
                     RegDst = 2'b00;
                     ALUSrcA = 2'b00;
                     ALUSrcB = 2'b00;
                     ShiftAmt = 2'b00;
                     Exception = 2'b00;
                     MemToReg = 3'b000;
                     PCSource = 3'b000;

                     rst_out = 1'b0; 
                     COUNTER = COUNTER + 1;
                end
                else if (COUNTER == 3'b101) begin
                    case (OPCODE)
                        NULL: begin
                            case (FUNCT)
                                ADD: begin
                                    STATE = ST_ADD;
                                end
                                SUB: begin
                                    STATE = ST_SUB;
                                end
                                AND: begin
                                    STATE = ST_AND;
                                end
                                MULT: begin
                                    STATE = ST_MULT;
                                end
                                DIV: begin
                                    STATE = ST_DIV;
                                end
                                BREAK: begin
                                    STATE = ST_BREAK;
                                end
                                RTE: begin
                                    STATE = ST_RTE;
                                end
                                JR: begin
                                    STATE = ST_JR;
                                end
                                SLL: begin
                                    STATE = ST_SLL;
                                end
                                SLLV: begin
                                    STATE = ST_SLLV;
                                end
                                SRA: begin
                                    STATE = ST_SRA;
                                end
                                SRAV: begin
                                    STATE = SRAV;
                                end
                                SRL: begin
                                    STATE = ST_SRL;
                                end
                                SLT: begin
                                    STATE = ST_SLT;
                                end
                                MFHI: begin
                                    STATE = ST_MFHI;
                                end
                                MFLO: begin
                                    STATE = ST_MFLO;
                                end
                                ADDM: begin
                                    STATE = ST_ADDM;
                                end
                            endcase
                    end
                    ADDI: begin
                        STATE = ST_ADDI;
                    end
                    ADDIU: begin
                        STATE = ST_ADDIU;
                    end
                    BEQ: begin
                        STATE = ST_BEQ;
                    end
                    BNE: begin
                        STATE = ST_BNE;
                    end
                    BLE: begin
                        STATE = ST_BLE;
                    end
                    BGT: begin
                        STATE = ST_BGT;
                    end
                    LW: begin
                        STATE = ST_LW;
                    end
                    SW: begin
                        STATE = ST_SW;
                    end
                    J: begin
                        STATE = ST_JUMP;
                    end
                    JAL: begin
                        STATE = ST_JAL;
                    end
                    SLTI: begin
                        STATE = ST_SLTI;
                    end
                    default: begin
                        STATE = ST_OPCODE_EX;
                    end  
                  endcase
                  // setting all signals
                  PCwrite =  1'b0; 
                  MemWrite =  1'b0;
                  IRWrite =  1'b0; 
                  BRWrite =  1'b0;
                  ABWrite =  1'b0;
                  EPCWrite =  1'b0;
                  HIWrite =  1'b0;
                  LOWrite =  1'b0;
                  MDRWrite =  1'b0;
                  ALUOutWrite =  1'b0;
                  ALUOp = 3'b000;
                  ShiftCtrl = 2'b00;
                  MultOrDiv = 1'b0;
                  HiOrLow = 1'b0;
                  Shiftln = 1'b0;
                  IorD = 2'b00;
                  RegDst = 2'b00;
                  ALUSrcA = 2'b00;
                  ALUSrcB = 2'b00;
                  ShiftAmt = 2'b00;
                  Exception = 2'b00;
                  MemToReg = 3'b000;
                  PCSource = 3'b000;

                  rst_out = 1'b0; 
                  COUNTER = 3'b000;
                end
            end
            //COMEÇA A FAZER O ADD
            ST_ADD: begin
                if (COUNTER == 3'b000) begin
                    // Setting future state
                    STATE = ST_ADD;
                    // Setting all signals
                    PCwrite =  1'b0;
                    MemWrite =  1'b0; 
                    IRWrite =  1'b0;
                    BRWrite =  1'b0;
                    ABWrite =  1'b0;
                    EPCWrite =  1'b0;
                    HIWrite =  1'b0;
                    LOWrite =  1'b0;
                    MDRWrite =  1'b0;
                    ALUOutWrite =  1'b1; /// Write no ALUOut
                    ALUOp = 3'b001; /// +
                    ShiftCtrl = 2'b00;
                    MultOrDiv = 1'b0;
                    HiOrLow = 1'b0;
                    Shiftln = 1'b0;
                    IorD = 2'b00;
                    RegDst = 2'b00;
                    ALUSrcA = 2'b01; /// A
                    ALUSrcB = 2'b00; /// B
                    ShiftAmt = 2'b00;
                    Exception = 2'b00;
                    MemToReg = 3'b000;
                    PCSource = 3'b000;

                    rst_out = 1'b0;
                    COUNTER = COUNTER + 1;
                end
                else if (COUNTER == 3'b001) begin
                    // Setting future state
                    STATE = ST_ADD;
                    // Setting all signals
                    PCwrite =  1'b0;
                    MemWrite =  1'b0; 
                    IRWrite =  1'b0;
                    BRWrite =  1'b1; // escrever no Banco de Registradores
                    ABWrite =  1'b0;
                    EPCWrite =  1'b0;
                    HIWrite =  1'b0;
                    LOWrite =  1'b0;
                    MDRWrite =  1'b0;
                    ALUOutWrite =  1'b0;
                    ALUOp = 3'b000;
                    ShiftCtrl = 2'b00;
                    MultOrDiv = 1'b0;
                    HiOrLow = 1'b0;
                    Shiftln = 1'b0;
                    IorD = 2'b00;
                    RegDst = 2'b01; // rd
                    ALUSrcA = 2'b00;
                    ALUSrcB = 2'b00;
                    ShiftAmt = 2'b00;
                    Exception = 2'b00;
                    MemToReg = 3'b000; /// ALUOut
                    PCSource = 3'b000;

                    rst_out = 1'b0;
                    COUNTER = COUNTER + 1;
                end
                else if (COUNTER == 3'b010) begin
                    // Setting future state
                    STATE = ST_COMMON;
                    // Setting all signals
                    PCwrite =  1'b0;
                    MemWrite =  1'b0; 
                    IRWrite =  1'b0;
                    BRWrite =  1'b0;
                    ABWrite =  1'b0;
                    EPCWrite =  1'b0;
                    HIWrite =  1'b0;
                    LOWrite =  1'b0;
                    MDRWrite =  1'b0;
                    ALUOutWrite =  1'b0;
                    ALUOp = 3'b000;
                    ShiftCtrl = 2'b00;
                    MultOrDiv = 1'b0;
                    HiOrLow = 1'b0;
                    Shiftln = 1'b0;
                    IorD = 2'b00;
                    RegDst = 2'b00; 
                    ALUSrcA = 2'b00;
                    ALUSrcB = 2'b00;
                    ShiftAmt = 2'b00;
                    Exception = 2'b00;
                    MemToReg = 3'b000; 
                    PCSource = 3'b000;

                    rst_out = 1'b0;
                    COUNTER = 3'b000;
                end
            end
            //COMEÇA A FAZER O ADDI
            ST_ADDI: begin
                if (COUNTER == 3'b000) begin
                    STATE = ST_ADDI;
                    // 1 ciclos -> realizar soma e escrever em ALUOut
                    PCwrite =  1'b0;
                    MemWrite =  1'b0; 
                    IRWrite =  1'b0;
                    BRWrite =  1'b0;
                    ABWrite =  1'b0;
                    EPCWrite =  1'b0;
                    HIWrite =  1'b0;
                    LOWrite =  1'b0;
                    MDRWrite =  1'b0;
                    ALUOutWrite =  1'b1; /// Write no ALUOut
                    ALUOp = 3'b001; /// +
                    ShiftCtrl = 2'b00;
                    MultOrDiv = 1'b0;
                    HiOrLow = 1'b0;
                    Shiftln = 1'b0;
                    IorD = 2'b00;
                    RegDst = 2'b00;
                    ALUSrcA = 2'b01; /// A
                    ALUSrcB = 2'b10; /// OFFSET
                    ShiftAmt = 2'b00;
                    Exception = 2'b00;
                    MemToReg = 3'b000;
                    PCSource = 3'b000;

                    rst_out = 1'b0;
                    COUNTER = COUNTER + 1;
                end
                else if (COUNTER == 3'b001) begin
                    STATE = ST_ADDI;
                    // 1 ciclos -> escrever resultado da soma no banco de registradores
                    PCwrite =  1'b0;
                    MemWrite =  1'b0; 
                    IRWrite =  1'b0;
                    BRWrite =  1'b1; // escrever no Banco de Registradores
                    ABWrite =  1'b0;
                    EPCWrite =  1'b0;
                    HIWrite =  1'b0;
                    LOWrite =  1'b0;
                    MDRWrite =  1'b0;
                    ALUOutWrite =  1'b0;
                    ALUOp = 3'b000;
                    ShiftCtrl = 2'b00;
                    MultOrDiv = 1'b0;
                    HiOrLow = 1'b0;
                    Shiftln = 1'b0;
                    IorD = 2'b00;
                    RegDst = 2'b00; // rt
                    ALUSrcA = 2'b00;
                    ALUSrcB = 2'b00;
                    ShiftAmt = 2'b00;
                    Exception = 2'b00;
                    MemToReg = 3'b000; /// ALUOut
                    PCSource = 3'b000;

                    rst_out = 1'b0;
                    COUNTER = COUNTER + 1;
                end
                else if (COUNTER == 3'b010) begin 
                    STATE = ST_COMMON;
                    PCwrite =  1'b0;
                    MemWrite =  1'b0; 
                    IRWrite =  1'b0;
                    BRWrite =  1'b0;
                    ABWrite =  1'b0;
                    EPCWrite =  1'b0;
                    HIWrite =  1'b0;
                    LOWrite =  1'b0;
                    MDRWrite =  1'b0;
                    ALUOutWrite =  1'b0;
                    ALUOp = 3'b000;
                    ShiftCtrl = 2'b00;
                    MultOrDiv = 1'b0;
                    HiOrLow = 1'b0;
                    Shiftln = 1'b0;
                    IorD = 2'b00;
                    RegDst = 2'b00; 
                    ALUSrcA = 2'b00;
                    ALUSrcB = 2'b00;
                    ShiftAmt = 2'b00;
                    Exception = 2'b00;
                    MemToReg = 3'b000; 
                    PCSource = 3'b000;

                    rst_out = 1'b0;
                    COUNTER = 3'b000;
                end
            end 
        endcase
    end
end

    
endmodule