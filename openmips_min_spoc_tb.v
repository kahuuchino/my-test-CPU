`timescale 1ns/1ps

`include "precompiled.v"

module openmips_min_spoc_tb();

    reg clock_50;
    reg rst;

    initial begin
        clock_50 = 1'b0;
        forever #10 clock_50 = ~clock_50;
    end

    initial begin
        rst = `RstEnable;
        #195 rst = `RstDisable;
        #1000 $stop;
    end

    openmips_min_spoc openmips_min_spoc0(
        .clk(clock_50),
        .rst(rst)
    );

endmodule