module risc_processor(
    input  wire        clk,
    input  wire        rst,
    output wire [31:0] alu_result,
    output wire [31:0] npc,
    output wire [31:0] rd_data
    
);

    // Internal Wires
    wire [31:0] instruction;
    wire        reg_write_en, alu_srcA, alu_srcB, dest_reg_sel;
    wire [3:0]  alu_op, mem_write_en;
    wire [1:0]  write_back;
    wire        alu_overflow;
    wire        mem_enable;

    // 1. Datapath 
    datapath datapath_inst (
        .clk(clk),
        .rst(rst),
        .reg_write_en(reg_write_en),
        .alu_src_A(alu_srcA),
        .alu_src_B(alu_srcB),
        .alu_op(alu_op),
        .mem_write_en(mem_write_en),
        .write_back(write_back),
        .instruction(instruction), 
        .alu_result(alu_result),
        .alu_overflow(alu_overflow),
        .mem_enable(mem_enable),
        .write_back_data(rd_data),
        .pc_reg(npc)
        
    );

    // 2. Control Unit
    control_unit control_inst (
        .clk(clk),
        .rst(rst),
        .instruction(instruction), 
        .reg_write_en(reg_write_en),
        .alu_srcA(alu_srcA),
        .alu_srcB(alu_srcB),
        .alu_op(alu_op),
        .mem_write_en(mem_write_en),
        .write_back(write_back),
        .mem_enable(mem_enable)
    );
    
endmodule