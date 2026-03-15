module datapath(
    input wire           clk,
    input wire           rst,
    input wire           reg_write_en,
    input wire           muxA_con,
    input wire           muxB_con,
    input wire  [3:0]    alu_op,
    input wire  [3:0]    mem_write_en, 
    input wire  [1:0]    mux_writeback_con, 
    input wire           mem_enable,
    
    output wire  [31:0]  write_back_data_WB,
    output wire          alu_overflow,
    output wire [31:0]   instruction_ID
);

    wire [31:0] pc_ID;
    
    wire [4:0] rs1_addr_ID = instruction_ID[19:15];
    wire [4:0] rs2_addr_ID = instruction_ID[24:20];
    wire [4:0] rd_addr_ID  = instruction_ID[11:7];
    
    wire [31:0] rs_data_ID;
    wire [31:0] rt_data_ID;
    
   wire [31:0] pc_EX;
    wire [31:0] rs_data_EX;
    wire [31:0] rt_data_EX;
    wire [31:0] imm_EX;
    wire [4:0]  rd_addr_EX;

    wire        reg_write_en_EX;
    wire        muxA_con_EX;
    wire        muxB_con_EX;
    wire [3:0]  alu_op_EX;
    wire [3:0]  mem_write_en_EX;
    wire [1:0]  mux_writeback_con_EX;
    wire        mem_enable_EX;
    
    wire [31:0] alu_res_MEM;
    wire [31:0] rt_data_MEM;
    wire [31:0] pc_MEM;
    wire [4:0]  rd_addr_MEM;

    wire        reg_write_en_MEM;
    wire [3:0]  mem_write_en_MEM;
    wire [1:0]  mux_writeback_con_MEM;
    wire        mem_enable_MEM;
    
    wire [31:0] alu_res_WB;
    wire [31:0] pc_WB;
    wire [31:0] memdata_WB;
    wire [4:0]  rd_addr_WB;
    wire [1:0]  mux_writeback_con_WB;
    wire        reg_write_en_WB;

    wire [31:0] pc_plus_off;
    wire        branch_taken;

    IF_Stage IF_Stage_inst(
        .clk(clk),
        .rst(rst),
        .pc_ID(pc_ID),
        .instruction_ID(instruction_ID),
        .branch_taken(branch_taken),
        .pc_plus_off(pc_plus_off)
    );
    
    ID_Stage ID_Stage_inst (
        .clk(clk),
        .rst(rst),

        // Datapath inputs from IF/ID (Internal wires)
        .pc_ID(pc_ID),
        .instruction_ID(instruction_ID),
        .rs_data_ID(rs_data_ID),
        .rt_data_ID(rt_data_ID),
        .rd_addr_ID(rd_addr_ID),

        // Control signals from Control Unit (Top-level inputs)
        .reg_write_en_ID(reg_write_en),
        .muxA_con_ID(muxA_con),
        .muxB_con_ID(muxB_con),
        .alu_op_ID(alu_op),
        .mem_write_en_ID(mem_write_en),
        .mux_writeback_con_ID(mux_writeback_con),
        .mem_enable_ID(mem_enable),

        // Datapath outputs to EX stage (New wires)
        .pc_EX(pc_EX),
        .rs_data_EX(rs_data_EX),
        .rt_data_EX(rt_data_EX),
        .imm_EX(imm_EX),
        .rd_addr_EX(rd_addr_EX),

        // Control signals forwarded to EX stage (New wires)
        .reg_write_en_EX(reg_write_en_EX),
        .muxA_con_EX(muxA_con_EX),
        .muxB_con_EX(muxB_con_EX),
        .alu_op_EX(alu_op_EX),
        .mem_write_en_EX(mem_write_en_EX),
        .mux_writeback_con_EX(mux_writeback_con_EX),
        .mem_enable_EX(mem_enable_EX),
        
        //Datapath and Control Output to IF Stage for Branch Taken
        .pc_plus_off(pc_plus_off),
        .branch_taken(branch_taken)
    );
    
    reg_bank reg_file_inst(
        .clk(clk), 
        .rst(rst), 
        .wr_en(reg_write_en_WB),
        .r_addr_a(rs1_addr_ID), 
        .r_addr_b(rs2_addr_ID),
        .w_addr(rd_addr_WB), 
        .w_data(write_back_data_WB),
        .r_data_a(rs_data_ID), 
        .r_data_b(rt_data_ID)
    );

    EX_Stage EX_Stage_inst (
        .clk(clk),
        .rst(rst),

        // Datapath inputs from ID/EX pipeline registers
        .pc_EX(pc_EX),
        .rs_data_EX(rs_data_EX),
        .rt_data_EX(rt_data_EX),
        .imm_EX(imm_EX),
        .rd_addr_EX(rd_addr_EX),

        .alu_overflow(alu_overflow),
        // Control signals from ID/EX pipeline registers
        .reg_write_en_EX(reg_write_en_EX),
        .muxA_con_EX(muxA_con_EX),
        .muxB_con_EX(muxB_con_EX),
        .alu_op_EX(alu_op_EX),
        .mem_write_en_EX(mem_write_en_EX),
        .mux_writeback_con_EX(mux_writeback_con_EX),
        .mem_enable_EX(mem_enable_EX),

        // Datapath outputs to MEM stage
        .alu_res_MEM(alu_res_MEM),
        .rt_data_MEM(rt_data_MEM),
        .pc_MEM(pc_MEM),
        .rd_addr_MEM(rd_addr_MEM),

        // Control signals forwarded to MEM stage
        .reg_write_en_MEM(reg_write_en_MEM),
        .mem_write_en_MEM(mem_write_en_MEM),
        .mux_writeback_con_MEM(mux_writeback_con_MEM),
        .mem_enable_MEM(mem_enable_MEM)
        
    );
    
    // MEM Stage Instantiation
    MEM_Stage MEM_Stage_inst(
        .clk(clk),
        .rst(rst),

        // Inputs from EX stage
        .alu_res_MEM(alu_res_MEM),
        .rt_data_MEM(rt_data_MEM),
        .pc_MEM(pc_MEM),
        .rd_addr_MEM(rd_addr_MEM),
        .reg_write_en_MEM(reg_write_en_MEM),
        .mem_write_en_MEM(mem_write_en_MEM),
        .mux_writeback_con_MEM(mux_writeback_con_MEM),
        .mem_enable_MEM(mem_enable_MEM),
        
        // Outputs to WB stage (Pipeline Registers)
        .reg_write_en_WB(reg_write_en_WB),
        .alu_res_WB(alu_res_WB),
        .pc_WB(pc_WB),
        .memdata_WB(memdata_WB),
        .mux_writeback_con_WB(mux_writeback_con_WB),
        .rd_addr_WB(rd_addr_WB)
    );
    
    // WB Stage Instantiation
    WB_Stage WB_Stage_inst(
        // Inputs from MEM/WB registers
        .alu_res_WB(alu_res_WB),
        .pc_WB(pc_WB),
        .memdata_WB(memdata_WB),
        .mux_writeback_con_WB(mux_writeback_con_WB),
        
        // Final selected data to be written to reg_bank
        .write_back_data_WB(write_back_data_WB)
    );
    
endmodule