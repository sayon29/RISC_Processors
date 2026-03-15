module risc_processor(
    input  wire        clk,
    input  wire        rst,
    output wire [31:0] alu_result,
    output wire [31:0] npc,
    output wire [31:0] rd_data
    
);

    // Internal Wires
    wire [31:0] instruction;
    wire        reg_write_en, muxA_con, muxB_con, dest_reg_sel;
    wire [3:0]  alu_op, mem_write_en;
    wire [1:0]  mux_writeback_con;
    wire        alu_overflow;
    wire        mem_enable;

    // 1. Datapath 
    datapath datapath_inst (
        .clk(clk),
        .rst(rst),
        .reg_write_en(reg_write_en),
        .muxA_con(muxA_con),
        .muxB_con(muxB_con),
        .alu_op(alu_op),
        .mem_write_en(mem_write_en),
        .mux_writeback_con(mux_writeback_con),
        .instruction_ID(instruction), 
        .alu_overflow(alu_overflow),
        .mem_enable(mem_enable),
        .write_back_data_WB(rd_data)
        
    );

    // 2. Control Unit
    control_unit control_inst (
        .clk(clk),
        .rst(rst),
        .instruction(instruction), 
        .reg_write_en(reg_write_en),
        .muxA_con(muxA_con),
        .muxB_con(muxB_con),
        .alu_op(alu_op),
        .mem_write_en(mem_write_en),
        .mux_writeback_con(mux_writeback_con),
        .mem_enable(mem_enable)
    );
    
endmodule