`timescale 1ns/1ps

module risc_processor_tb;

    reg clk;
    reg rst;

    wire [31:0] alu_result;
    wire [31:0] npc;
    wire [31:0] rd_data;

    // Instantiate DUT
    risc_processor uut (
        .clk(clk),
        .rst(rst),
        .alu_result(alu_result),
        .npc(npc),
        .rd_data(rd_data)
    );

    // Clock generation (10ns period)
    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;

        // Apply reset
        #10;
        rst = 0;

        // Run for enough cycles
        #300;

        $finish;
    end


    // ----------- DEBUG PRINT EVERY CYCLE -----------
    always @(posedge clk) begin
        $display("--------------------------------------------------------------------");
        $display("PC=%0d | PC+1=%0d | NPC=%0d",
                 uut.datapath_inst.pc_reg,
                 uut.datapath_inst.pc_plus_one,
                 npc);

        $display("ALU_SRC_A=%h | ALU_SRC_B=%h",
                 uut.datapath_inst.alu_src_a,
                 uut.datapath_inst.alu_src_b);

        $display("ALU_RESULT=%h | RD_DATA=%h",
                 alu_result,
                 rd_data);
                 
        $display("INSTRUCTION=%h",
             uut.datapath_inst.instruction);
             
        $display("RS2 ADDR=%h",
             uut.datapath_inst.rs2_addr);
             
        $display("R ADDR B=%h",
             uut.datapath_inst.reg_file_inst.r_addr_b);
             
        $display("--------------------------------------------------------------------");
    end

endmodule