`include "precompiled.v"

module openmips(
    input   wire clk,
    input   wire rst,
    
    input   wire[`RegBus]   rom_data_i,
    output  wire[`RegBus]   rom_addr_o, 
    output  wire            rom_ce_o
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
    wire[`RegAddrBus]   id_wd_o;
    wire                id_wreg_o;

    //*连接id/ex与ex
    wire[`AluOpBus]     ex_aluop_i;
    wire[`AluSelBus]    ex_alusel_i;
    wire[`RegBus]       ex_reg1_i;
    wire[`RegBus]       ex_reg2_i;
    wire[`RegAddrBus]   ex_wd_i;
    wire                ex_wreg_i;

    //*连接ex与ex/mem
    wire[`RegAddrBus]   ex_wd_o;
    wire                ex_wreg_o;
    wire[`RegBus]       ex_wdata_o;
    wire[`RegBus]       ex_hi_o;
    wire[`RegBus]       ex_lo_o;
    wire                ex_whilo_o;

    //*连接ex/mem与mem
    wire[`RegAddrBus]   mem_wd_i;
    wire                mem_wreg_i;
    wire[`RegBus]       mem_wdata_i;
    wire[`RegBus]       mem_hi_i;
    wire[`RegBus]       mem_lo_i;
    wire                mem_whilo_i;

    //*连接mem与mem/wb
    wire[`RegAddrBus]   mem_wd_o;
    wire                mem_wreg_o;
    wire[`RegBus]       mem_wdata_o;
    wire[`RegBus]       mem_hi_o;
    wire[`RegBus]       mem_lo_o;
    wire                mem_whilo_o;

    //*连接mem/wb至回写部分
    wire[`RegAddrBus]   wb_wd_i;
    wire                wb_wreg_i;
    wire[`RegBus]       wb_wdata_i;
    wire[`RegBus]       wb_hi_i;
    wire[`RegBus]       wb_lo_i;
    wire                wb_whilo_i;

    //*连接id与regfile
    wire[`RegBus]       reg1_data;
    wire[`RegBus]       reg2_data;
    wire                reg1_read;
    wire                reg2_read;
    wire[`RegAddrBus]   reg1_addr;
    wire[`RegAddrBus]   reg2_addr;

    //*连接特殊寄存器
    wire[`RegBus]       hi;
    wire[`RegBus]       lo;

    //*流水线控制信号
    wire[`CtrlBus]      stall;
    wire                stall_from_ex;
    wire                stall_from_id;


    //*实例化pc_reg
    pc_reg pc_reg0(
        .clk(clk),
        .rst(rst),
        .stall(stall),
        .pc(pc),
        .ce(rom_ce_o)
    );

    assign rom_addr_o = pc;

    //*实例化if/id
    if_id if_id0(
        .clk(clk),
        .rst(rst),
        .stall(stall),
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
        .stall_from_id(stall_from_id),
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
        .wreg(id_wreg_o),
        //处理流水线数据冲突
        .ex_wreg_i(ex_wreg_o),
        .ex_wdata_i(ex_wdata_o),
        .ex_wd_i(ex_wd_o),
        .mem_wreg_i(mem_wreg_o),
        .mem_wdata_i(mem_wdata_o),
        .mem_wd_i(mem_wd_o)
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
        .re2(reg2_read)
    );

    //*实例化id/ex
    id_ex id_ex0(
        .rst(rst),
        .clk(clk),
        .stall(stall),

        .id_aluop(id_aluop_o),
        .id_alusel(id_alusel_o),
        .id_reg1(id_reg1_o),
        .id_reg2(id_reg2_o),
        .id_wd(id_wd_o),
        .id_wreg(id_wreg_o),

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
        .stall_from_ex(stall_from_ex),

        .aluop_i(ex_aluop_i),
        .alusel_i(ex_alusel_i),
        .reg1_i(ex_reg1_i),
        .reg2_i(ex_reg2_i),
        .wd_i(ex_wd_i),
        .wreg_i(ex_wreg_i),

        .hi_i(hi),
        .lo_i(lo),

        .wb_hi_i(wb_hi_i),
        .wb_lo_i(wb_lo_i),
        .wb_whilo_i(wb_whilo_i),

        .mem_hi_i(mem_hi_o),
        .mem_lo_i(mem_lo_o),
        .mem_whilo_i(mem_whilo_o),

        .hi_o(ex_hi_o),
        .lo_o(ex_lo_o),
        .whilo_o(ex_whilo_o),

        .wd_o(ex_wd_o),
        .wreg_o(ex_wreg_o),
        .wdata_o(ex_wdata_o)
    );

    //*实例化ex/mem
    ex_mem ex_mem0(
        .rst(rst),
        .clk(clk),
        .stall(stall),

        .ex_wd(ex_wd_o),
        .ex_wreg(ex_wreg_o),
        .ex_wdata(ex_wdata_o),
        .ex_hi(ex_hi_o),
        .ex_lo(ex_lo_o),
        .ex_whilo(ex_whilo_o),

        .mem_wd(mem_wd_i),
        .mem_wreg(mem_wreg_i),
        .mem_wdata(mem_wdata_i),
        .mem_hi(mem_hi_i),
        .mem_lo(mem_lo_i),
        .mem_whilo(mem_whilo_i)
    );

    //*实例化mem
    mem mem0(
        .rst(rst),
        .clk(clk),

        .wd_i(mem_wd_i),
        .wreg_i(mem_wreg_i),
        .wdata_i(mem_wdata_i),
        .hi_i(mem_hi_i),
		.lo_i(mem_lo_i),
		.whilo_i(mem_whilo_i),

        .wd_o(mem_wd_o),
        .wreg_o(mem_wreg_o),
        .wdata_o(mem_wdata_o),
        .hi_o(mem_hi_o),
		.lo_o(mem_lo_o),
		.whilo_o(mem_whilo_o)
    );

    //*实例化mem/wb
    mem_wb mem_wb0(
        .rst(rst),
        .clk(clk),
        .stall(stall),

        .mem_wd(mem_wd_o),
        .mem_wreg(mem_wreg_o),
        .mem_wdata(mem_wdata_o),
        .mem_hi(mem_hi_o),
		.mem_lo(mem_lo_o),
		.mem_whilo(mem_whilo_o),

        .wb_wd(wb_wd_i),
        .wb_wreg(wb_wreg_i),
        .wb_wdata(wb_wdata_i),
        .wb_hi(wb_hi_i),
		.wb_lo(wb_lo_i),
		.wb_whilo(wb_whilo_i)
    );

    //*实例化hi、lo特殊寄存器
    hilo_reg hilo_reg0(
        .rst(rst),
        .clk(clk),

        .we(wb_whilo_i),
        .hi_i(wb_hi_i),
        .lo_i(wb_lo_i),

        .hi_o(hi),
        .lo_o(lo)
    );

    //*实例化ctrl流水线控制模块
    ctrl ctrl0(
        .rst(rst),
        .stall_from_ex(stall_from_ex),
        .stall_from_id(stall_from_id),
        .stall(stall)
    );

endmodule