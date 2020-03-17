`include "precompiled.v"

module id_ex(
    input wire  rst,
    input wire  clk,

    //从译码阶段传来的信息
    input wire[`AluOpBus]   id_aluop,
    input wire[`AluSelBus]  id_alusel,
    input wire[`RegBus]     id_reg1,
    input wire[`RegBus]     id_reg2,
    input wire[`RegAbbrBus] id_wd,
    input wire              id_wreg,

    //送入执行阶段的信息
    output wire[`AluOpBus]   ex_aluop,
    output wire[`AluSelBus]  ex_alusel,
    output wire[`RegBus]     ex_reg1,
    output wire[`RegBus]     ex_reg2,
    output wire[`RegAbbrBus] ex_wd,
    output wire              ex_wreg,
);

    always @ (posedge clk)  begin
        if (rst == `RstEnable) begin
            ex_aluop    <=  `EXE_NOP_OP;
            ex_alusel   <=  `EXE_RES_NOP;
            ex_reg1     <=  `ZeroWord;
            ex_reg2     <=  `ZeroWord;
            ex_wd       <=  `NOPRegAddr;
            ex_wreg     <=  `WriteDisable;
        end else begin
            ex_aluop    <=  id_aluop;
            ex_alusel   <=  id_alusel;
            ex_reg1     <=  id_reg1;
            ex_reg2     <=  id_reg2;
            ex_wd       <=  id_wd;
            ex_wreg     <=  id_wreg;
        end
    end