module IF_Stage(
    input wire clk,
    input wire rst,
    
    input wire  [31:0] pc_plus_off,
    input wire         branch_taken,
    input wire         wrong_pred,
    input wire  [31:0] real_pc,
    output wire [31:0] instruction_ID,
    output wire [31:0] pc_ID,
    
    input wire freeze_PC,
    input wire flush_IF,
    input wire freeze_IF
);
    wire [31:0] pc_plus_one;
    wire [31:0] pc_net;
    wire [31:0] new_pc_pred;
    wire [31:0] new_pc;
    
    assign pc_plus_one = pc_net + 1;
    assign new_pc_pred = branch_taken ? pc_plus_off : pc_plus_one;
    assign new_pc = wrong_pred ? real_pc : new_pc_pred;
    
    register_32bit pc(
        .out(pc_net),
        .in(new_pc),
        .clk(clk),
        .flush(0),
        .freeze(freeze_PC),
        .rst(rst)
    );
    
    register_32bit pc_IF(
        .out(pc_ID),
        .in(pc_plus_one),
        .clk(clk),
        .flush(flush_IF),
        .freeze(freeze_IF),
        .rst(rst)
    );
    
    instruction_mem instruction_mem_inst (
        .clk(clk),
        .addr(pc_net),
        .out(instruction_ID),
        .flush(flush_IF),
        .freeze(freeze_IF),
        .rst(rst)
    );
endmodule
