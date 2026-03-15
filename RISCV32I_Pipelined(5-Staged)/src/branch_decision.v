`timescale 1ns / 1ps

module branch_decision( input [31:0] rs1_data,
                        input [31:0] rs2_data,
                        input [31:0] instruction,
                        input [31:0] immediate,
                        input [31:0] pc,
                        output wire [31:0] pc_plus_off,
                        output reg branch_taken);

wire [6:0] opcode= instruction[6:0];
wire [2:0] funct3= instruction[14:12];

assign pc_plus_off=pc+immediate;

always @(*) begin
    if(opcode == 7'b1100011) begin
    case(funct3)
        
        3'b000: branch_taken = (rs1_data == rs2_data);        // BEQ
        3'b001: branch_taken = (rs1_data != rs2_data);        // BNE
        3'b100: branch_taken = ($signed(rs1_data) < $signed(rs2_data));          // BLT
                                                   
        3'b101: branch_taken = ($signed(rs1_data) >=  $signed(rs2_data));          // BGE
                                                  
        3'b110: branch_taken = (rs1_data < rs2_data);         // BLTU
        3'b111: branch_taken = (rs1_data >= rs2_data);        // BGEU
            
        default: branch_taken = 1'b0;
    endcase
    end
    else if(opcode == 7'b1101111 || opcode == 7'b1100111) begin
        branch_taken = 1; //JAL, JALR
    end
    else begin
        branch_taken = 1'b0;
    end
end


                         
                      
endmodule