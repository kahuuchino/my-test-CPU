`include "precompiled.v"

module openmips(
    input wire clk,
    input wire rst,
    
    input   wire[`RegBus]   rom_data_i,
    output  reg[`RegBus]    rom_addr_o, 
    output  reg             rom_ce_o
);

    //*连接if/id与id
    wire[`InstAddrBus]  pc;
    wire[`InstAddrBus]  id_pc_i;
    wire[`InstBus]      id_inst_i;

    //*连接id与id/ex
    wire[`AluOpBus]     id_aluop_o;
    wire[`AluSelBus]    id_alusel_o;
    wire[`RegBus]       id_reg1_o;
    wire[`RegBus]       id_reg2_o;
    wire[`RegAbbrBus]   id_wd_o;
    wire                id_wreg_o;

    //*连接id/ex与ex
    wire[`AluOpBus]     ex_aluop_i;
    wire[`AluSelBus]    ex_alusel_i;
    wire[`RegBus]       ex_reg1_i;
    wire[`RegBus]       ex_reg2_i;
    wire[`RegAbbrBus]   ex_wd_i;
    wire                ex_wreg_i;

    //*连接ex与ex/mem
    wire[`RegAddrBus]   ex_wd_o;
    wire                ex_wreg_o;
    wire[`RegBus]       ex_wdata_o;

    //*连接ex/mem与mem
    wire[`RegAddrBus]   mem_wd_i;
    wire                mem_wreg_i;
    wire[`RegBus]       mem_wdata_i;

    //*连接mem与mem/wb
    wire[`RegAddrBus]   mem_wd_o;
    wire                mem_wreg_o;
    wire[`RegBus]       mem_wdata_o;

    //*连接mem/wb至回写部分
    wire[`RegAddrBus]   wb_wd_i;
    wire                wb_wreg_i;
    wire[`RegBus]       wb_wdata_i;

    //*连接id与regfile
    wire[`RegBus]        reg1_data;
    wire[`RegBus]        reg2_data;
    wire                 reg1_read;
    wire                 reg2_read;
    wire[`RegAddrBus]    reg1_addr;
    wire[`RegAddrBus]    reg2_addr;

    //*实例化pc_reg
    pc_reg pc_reg0(
        .clk(clk),
        .rst(rst),
        .pc(pc),
        .ce(rom_ce_o)
    );

    assign rom_addr_o = pc;

    //*实例化if/id
    if_id if_id0(
        .clk(clk),
        .rst(rst),
        .if_pc(pc),
        .if_inst(rom_data_i),
        .id_pc(id_pc_i),
        .id_inst(id_inst_i)
    );

    //*实例化id
    id id0(
        .rst(rst),
        .pc_i(id_pc_i),
        .inst_i(id_inst_i),
        //来自regfile的输入
        .reg1_data_i(reg1_data),
        .reg2_data_i(reg2_data),
        //送到regfile的信息
        .reg1_read_o(reg1_read),
        .reg2_read_o(reg2_read),
        .reg1_addr_o(reg1_addr),
        .reg2_addr_o(reg2_addr),
        //送到id/ex模块
        .aluop_o(id_aluop_o),
        .alusel_o(id_alusel_o),
        .reg1_o(id_reg1_o),
        .reg2_o(id_reg2_o),
        .wd_o(id_wd_o),
        .wreg(id_wreg_o)
    );

    //*实例化regfile
    regfile regfile0(
        .rst(rst),
        .clk(clk),

        .waddr(wb_wd_i),
        .wdata(wb_wdata_i),
        .we(wb_wreg_i),

        .rdata1(reg1_data),
        .raddr1(reg1_addr),
        .re1(reg1_read),

        .rdata2(reg2_data),
        .raddr2(reg2_addr),
        .re2(reg2_read),
    );

    //*实例化id/ex
    id_ex id_ex0(
        .rst(rst),
        .clk(clk),

        .id_aluop(id_aluop_o),
        .id_alusel(id_alusel_o),
        .id_reg1(id_reg1_o),
        .id_reg2(id_reg2_o),
        .id_wd(id_wd_o),
        .id_wreg(id_wreg_o)

        .ex_aluop(ex_aluop_i),
        .ex_alusel(ex_alusel_i),
        .ex_reg1(ex_reg1_i),
        .ex_reg2(ex_reg2_i),
        .ex_wd(ex_wd_i),
        .ex_wreg(ex_wreg_i)
    );

    //*实例化ex
    ex ex0(
        .rst(rst),

        .aluop_i(ex_aluop_i),
        .alusel_i(ex_alusel_i),
        .reg1_i(ex_reg1_i),
        .reg2_i(ex_reg2_i),
        .wd_i(ex_wd_i),
        .wreg_i(ex_wreg_1),

        .wd_o(ex_wd_o),
        .wreg_o(ex_wreg_o),
        .wdata_o(ex_wdata_o)
    );

    //*实例化ex/mem
    ex_mem ex_mem0(
        .rst(rst),
        .clk(clk),

        .ex_wd(ex_wd_o),
        .ex_wreg(ex_wreg_o),
        .ex_wdata(ex_wdata_o),

        .mem_wd(mem_wd_i),
        .mem_wreg(mem_wreg_i),
        .mem_wdata(mem_wdata_i)
    );

    //*实例化mem
    mem mem0(
        .rst(rst),
        .clk(clk),

        .wd_i(mem_wd_i),
        .wreg_i(mem_wreg_i),
        .wdata_i(mem_wdata_i),

        .wd_o(mem_wd_o),
        .wreg_o(mem_wreg_o),
        .wdata_o(mem_wdata_o)
    );

    //*实例化mem/wb
    mem_wb mem_wb0(
        .rst(rst),
        .clk(clk),

        .mem_wd(mem_wd_o),
        .mem_wreg(mem_wreg_o),
        .mem_wdata(mem_wdata_o),

        .wb_wd(wb_wd_i),
        .wb_wreg(wb_wreg_i),
        .wb_wdata(wb_wdata_i)
    );

endmodule