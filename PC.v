`include "precompiled.v"

module PC(
    output reg[InstAddrBus] pc,
    output reg ce,
    input wire rst,
    input wire clk
);

always @ (posedge clk) begin        //复位时禁用指令储存器
    if (rst == 'RstEnable) begin
        ce <= `ChipDisable;
    end
    else begin
        ce <= `ChipEnable;
    end
end

always @ (posedge clk) begin
    if (ce == `ChipDisable) begin
        pc <= 32'h00000000;         //复位时PC为0
    end else begin
        pc <= pc+4'h4;              //PC每时钟+4
    end
end

endmodule