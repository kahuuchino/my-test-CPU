`include "precompiled.v"

module if_id(
    //译码后的信号
    output reg[`InstAddrBus] id_pc,
    output reg[`InstBus] id_inst,
    //取指信号
    input wire[`InstAddrBus] if_pc,
    input wire[`InstBus] if_inst,

    input wire clk,
    input wire rst
);

    always @ (posedge clk) begin
        if (rst == `RstEnable) begin
            id_pc <= `ZeroWord;
            id_inst <= `ZeroWord;
        end
        else begin
            id_pc <= if_pc;
            id_inst <= if_inst;
        end
    end

endmodule