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
    
    //Branch Decision
    output wire [31:0] pc_plus_off,
    output wire        branch_taken,
    
    //Data Forwarding Control
    input wire  [4:0] rd_addr_MEM,
    input wire  [4:0] rd_addr_WB,
    input wire        reg_write_en_MEM,
    input wire        reg_write_en_WB,
    output wire [1:0] fwd_con3_EX,
    output wire [1:0] fwd_con4_EX,
    input  wire [31:0] write_back_data_WB,
    
    output wire freeze_IF,
    output wire freeze_PC,
    output wire flush_IF,
    output wire pred_out_EX,
    output wire [31:0] pc_plus_off_EX,
    output wire [31:0] instruction_EX,
    
    input wire wrong_pred
);

    wire [31:0] imm_out_net;

    wire fwd_con1;
    wire fwd_con2;
    wire [1:0] fwd_con3;
    wire [1:0] fwd_con4;
    
    wire [31:0] fwd_mux_data1;
    wire [31:0] fwd_mux_data2;
    
    wire flush_ID;
    
    wire flush_ID_data_fwd;
    wire freeze_IF_data_fwd;
    wire freeze_PC_data_fwd;
    
    assign fwd_mux_data1 = fwd_con1 ? write_back_data_WB: rs_data_ID;
    assign fwd_mux_data2 = fwd_con2 ? write_back_data_WB: rt_data_ID;
    
    // Immediate generator
    imm_generate imm_gen_inst (
        .instruction(instruction_ID),
        .imm_out(imm_out_net)
    );
    
    //Branch Prediction Module
    branch_prediction branch_prediction_inst(
        .instruction(instruction_ID),
        .immediate(imm_out_net),
        .pc(pc_ID),
        .pc_plus_off(pc_plus_off),
        .branch_taken(branch_taken)
    );
    
    hazard_control hazard_control_inst(
    
        .flush_IF_BP(branch_taken),
        .flush_ID_DF(flush_ID_data_fwd),
        .flush_ID_BD(wrong_pred),
        .flush_IF_BD(wrong_pred),
        .freeze_PC_DF(freeze_PC_data_fwd),
        .freeze_IF_DF(freeze_IF_data_fwd),
        
        .freeze_PC(freeze_PC),
        .freeze_IF(freeze_IF),
        .flush_IF(flush_IF),
        .flush_ID(flush_ID)
    );
        
   
    dataforwarding_control dataforwarding_control_inst(
        .instruction(instruction_ID),
        .rd_addr_EX(rd_addr_EX),
        .rd_addr_MEM(rd_addr_MEM),
        .rd_addr_WB(rd_addr_WB),
        .reg_write_en_EX(reg_write_en_EX),
        .reg_write_en_MEM(reg_write_en_MEM),
        .reg_write_en_WB(reg_write_en_WB),
        .mem_write_en_EX(mem_write_en_EX),
        .mem_enable_EX(mem_enable_EX),
        .fwd_con1(fwd_con1),
        .fwd_con2(fwd_con2),
        .fwd_con3(fwd_con3),
        .fwd_con4(fwd_con4),
        .flush_ID(flush_ID_data_fwd),
        .freeze_IF(freeze_IF_data_fwd),
        .freeze_PC(freeze_PC_data_fwd)
    );

    // Datapath pipeline registers
    register_32bit pcreg_ID (
        .out(pc_EX),
        .in(pc_ID),
        .clk(clk),
        .flush(flush_ID),
        .freeze(0),
        .rst(rst)
    );

    register_32bit immreg_ID (
        .out(imm_EX),
        .in(imm_out_net),
        .clk(clk),
        .flush(flush_ID),
        .freeze(0),
        .rst(rst)
    );

    register_32bit rs_data_reg_ID (
        .out(rs_data_EX),
        .in(fwd_mux_data1),
        .clk(clk),
        .flush(flush_ID),
        .freeze(0),
        .rst(rst)
    );

    register_32bit rt_data_reg_ID (
        .out(rt_data_EX),
        .in(fwd_mux_data2),
        .clk(clk),
        .flush(flush_ID),
        .freeze(0),
        .rst(rst)
    );

    register_5bit rd_addr_reg_ID (
        .out(rd_addr_EX),
        .in(rd_addr_ID),
        .clk(clk),
        .flush(flush_ID),
        .freeze(0),
        .rst(rst)
    );
    
    register_32bit instruction_reg_EX (
        .out(instruction_EX),
        .in(instruction_ID),
        .clk(clk),
        .flush(flush_ID),
        .freeze(0),
        .rst(rst)
    );
    
    // =============================
    // Control signal pipeline regs
    // =============================

    register_1bit reg_write_en_reg_ID (
        .out(reg_write_en_EX),
        .in(reg_write_en_ID),
        .clk(clk),
        .flush(flush_ID),
        .rst(rst)
    );

    register_1bit muxA_con_reg_ID (
        .out(muxA_con_EX),
        .in(muxA_con_ID),
        .clk(clk),
        .flush(flush_ID),
        .rst(rst)
    );

    register_1bit muxB_con_reg_ID (
        .out(muxB_con_EX),
        .in(muxB_con_ID),
        .clk(clk),
        .flush(flush_ID),
        .rst(rst)
    );

    register_4bit alu_op_reg_ID (
        .out(alu_op_EX),
        .in(alu_op_ID),
        .clk(clk),
        .flush(flush_ID),
        .rst(rst)
    );

    register_4bit mem_write_en_reg_ID (
        .out(mem_write_en_EX),
        .in(mem_write_en_ID),
        .clk(clk),
        .flush(flush_ID),
        .rst(rst)
    );

    register_2bit mux_writeback_reg_ID (
        .out(mux_writeback_con_EX),
        .in(mux_writeback_con_ID),
        .clk(clk),
        .flush(flush_ID),
        .rst(rst)
    );

    register_1bit mem_enable_reg_ID (
        .out(mem_enable_EX),
        .in(mem_enable_ID),
        .clk(clk),
        .flush(flush_ID),
        .rst(rst)
        
    );
    
    register_2bit fwd_con3_reg (
        .out(fwd_con3_EX),
        .in(fwd_con3),
        .clk(clk),
        .flush(flush_ID),
        .rst(rst)
    );
    
    register_2bit fwd_con4_reg (
        .out(fwd_con4_EX),
        .in(fwd_con4),
        .clk(clk),
        .flush(flush_ID),
        .rst(rst)
    );
    
    register_1bit branch_pred_reg (
        .out(pred_out_EX),
        .in(branch_taken),
        .clk(clk),
        .rst(rst),
        .flush(flush_ID)
    );
    
    register_32bit pc_plus_off_reg (
        .out(pc_plus_off_EX),
        .in(pc_plus_off),
        .clk(clk),
        .rst(rst),
        .flush(flush_ID),
        .freeze(0)
    );
    
    register_5bit rd_addr_reg (
        .out(rd_addr_EX),
        .in(rd_addr_ID),
        .clk(clk),
        .flush(flush_ID),
        .freeze(0),
        .rst(rst)
    );


endmodule