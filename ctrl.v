`include "precomplied.v"

module ctrl(
    input wire              rst,

    input wire              stallreq_from_id,
    input wire              stallreq_from_ex,

    output reg[`CtrlBus]    stall
);

    always @ (*) begin
        if (rst == `RstEnable) begin
            stall <= 6'b000000;
        end else if (stallreq_from_ex == `STOP) begin
            stall <= 6'b001111;
        end else if (stallreq_from_id == `STOP) begin
            stall <= 6'b000111;
        end else begin
            stall <= 6'b000000;
        end
    end

endmodule // 