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

    //处理hi、lo寄存器
    input wire[`RegBus]     hi_i,
    input wire[`RegBus]     lo_i,
    //回写阶段访问hi、lo
    input wire[`RegBus]     wb_hi_i, 
    input wire[`RegBus]     wb_lo_i,
    input wire              wb_whilo_i, 
    //访存阶段访问hi、lo
    input wire[`RegBus]     mem_hi_i, 
    input wire[`RegBus]     mem_lo_i,
    input wire              mem_whilo_i, 
    //写入到hi、lo
    output reg[`RegBus]     hi_o,
    output reg[`RegBus]     lo_o,
    output reg              whilo_o,

    //执行的结果
    output reg[`RegAddrBus] wd_o,
    output reg              wreg_o,
    output reg[`RegBus]     wdata_o
);

    //保存逻辑运算的结果
    reg[`RegBus] logicout;
    //保存移位运算的结果
    reg[`RegBus] shiftres;
    //保存移动运算的结果
    reg[`RegBus] moveres;
    //保存要写入hi寄存器的值
    reg[`RegBus] HI;
    //保存要写入lo寄存器的值
    reg[`RegBus] LO;

    always @ (*) begin
        if(rst == `RstEnable) begin
            {HI,LO} <= {`ZeroWord,`ZeroWord};
        end else if (mem_whilo_i == `WriteEnable) begin
            {HI,LO} <= {mem_hi_i,mem_lo_i};
        end else if (wb_whilo_i == `WriteEnable) begin
            {HI,LO} <= {wb_hi_i,wb_lo_i};
        end else begin
            {HI,LO} <= {hi_i,lo_i};
        end
    end

//根据aluop_i进行运算

    //处理逻辑运算
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

    //处理移位运算
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

    //处理移动运算
    always @ (*) begin
        if (rst == `RstEnable) begin
            moveres <= `ZeroWord;
        end else begin
            case(aluop_i)

                `EXE_MOVZ_OP:   begin
                    moveres <= reg1_i;
                end
                
                `EXE_MOVN_OP:   begin
                    moveres <= reg1_i;
                end

                `EXE_MFHI_OP:   begin
                    moveres <= HI;
                end

                `EXE_MFLO_OP:   begin
                    moveres <= LO;
                end
                default:        begin
                    

                end
            endcase
        end
    end

    always @ (*) begin
        if (rst == `RstEnable) begin
            whilo_o <= `WriteDisable;
            hi_o    <= `ZeroWord;
            lo_o    <= `ZeroWord;
        end else begin
            case (aluop_i)
                `EXE_MTHI_OP:   begin
                    whilo_o <= `WriteEnable;
                    hi_o    <= reg1_i;
                    lo_o    <= LO;
                end
                `EXE_MTLO_OP:   begin
                    whilo_o <= `WriteEnable;
                    hi_o    <= HI;
                    lo_o    <= reg1_i;
                end
                default:        begin
                    whilo_o <= `WriteDisable;
                    hi_o    <= `ZeroWord;
                    lo_o    <= `ZeroWord;
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
            `EXE_RES_MOVE:  begin
                wdata_o <=  moveres;
            end
            default:    begin
                wdata_o <=  `ZeroWord;
            end
        endcase
    end

endmodule