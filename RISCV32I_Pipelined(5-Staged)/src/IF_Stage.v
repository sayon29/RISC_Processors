module IF_Stage(
    input wire clk,
    input wire rst,
    
    input wire [31:0] pc_plus_off,
    input wire        branch_taken,
    output wire [31:0] instruction_ID,
    output wire [31:0] pc_ID
);
    wire [31:0] pc_plus_one;
    wire [31:0] pc_net;
    wire [31:0] new_pc;
    
    assign pc_plus_one = pc_net + 1;
    assign new_pc = branch_taken ? pc_plus_off : pc_plus_one;
    
    register_32bit pc(
        .out(pc_net),
        .in(new_pc),
        .clk(clk),
        .flush(0),
        .freeze(0),
        .rst(rst)
    );
    
    register_32bit pc_IF(
        .out(pc_ID),
        .in(pc_plus_one),
        .clk(clk),
        .flush(branch_taken),
        .freeze(0),
        .rst(rst)
    );
    
    instruction_mem instruction_mem_inst (
        .clk(clk),
        .addr(pc_net),
        .out(instruction_ID),
        .flush(branch_taken),
        .freeze(0),
        .rst(rst)
    );
endmodule
