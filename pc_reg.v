`include "precompiled.v"

module pc_reg(
    input wire               rst,
    input wire               clk,

    input wire[`CtrlBus]     stall,

    output reg[`InstAddrBus] pc,
    output reg               ce
);

always @ (posedge clk) begin        //复位时禁用指令储存器
    if (rst == `RstEnable) begin
        ce <= `ChipDisable;
    end
    else begin
        ce <= `ChipEnable;
    end
end

always @ (posedge clk) begin
    if (ce == `ChipDisable) begin
        pc <= 32'h00000000;         //复位时PC为0
    end else if(stall[0] == `NOSTOP) begin
        pc <= pc+4'h4;              //PC每时钟+4
    end
end

endmodule