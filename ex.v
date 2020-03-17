`include "precomplied.v"

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

//根据aluop_i进行运算
    always @ (*) begin
        if (rst == `RstEnable) begin
            logicout <= `ZeroWord;
        end else begin
            case (aliop_i)
                `EXE_OR_OP: begin
                    logicout <= reg1_i | reg2_i;
                end
                default:    begin
                    logicout <= `ZeroWord;
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
            default:    begin
                wdata_o <=  `ZeroWord;
            end
        endcase
    end
