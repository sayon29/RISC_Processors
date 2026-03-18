`timescale 1ns / 1ps

module branch_prediction(output wire [31:0] pc_plus_off ,
                       output wire branch_taken,
                       input [31:0] instruction,
                       input [31:0] immediate,
                       input [31:0] pc);
                   
wire [6:0] opcode= instruction[6:0];

assign pc_plus_off =pc+immediate;
assign branch_taken=((opcode==7'b1100011) && ($signed(immediate) < 0))||(opcode==7'b1101111) || (opcode==7'b1100111); 
                 
endmodule