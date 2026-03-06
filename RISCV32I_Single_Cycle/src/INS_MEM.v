`timescale 1ns / 1ps                                                                                      
                                                                                                          
module INS_MEM(input clka,input w_en,input [6:0] addra,output [31:0] douta);                              
reg [31:0] mem [127:0];                                                                                   
assign douta=mem[addra];                                                                                  
                                                                                                          
initial begin                                                                                             
    $readmemh("program.mem", mem);                                                                        
end                                                                                                       
                                                                                                          
                                                                                                          
endmodule