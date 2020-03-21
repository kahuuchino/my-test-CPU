`include "precompiled.v"

module ex(
    input wire rst,

    //译码得到的信息
    input wire[`AluOpBus]   aluop_i,
    input wire[`AluSelBus]  alusel_i,
    input wire[`RegBus]     reg1_i,
    input wire[`RegBus]     reg2_i,
    input wire[`RegAddrBus] wd_i,
    input wire              wreg_i,

    //执行的结果
    output reg[`RegAddrBus] wd_o,
    output reg              wreg_o,
    output reg[`RegBus]     wdata_o
);

    //保存逻辑运算的结果
    reg[`RegBus] logicout;
    //保存移位运算的结果
    reg[`RegBus] shiftres;

//根据aluop_i进行运算
    always @ (*) begin
        if (rst == `RstEnable) begin
            logicout <= `ZeroWord;
        end else begin
            case (aluop_i)
                `EXE_OR_OP:     begin
                    logicout <= reg1_i | reg2_i;
                end
                `EXE_AND_OP:    begin
                    logicout <= reg1_i & reg2_i;
                end
                `EXE_XOR_OP:    begin
                    logicout <= reg1_i ^ reg2_i;
                end
                `EXE_NOR_OP:    begin
                    logicout <= ~(reg1_i | reg2_i);
                end
                default:    begin
                    logicout <= `ZeroWord;
                end
            endcase
        end
    end

    always @ (*) begin
        if (rst == `RstEnable) begin
            shiftres <= `ZeroWord;
        end else begin
            case (aluop_i)
                `EXE_SLL_OP:    begin
                    shiftres <= reg2_i << reg1_i[4:0];
                end 
                `EXE_SRL_OP:    begin
                    shiftres <= reg2_i >> reg1_i[4:0];
                end 
                `EXE_SRA_OP:    begin   //算术右移
                    shiftres <= ({32{reg2_i[31]}} << (6'd32-{1'b0, reg1_i[4:0]}))
                                                | reg2_i >> reg1_i[4:0];                end 
                default:    begin
                    shiftres <= `ZeroWord;
                end 
            endcase
        end
    end

//根据alusel_i选择逻辑运算或数值运算
    always @ (*) begin
        wd_o    <=  wd_i;       //要写的目的寄存器地址
        wreg_o  <=  wreg_i;     //是否写目的寄存器
        case (alusel_i)
            `EXE_RES_LOGIC: begin
                wdata_o <=  logicout;
            end
            `EXE_RES_SHIFT: begin
                wdata_o <=  shiftres;
            end
            default:    begin
                wdata_o <=  `ZeroWord;
            end
        endcase
    end

endmodule