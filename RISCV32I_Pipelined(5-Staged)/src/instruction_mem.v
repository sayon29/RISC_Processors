`timescale 1ns / 1ps                                                                                      
                                                                                                          
module instruction_mem(output reg [31:0] out,input clk,input [31:0] addr,input flush,input freeze, input rst);                              
reg [31:0] mem [127:0];                                                                                   
                                                                                                                                                                                            
initial begin                                                                                             
    $readmemh("program.mem", mem);                                                                        
end                                                                                                       
                                                                                                          
always @(posedge clk)begin
    if (rst == 1)begin out = 32'b0; end
    else if(flush==1 && freeze==0)begin out=32'b0; end               //For flush
    else if(flush==0 && freeze==1)begin  out <= out; end        //Fpr freeze
    else if(flush==0 && freeze==0)out<=mem[addr];
end
                                                                                                         
endmodule