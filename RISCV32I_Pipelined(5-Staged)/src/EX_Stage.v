module EX_Stage(
    input wire clk,
    input wire rst,

    // Datapath inputs from ID/EX registers
    input wire [31:0] pc_EX,
    input wire [31:0] rs_data_EX,
    input wire [31:0] rt_data_EX,
    input wire [31:0] imm_EX,
    input wire [4:0]  rd_addr_EX,
    input wire [31:0] instruction_EX,

    // Control signals from ID/EX registers
    input wire        reg_write_en_EX,
    input wire        muxA_con_EX,
    input wire        muxB_con_EX,
    input wire [3:0]  alu_op_EX,
    input wire [3:0]  mem_write_en_EX,
    input wire [1:0]  mux_writeback_con_EX,
    input wire        mem_enable_EX,

    // Datapath outputs to MEM stage
    output wire [31:0] alu_res_MEM,
    output wire [31:0] rt_data_MEM, // Forwarded for store instructions
    output wire [31:0] pc_MEM,
    output wire [4:0]  rd_addr_MEM,

    // Control signals forwarded to MEM stage
    output wire        reg_write_en_MEM,
    output wire [3:0]  mem_write_en_MEM,
    output wire [1:0]  mux_writeback_con_MEM,
    output wire        mem_enable_MEM,
    
    input  wire [1:0]  fwd_con3,
    input  wire [1:0]  fwd_con4,
    input  wire [31:0] write_back_data_WB,
    
    output wire        wrong_pred,
    input  wire        pred_out_EX,
    input  wire [31:0] pc_plus_off_EX,
    output wire [31:0] real_pc,
    
    // Status signals
    output wire        alu_overflow
);

    // Internal wires for Mux outputs
    wire [31:0] muxA_out;
    wire [31:0] muxB_out;
    wire [31:0] alu_result_net;
    wire        alu_carry; // Optional: not usually forwarded to MEM
    wire [31:0] fwd_mux_data3;
    wire [31:0] fwd_mux_data4;
    
    wire        real_pc_con;
    
    assign fwd_mux_data3  =(fwd_con3 == 2'b00) ? rs_data_EX :
                           (fwd_con3 == 2'b01) ? alu_res_MEM :
                           (fwd_con3 == 2'b10) ? write_back_data_WB : 32'b0 ;
    
    assign fwd_mux_data4  =(fwd_con4 == 2'b00) ? rt_data_EX :
                           (fwd_con4 == 2'b01) ? alu_res_MEM :
                           (fwd_con4 == 2'b10) ? write_back_data_WB : 32'b0 ;
    
    // Mux A logic: Select between Register Data and PC
    assign muxA_out = (muxA_con_EX) ? fwd_mux_data3 : pc_EX;

    // Mux B logic: Select between Register Data and Immediate
    assign muxB_out = (muxB_con_EX) ? fwd_mux_data4 : imm_EX;

     branch_decision branch_decision_inst (
        .rs1_data(fwd_mux_data3),
        .rs2_data(fwd_mux_data4),
        .immediate(imm_EX),
        .instruction(instruction_EX),
        .pred_out(pred_out_EX),
        .wrong_pred(wrong_pred),
        .real_pc_con(real_pc_con)
    );
    
    assign real_pc = (real_pc_con)? pc_plus_off_EX : pc_EX;
    
    // ALU Instantiation
    alu alu_inst (
        .in_1(muxA_out), 
        .in_2(muxB_out), 
        .ALU_CON(alu_op_EX),
        .out(alu_result_net), 
        .OV(alu_overflow), 
        .CY(alu_carry)
    );

    // --- EX/MEM Pipeline Registers ---
    // These registers transition the signals from the EX stage to the MEM stage
    
    register_32bit alu_res_reg (
        .out(alu_res_MEM), .in(alu_result_net), .clk(clk), .flush(0), .freeze(0), .rst(rst)
    );

    register_32bit rt_data_pass_reg (
        .out(rt_data_MEM), .in(rt_data_EX), .clk(clk), .flush(0), .freeze(0), .rst(rst)
    );

    register_32bit pc_pass_reg (
        .out(pc_MEM), .in(pc_EX), .clk(clk), .flush(0), .freeze(0), .rst(rst)
    );

    register_5bit rd_addr_reg (
        .out(rd_addr_MEM), .in(rd_addr_EX), .clk(clk), .flush(0), .freeze(0), .rst(rst)
    );

    register_1bit reg_write_reg (
        .out(reg_write_en_MEM), .in(reg_write_en_EX), .clk(clk), .flush(0), .rst(rst)
    );

    register_4bit mem_write_reg (
        .out(mem_write_en_MEM), .in(mem_write_en_EX), .clk(clk), .flush(0), .rst(rst)
    );

    register_2bit mux_wb_reg (
        .out(mux_writeback_con_MEM), .in(mux_writeback_con_EX), .clk(clk), .flush(0), .rst(rst)
    );

    register_1bit mem_en_reg (
        .out(mem_enable_MEM), .in(mem_enable_EX), .clk(clk), .flush(0), .rst(rst)
    );

endmodule