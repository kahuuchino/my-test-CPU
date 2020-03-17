`include "precompiled.v"

module PC(
    output reg[InstAddrBus] pc,
    output ce,
    input rst,
    input clk
);

always @ (posedge clk) begin
    if (rst == 'RstEnable) begin
        ce <= `ChipDisable;
    end
    else begin
        ce <= `ChipEnable;
    end
end

always @ (posedge clk) begin
    if (ce == `ChipDisable) begin
        pc <= 32'h00000000;
    end else begin
        pc <= pc+4'h4;
    end
end

endmodule