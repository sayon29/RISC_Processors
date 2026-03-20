`timescale 1ns / 1ps

module data_mem(
  output reg [31:0] out,
  input  clk,
  input  [3:0] mem_write_en,         
  input  [6:0] addr,
  input  [31:0] in,
  input  enable
);

reg [31:0] mem [127:0];

initial begin
    $readmemh("datamem.mem", mem);
end


always @(posedge clk)begin
    if(enable==1)begin
        if(mem_write_en==4'b0001) mem [addr]<=in[7:0]; //SB
        else if(mem_write_en==4'b0011) mem [addr]<=in[15:0]; //SH
        else if(mem_write_en==4'b1111) mem [addr]<=in[31:0]; //SW
        out=mem[addr];   //read
    end
end

endmodule