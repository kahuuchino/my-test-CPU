`include "precompiled.v"

module id(
    input wire                  rst,
    input wire[`InstAddrBus]    pc_i,
    input wire[`InstBus]        inst_i,

    //读取Regfile
    input wire[`RegBus]         reg1_data_i,
    input wire[`RegBus]         reg2_data_i,

    //输出到Regfile
    output reg                  reg1_read_o,
    output reg                  reg2_read_o,
    output reg[`RegAddrBus]     reg1_addr_o,
    output reg[`RegAddrBus]     reg2_addr_o,

    //送入执行阶段
    output reg[`AluOpBus]       aluop_o,
    output reg[`AluSelBus]      alusel_o,
    output reg[`RegBus]         reg1_o,
    output reg[`RegBus]         reg2_o,
    output reg[`RegAddrBus]     wd_o,
    output reg                  wreg,

    //TODO:增加处理流水线数据冲突端口
    //位于执行阶段的运算结果
    input   wire                ex_wreg_i,
    input   wire[`RegBus]       ex_wdata_i,
    input   wire[`RegAddrBus]   ex_wd_i,

    //位于访存阶段的运算结果
    input   wire                mem_wreg_i,
    input   wire[`RegBus]       mem_wdata_i,
    input   wire[`RegAddrBus]   mem_wd_i
);

//取得指令码
    wire[5:0] op  = inst_i[31:26];      //指令码
    wire[4:0] op2 = inst_i[10:6];       //移位指令所需的移位位码
    wire[5:0] op3 = inst_i[5:0];        //功能码
    wire[4:0] op4 = inst_i[20:16];      //指令指定参与计算的寄存器

//保存指令执行的立即数
    reg[`RegBus] imm;

//指令是否有效标志码
    reg instvalid;


//对指令进行译码
    always @ (*)    begin
        if(rst == `RstEnable) begin
            aluop_o     <=  `EXE_NOP_OP;
            alusel_o    <=  `EXE_RES_NOP;
            wd_o        <=  `NOPRegAddr;
            wreg        <=  `WriteDisable;
            instvalid   <=  `InstVaild;
            reg1_read_o <=  1'b0;
            reg2_read_o <=  1'b0;
            reg1_addr_o <=  `NOPRegAddr;
            reg2_addr_o <=  `NOPRegAddr;
            imm         <=  32'h0;
        end else begin
            aluop_o     <=  `EXE_NOP_OP;
            alusel_o    <=  `EXE_RES_NOP;
            wd_o        <=  inst_i[15:11];
            wreg        <=  `WriteDisable;
            instvalid   <=  `InstVaild;
            reg1_read_o <=  1'b0;
            reg2_read_o <=  1'b0;
            reg1_addr_o <=  inst_i[25:21];
            reg2_addr_o <=  inst_i[20:16];
            imm         <=  `ZeroWord;

            case(op)
                `EXE_SPECIAL_INST: begin
                    case (op2)
                        5'b00000:   begin
                            case (op3)

                                `EXE_OR:   begin    //指令OR
                                    wreg        <=  `WriteEnable;
                                    aluop_o     <=  `EXE_OR_OP;  
                                    alusel_o    <=  `EXE_RES_LOGIC;
                                    reg1_read_o <=  1'b1;
                                    reg2_read_o <=  1'b1;
                                    instvalid   <=  `InstVaild;
                                end

                                `EXE_AND:   begin    
                                    wreg        <=  `WriteEnable;
                                    aluop_o     <=  `EXE_AND_OP;  
                                    alusel_o    <=  `EXE_RES_LOGIC;
                                    reg1_read_o <=  1'b1;
                                    reg2_read_o <=  1'b1;
                                    instvalid   <=  `InstVaild;
                                end

                                `EXE_XOR:   begin    
                                    wreg        <=  `WriteEnable;
                                    aluop_o     <=  `EXE_XOR_OP;  
                                    alusel_o    <=  `EXE_RES_LOGIC;
                                    reg1_read_o <=  1'b1;
                                    reg2_read_o <=  1'b1;
                                    instvalid   <=  `InstVaild;
                                end

                                `EXE_NOR:   begin    
                                    wreg        <=  `WriteEnable;
                                    aluop_o     <=  `EXE_NOR_OP;  
                                    alusel_o    <=  `EXE_RES_LOGIC;
                                    reg1_read_o <=  1'b1;
                                    reg2_read_o <=  1'b1;
                                    instvalid   <=  `InstVaild;
                                end

                                `EXE_SLLV:   begin    
                                    wreg        <=  `WriteEnable;
                                    aluop_o     <=  `EXE_SLL_OP;  
                                    alusel_o    <=  `EXE_RES_SHIFT;
                                    reg1_read_o <=  1'b1;
                                    reg2_read_o <=  1'b1;
                                    instvalid   <=  `InstVaild;
                                end

                                `EXE_SRLV:   begin
                                    wreg        <=  `WriteEnable;
                                    aluop_o     <=  `EXE_SRL_OP;
                                    alusel_o    <=  `EXE_RES_SHIFT;
                                    reg1_read_o <=  1'b1;
                                    reg2_read_o <=  1'b1;
                                    instvalid   <=  `InstVaild;
                                end

                                `EXE_SRAV:   begin    
                                    wreg        <=  `WriteEnable;
                                    aluop_o     <=  `EXE_SRA_OP;  
                                    alusel_o    <=  `EXE_RES_SHIFT;
                                    reg1_read_o <=  1'b1;
                                    reg2_read_o <=  1'b1;
                                    instvalid   <=  `InstVaild;
                                end

                                `EXE_SYNC:   begin    
                                    wreg        <=  `WriteDisable;
                                    aluop_o     <=  `EXE_NOP_OP;
                                    alusel_o    <=  `EXE_RES_NOP;
                                    reg1_read_o <=  1'b1;
                                    reg2_read_o <=  1'b1;
                                    instvalid   <=  `InstVaild;
                                end

                                default:    begin
                                    
                                end
                            endcase //case op3
                        end
                        default:    begin
                            
                        end
                    endcase //case op2
                end

                `EXE_ORI:   begin
                    wreg        <=  `WriteEnable;           //指令需要写入寄存器
                    aluop_o     <=  `EXE_OR_OP;             //指令子类型为OR
                    alusel_o    <=  `EXE_RES_LOGIC;         //指令类型为逻辑运算
                    reg1_read_o <=  1'b1;                   //使用读端口1
                    reg2_read_o <=  1'b0;                   //不使用读端口2
                    imm         <=  {16'h0,inst_i[15:0]};   //指令需要的立即数
                    wd_o        <=  inst_i[20:16];          //指令需要的目的寄存器地址
                    instvalid   <=  `InstVaild;             //指令有效
                end

                `EXE_ANDI:   begin
                    wreg        <=  `WriteEnable;
                    aluop_o     <=  `EXE_AND_OP;
                    alusel_o    <=  `EXE_RES_LOGIC;
                    reg1_read_o <=  1'b1;
                    reg2_read_o <=  1'b0;
                    imm         <=  {16'h0,inst_i[15:0]};
                    wd_o        <=  inst_i[20:16];
                    instvalid   <=  `InstVaild;
                end

                `EXE_XORI:   begin
                    wreg        <=  `WriteEnable;
                    aluop_o     <=  `EXE_XOR_OP;
                    alusel_o    <=  `EXE_RES_LOGIC;
                    reg1_read_o <=  1'b1;
                    reg2_read_o <=  1'b0;
                    imm         <=  {16'h0,inst_i[15:0]};
                    wd_o        <=  inst_i[20:16];
                    instvalid   <=  `InstVaild;
                end
                
                `EXE_LUI:   begin
                    wreg        <=  `WriteEnable;
                    aluop_o     <=  `EXE_OR_OP;             //LUI视作立即数左移6位后与寄存器相或
                    alusel_o    <=  `EXE_RES_LOGIC;
                    reg1_read_o <=  1'b1;
                    reg2_read_o <=  1'b0;
                    imm         <=  {inst_i[15:0],16'h0};
                    wd_o        <=  inst_i[20:16];
                    instvalid   <=  `InstVaild;
                end

                `EXE_PREF:   begin
                    wreg        <=  `WriteDisable;
                    aluop_o     <=  `EXE_NOP_OP;
                    alusel_o    <=  `EXE_RES_NOP;
                    reg1_read_o <=  1'b0;
                    reg2_read_o <=  1'b0;
                    imm         <=  {16'h0,inst_i[15:0]};
                    wd_o        <=  inst_i[20:16];
                    instvalid   <=  `InstVaild;
                end
                default:    begin
                    
                end
            endcase //case op

            ////加入循环移位指令(已加入）
            if (inst_i[31:21] == 11'b00000000000) begin
                if (op3 == `EXE_SLL) begin
                    wreg        <=  `WriteEnable;
                    aluop_o     <=  `EXE_SLL_OP;
                    alusel_o    <=  `EXE_RES_SHIFT;
                    reg1_read_o <=  1'b0;
                    reg2_read_o <=  1'b1;
                    imm[4:0]    <=  inst_i[10:6];
                    wd_o        <=  inst_i[15:11];
                    instvalid   <=  `InstVaild;
                end else if (op3 == `EXE_SRL) begin
                    wreg        <=  `WriteEnable;
                    aluop_o     <=  `EXE_SRL_OP;
                    alusel_o    <=  `EXE_RES_SHIFT;
                    reg1_read_o <=  1'b0;
                    reg2_read_o <=  1'b1;
                    imm[4:0]    <=  inst_i[10:6];
                    wd_o        <=  inst_i[15:11];
                    instvalid   <=  `InstVaild;
                end else if (op3 == `EXE_SRA) begin
                    wreg        <=  `WriteEnable;
                    aluop_o     <=  `EXE_SRA_OP;
                    alusel_o    <=  `EXE_RES_SHIFT;
                    reg1_read_o <=  1'b0;
                    reg2_read_o <=  1'b1;
                    imm[4:0]    <=  inst_i[10:6];
                    wd_o        <=  inst_i[15:11];
                    instvalid   <=  `InstVaild;
                end
            end
        end

    end


//确定源操作数1
/*
若有复位信号，则操作数为0
若read_o为真，则输出寄存器地址
若read_o为假，则输出立即数
*/
    always @ (*)    begin
        if(rst == `RstEnable)   begin
            reg1_o <= `ZeroWord;
        //增加对执行和访存阶段结果的直接访问
        end else if ((reg1_read_o == 1'b1) && (ex_wreg_i == 1'b1) && (ex_wd_i == reg1_addr_o)) begin
            reg1_o <= ex_wdata_i;
        end else if ((reg1_read_o == 1'b1) && (mem_wreg_i == 1'b1) && (mem_wd_i == reg1_addr_o)) begin
            reg1_o <= mem_wdata_i;
        //增加结束
        end else if (reg1_read_o == 1'b1) begin
            reg1_o <= reg1_data_i;
        end else if (reg1_read_o == 1'b0) begin
            reg1_o <= imm;
        end else begin
            reg1_o <= `ZeroWord;
        end
    end

//确定源操作数2
    always @ (*)    begin
        if(rst == `RstEnable)   begin
            reg2_o <= `ZeroWord;
         //增加对执行和访存阶段结果的直接访问
        end else if ((reg2_read_o == 1'b1) && (ex_wreg_i == 1'b1) && (ex_wd_i == reg2_addr_o)) begin
            reg2_o <= ex_wdata_i;
        end else if ((reg2_read_o == 1'b1) && (mem_wreg_i == 1'b1) && (mem_wd_i == reg2_addr_o)) begin
            reg2_o <= mem_wdata_i;
        //增加结束
        end else if (reg2_read_o == 1'b1) begin
            reg2_o <= reg2_data_i;
        end else if (reg2_read_o == 1'b0) begin
            reg2_o <= imm;
        end else begin
            reg2_o <= `ZeroWord;
        end
    end    

endmodule
