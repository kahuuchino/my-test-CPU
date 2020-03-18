//ROM
`define InstAddrBus     31:0                //ROM地址总线宽度
`define InstBus         31:0                //ROM数据总线宽度
`define InstMemNum      131071              //ROM实际大小
`define InstMemNumLog2  17                  //ROM实际使用的地址线宽度

//Regfile
`define RegAddrBus      4:0                 //Regfile地址线宽度
`define RegBus          32:0                //Regfile数据线宽度
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

//*具体指令相关
`define EXE_ORI         6'b001101           //指令ori的指令码
`define EXE_NOP         6'b000000           //指令nop（空指令）

//*Aluop
`define EXE_OR_OP       8'b00100101
`define EXE_NOP_OP      8'b00000000

//*AluSel
`define EXE_RES_LOGIC   3'b001
`define EXE_RES_NOP     3'b000


//*常用值定义
`define ZeroWord        32h'00000000        //32位的数值0