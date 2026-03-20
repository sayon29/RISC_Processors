`timescale 1ns / 1ps

module branch_decision( input [31:0] rs1_data,
                        input [31:0] rs2_data,
                        input [31:0] instruction,
                        input pred_out,
                        output reg real_pc_con,
                        output reg wrong_pred);

wire [6:0] opcode= instruction[6:0];
wire [2:0] funct3= instruction[14:12];


always @(*) begin
    if(opcode == 7'b1100011) begin
        case(funct3)          
            3'b000:begin 
                        real_pc_con = (rs1_data == rs2_data);        // BEQ
                        wrong_pred =(real_pc_con!=pred_out);
                   end
            3'b001:begin
                        real_pc_con = (rs1_data != rs2_data);        // BNE
                        wrong_pred =(real_pc_con!=pred_out);
                   end
            3'b100:begin 
                        real_pc_con = ($signed(rs1_data) < $signed(rs2_data));          // BLT
                        wrong_pred =(real_pc_con!=pred_out);
                   end                                    
            3'b101:begin 
                        real_pc_con = ($signed(rs1_data) >=  $signed(rs2_data));          // BGE
                        wrong_pred =(real_pc_con!=pred_out);
                   end                                   
            3'b110:begin 
                        real_pc_con = (rs1_data < rs2_data);         // BLTU
                        wrong_pred =(real_pc_con!=pred_out);
                   end     
            3'b111:begin 
                        real_pc_con = (rs1_data >= rs2_data);        // BGEU
                        wrong_pred =(real_pc_con!=pred_out);
                   end
                
            default:begin 
                        real_pc_con = 1'b0;
                        wrong_pred =(real_pc_con!=pred_out);
                    end
        endcase  
    end
    else if(opcode == 7'b1101111 || opcode == 7'b1100111) begin
            real_pc_con = 1; //JAL, JALR
            wrong_pred =(real_pc_con!=pred_out);
    end
    else begin
            real_pc_con = 1'b0;
            wrong_pred =(real_pc_con!=pred_out);
    end   
    
end
                                               
endmodule