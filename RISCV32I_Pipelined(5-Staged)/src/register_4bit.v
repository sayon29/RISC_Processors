`timescale 1ns / 1ps

module register_4bit(output reg [3:0] out,input [3:0] in,input clk,input flush, input rst);

always @(posedge clk)begin
    if (rst == 1)begin out = 4'b0; end
    else if(flush==1)begin out=4'b0; end               //For flush
    else if(flush==0)begin out<=in; end           //Out=In
end

endmodule