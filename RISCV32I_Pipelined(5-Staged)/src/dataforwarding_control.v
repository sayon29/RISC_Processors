`timescale 1ns / 1ps

module dataforwarding_control(input [31:0]instruction,
                              input [4:0] rd_addr_EX,
                              input [4:0] rd_addr_MEM,
                              input [4:0] rd_addr_WB,
                              input reg_write_en_EX,
                              input reg_write_en_MEM,
                              input reg_write_en_WB,
                              input [3:0] mem_write_en_EX,
                              input mem_enable_EX,
                              output reg [1:0] fwd_con3,
                              output reg [1:0] fwd_con4,
                              output reg fwd_con1,
                              output reg fwd_con2,
                              output reg flush_ID,
                              output reg freeze_PC,
                              output reg freeze_IF );                        
                 
 
 wire [6:0] opcode=instruction[6:0];                             
 wire [4:0] rs2_addr=instruction[24:20];
 wire [4:0] rs1_addr=instruction[19:15];
 reg check_rs1;
 reg check_rs2;
 
 always @(*) begin
    
    //Initially 0 
    flush_ID = 0;
    freeze_PC = 0;
    freeze_IF = 0;
    fwd_con1 = 0;
    fwd_con2 = 0;
    fwd_con3 = 2'b0;
    fwd_con4 = 2'b0;
    check_rs1 = 0;
    check_rs2 = 0;
    
    case(opcode)
        7'b0100011,7'b0110011,7'b1100011:begin 
            check_rs1 = 1;
            check_rs2 = 1;
        end
        7'b0000011,7'b0010011,7'b1100111: begin
            check_rs1 = 1;
        end
    endcase
    
    //RS1
    //Check in EX stage
    
    if(check_rs1 == 1) begin
            if(reg_write_en_EX==1 && rs1_addr==rd_addr_EX && rd_addr_EX!=0)begin
                fwd_con3=2'b01;
                if(mem_write_en_EX==0 && mem_enable_EX==1)begin 
                flush_ID=1;
                freeze_PC=1;
                freeze_IF=1;
                end
            end
            else if(reg_write_en_MEM==1 && rs1_addr==rd_addr_MEM && rd_addr_MEM!=0) begin
                fwd_con3=2'b10;
            end
            else if(reg_write_en_WB==1 && rs1_addr==rd_addr_WB && rd_addr_WB!=0) begin
                fwd_con1=1;
            end
    end
    if(check_rs2 == 1) begin
            if(reg_write_en_EX==1 && rs2_addr==rd_addr_EX && rd_addr_EX!=0)begin
                fwd_con4=2'b01;
                if(mem_write_en_EX==0 && mem_enable_EX==1)begin 
                    flush_ID=1;
                    freeze_PC=1;
                    freeze_IF=1;
                end
            end
            else if(reg_write_en_MEM==1 && rs2_addr==rd_addr_MEM && rd_addr_MEM!=0) begin
                fwd_con4=2'b10;
            end
            else if(reg_write_en_WB==1 && rs2_addr==rd_addr_WB && rd_addr_WB!=0) begin
                fwd_con2=1;
            end
   end
end
 
                              
endmodule