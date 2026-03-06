module branch_condition(
    input  wire  [31:0] rs_data,
    input  wire  [31:0] rt_data,
    input  wire [2:0]  funct3,
    input  wire  [6:0] opcode,
    output reg         branch_cond_out
);

    always @(*) begin
        if(opcode == 7'b1100011) begin
            case(funct3)
    
                3'b000: branch_cond_out = (rs_data == rt_data);        // BEQ
                3'b001: branch_cond_out = (rs_data != rt_data);        // BNE
                3'b100: branch_cond_out = ($signed(rs_data) < 
                                           $signed(rt_data));          // BLT
                3'b101: branch_cond_out = ($signed(rs_data) >= 
                                           $signed(rt_data));          // BGE
                3'b110: branch_cond_out = (rs_data < rt_data);         // BLTU
                3'b111: branch_cond_out = (rs_data >= rt_data);        // BGEU
    
                default: branch_cond_out = 1'b0;
            endcase
        end
        else if(opcode == 7'b1101111 || opcode == 7'b1100111) begin
            branch_cond_out = 1; //JAL, JALR
        end
        else begin
            branch_cond_out = 1'b0;
        end
    end

endmodule