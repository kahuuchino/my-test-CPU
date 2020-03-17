//ROM
`define InstAddrBus     31:0    //ROM地址总线宽度
`define InstBus         31:0    //ROM数据总线宽度
`define InstMemNum      131071  //ROM实际大小
`define InstMemNumLog2  17      //ROM实际使用的地址线宽度

//全局信号定义
`define ChipEnable      1'b1    //芯片使能
`define ChipDisable     1'b0   //芯片禁止
