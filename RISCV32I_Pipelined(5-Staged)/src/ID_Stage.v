module ID_Stage(
    input wire clk,
    input wire rst,

    // Datapath inputs from IF/ID
    input wire [31:0] pc_ID,
    input wire [31:0] instruction_ID,
    input wire [31:0] rs_data_ID,
    input wire [31:0] rt_data_ID,
    input wire [4:0]  rd_addr_ID,

    // Control signals from Control Unit (ID stage)
    input wire        reg_write_en_ID,
    input wire        muxA_con_ID,
    input wire        muxB_con_ID,
    input wire [3:0]  alu_op_ID,
    input wire [3:0]  mem_write_en_ID,
    input wire [1:0]  mux_writeback_con_ID,
    input wire        mem_enable_ID,

    // Datapath outputs to EX stage
    output wire [31:0] pc_EX,
    output wire [31:0] rs_data_EX,
    output wire [31:0] rt_data_EX,
    output wire [31:0] imm_EX,
    output wire [4:0]  rd_addr_EX,

    // Control signals forwarded to EX stage
    output wire        reg_write_en_EX,
    output wire        muxA_con_EX,
    output wire        muxB_con_EX,
    output wire [3:0]  alu_op_EX,
    output wire [3:0]  mem_write_en_EX,
    output wire [1:0]  mux_writeback_con_EX,
    output wire        mem_enable_EX,
    
    output wire [31:0] pc_plus_off,
    output wire        branch_taken
);

    wire [31:0] imm_out_net;

    // Immediate generator
    imm_generate imm_gen_inst (
        .instruction(instruction_ID),
        .imm_out(imm_out_net)
    );
    
    //Branch Decision Module
    branch_decision branch_decision_inst (
        .rs1_data(rs_data_ID),
        .rs2_data(rt_data_ID),
        .instruction(instruction_ID),
        .pc_plus_off(pc_plus_off),
        .branch_taken(branch_taken)
    );

    // Datapath pipeline registers
    register_32bit pcreg_ID (
        .out(pc_EX),
        .in(pc_ID),
        .clk(clk),
        .flush(0),
        .freeze(0)
    );

    register_32bit immreg_ID (
        .out(imm_EX),
        .in(imm_out_net),
        .clk(clk),
        .flush(0),
        .freeze(0)
    );

    register_32bit rs_data_reg_ID (
        .out(rs_data_EX),
        .in(rs_data_ID),
        .clk(clk),
        .flush(0),
        .freeze(0)
    );

    register_32bit rt_data_reg_ID (
        .out(rt_data_EX),
        .in(rt_data_ID),
        .clk(clk),
        .flush(0),
        .freeze(0)
    );

    register_5bit rd_addr_reg_ID (
        .out(rd_addr_EX),
        .in(rd_addr_ID),
        .clk(clk),
        .flush(0),
        .freeze(0)
    );

    // =============================
    // Control signal pipeline regs
    // =============================

    register_1bit reg_write_en_reg_ID (
        .out(reg_write_en_EX),
        .in(reg_write_en_ID),
        .clk(clk),
        .flush(0)
    );

    register_1bit muxA_con_reg_ID (
        .out(muxA_con_EX),
        .in(muxA_con_ID),
        .clk(clk),
        .flush(0)
    );

    register_1bit muxB_con_reg_ID (
        .out(muxB_con_EX),
        .in(muxB_con_ID),
        .clk(clk),
        .flush(0)
    );

    register_4bit alu_op_reg_ID (
        .out(alu_op_EX),
        .in(alu_op_ID),
        .clk(clk),
        .flush(0)
    );

    register_4bit mem_write_en_reg_ID (
        .out(mem_write_en_EX),
        .in(mem_write_en_ID),
        .clk(clk),
        .flush(0)
    );

    register_2bit mux_writeback_reg_ID (
        .out(mux_writeback_con_EX),
        .in(mux_writeback_con_ID),
        .clk(clk),
        .flush(0)
    );

    register_1bit mem_enable_reg_ID (
        .out(mem_enable_EX),
        .in(mem_enable_ID),
        .clk(clk),
        .flush(0)
        
    );

endmodule