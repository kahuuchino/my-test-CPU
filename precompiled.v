//ROM
`define InstAddrBus     31:0                //ROM地址总线宽度
`define InstBus         31:0                //ROM数据总线宽度
`define InstMemNum      131071              //ROM实际大小
`define InstMemNumLog2  17                  //ROM实际使用的地址线宽度

//Regfile
`define RegAddrBus      4:0                 //Regfile地址线宽度
`define RegBus          31:0                //Regfile数据线宽度
`define RegNum          32                  //32位寄存器的数量
`define RegNumLog2      5                   //寻址寄存器地址宽度
`define NOPRegAddr      5'b00000

//*全局信号定义
`define ChipEnable      1'b1                //芯片使能
`define ChipDisable     1'b0                //芯片禁止
`define RstEnable       1'b1                //复位有效
`define RstDisable      1'b0                //复位无效
`define WriteEnable     1'b1                //写使能
`define WriteDisable    1'b0                //写禁止
`define ReadEnable      1'b1                //读使能
`define ReadDisable     1'b0                //读禁止
`define AluOpBus        7:0                 //译码输出aluop_o宽度
`define AluSelBus       2:0                 //译码输出alusel_o宽度
`define InstVaild       1'b0                //指令有效
`define InstInvaild     1'b1                //指令无效
`define True_v          1'b1                //逻辑为真
`define False_v         1'b0                //逻辑为假

//*指令码
//逻辑运算指令
`define EXE_NOP         6'b000000           //指令nop（空指令）
`define EXE_AND         6'b100100           //指令and
`define EXE_OR          6'b100101
`define EXE_XOR         6'b100110
`define EXE_NOR         6'b100111
`define EXE_ANDI        6'b001100
`define EXE_ORI         6'b001101
`define EXE_XORI        6'b001110
`define EXE_LUI         6'b001111

//移位运算指令
`define EXE_SLL         6'b000000
`define EXE_SLLV        6'b000100
`define EXE_SRL         6'b000010
`define EXE_SRLV        6'b000110
`define EXE_SRA         6'b000011
`define EXE_SRAV        6'b000111

//特殊指令
`define EXE_SYNC        6'b001111
`define EXE_PREF        6'b110011
`define EXE_SPECIAL_INST 6'b000000

//*Aluop
`define EXE_OR_OP       8'b00100101
`define EXE_NOP_OP      8'b00000000

`define EXE_AND_OP   8'b00100100
`define EXE_OR_OP    8'b00100101
`define EXE_XOR_OP  8'b00100110
`define EXE_NOR_OP  8'b00100111
`define EXE_ANDI_OP  8'b01011001
`define EXE_ORI_OP  8'b01011010
`define EXE_XORI_OP  8'b01011011
`define EXE_LUI_OP  8'b01011100

`define EXE_SLL_OP  8'b01111100
`define EXE_SLLV_OP  8'b00000100
`define EXE_SRL_OP  8'b00000010
`define EXE_SRLV_OP  8'b00000110
`define EXE_SRA_OP  8'b00000011
`define EXE_SRAV_OP  8'b00000111

`define EXE_NOP_OP    8'b00000000

//*AluSel
`define EXE_RES_LOGIC   3'b001
`define EXE_RES_SHIFT 	3'b010
`define EXE_RES_NOP     3'b000


//*常用值定义
`define ZeroWord        32'h00000000        //32位的数值0