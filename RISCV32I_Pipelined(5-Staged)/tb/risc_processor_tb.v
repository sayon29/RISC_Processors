`timescale 1ns / 1ps

module risc_processor_tb();

    // Inputs
    reg clk;
    reg rst;

    // Outputs
    wire [31:0] alu_result;
    wire [31:0] npc;
    wire [31:0] rd_data;

    // Instantiate Top Level Processor
    risc_processor uut (
        .clk(clk),
        .rst(rst),
        .alu_result(alu_result),
        .npc(npc),
        .rd_data(rd_data)
    );

    // Clock Generation (100MHz)
    always #5 clk = ~clk;

    initial begin
        // Initialize
        clk = 0;
        rst = 1;

        // Hold reset for 2 cycles
        #10 rst = 0;

        // Run simulation for 20 cycles to see instruction flow
        #200;
        $display("\nSimulation Complete.");
        $finish;
    end

    // Formatted Pipeline Monitor
    always @(posedge clk) begin
        #1; // Wait for signals to settle after clock edge
        $display("\n==================== TIME: %0t ====================", $time);
        
        // IF STAGE
        $display("--- IF STAGE ---");
        // Accessing pc_net inside datapath -> IF_Stage [cite: 1, 3]
        $display("PC_Net (Current): %h", uut.datapath_inst.IF_Stage_inst.pc_net);
        $display("PC_Plus_One:      %h", uut.datapath_inst.IF_Stage_inst.pc_plus_one);
        $display("Branch Taken:      %h", uut.datapath_inst.IF_Stage_inst.branch_taken);
         $display("PC_plus_off:      %h", uut.datapath_inst.IF_Stage_inst.pc_plus_off);
        
        // ID STAGE
        $display("\n--- ID STAGE ---");
        $display("Instruction: %h", uut.datapath_inst.instruction_ID); 
        $display("PC_ID:       %h", uut.datapath_inst.pc_ID); 
        $display("FWD_MUX1_DATA: %h", uut.datapath_inst.ID_Stage_inst.fwd_mux_data1); 
        $display("FWD_MUX2_DATA: %h", uut.datapath_inst.ID_Stage_inst.fwd_mux_data2); 
        $display("RD_Addr_ID:  %d", uut.datapath_inst.rd_addr_ID); 
        $display("IMM_out:     %h", uut.datapath_inst.ID_Stage_inst.imm_out_net);
        $display("FREEZE PC DF: %h", uut.datapath_inst.ID_Stage_inst.hazard_control_inst.freeze_PC_DF);
        $display("FLUSH IF BP: %h", uut.datapath_inst.ID_Stage_inst.hazard_control_inst.flush_IF_BP);  
        $display("FREEZE IF DF: %h", uut.datapath_inst.ID_Stage_inst.hazard_control_inst.freeze_IF_DF);
        $display("FLUSH ID DF: %h", uut.datapath_inst.ID_Stage_inst.hazard_control_inst.flush_ID_DF);
        $display("FLUSH ID BD: %h", uut.datapath_inst.ID_Stage_inst.hazard_control_inst.flush_ID_BD);  
        $display("FLUSH IF BD: %h", uut.datapath_inst.ID_Stage_inst.hazard_control_inst.flush_IF_BD);
        $display("CHECK RS1: %h", uut.datapath_inst.ID_Stage_inst.dataforwarding_control_inst.check_rs1);
        $display("CHECK RS2: %h", uut.datapath_inst.ID_Stage_inst.dataforwarding_control_inst.check_rs2);
        $display("FWD CON 1: %h", uut.datapath_inst.ID_Stage_inst.dataforwarding_control_inst.fwd_con1);
        $display("FWD CON 2: %h", uut.datapath_inst.ID_Stage_inst.dataforwarding_control_inst.fwd_con2);
        $display("FWD CON 3: %h", uut.datapath_inst.ID_Stage_inst.dataforwarding_control_inst.fwd_con3);
        $display("FWD CON 4: %h", uut.datapath_inst.ID_Stage_inst.dataforwarding_control_inst.fwd_con4);
        $display("REG WRITE EN EX: %h", uut.datapath_inst.ID_Stage_inst.reg_write_en_EX);
        $display("REG WRITE EN MEM: %h", uut.datapath_inst.ID_Stage_inst.reg_write_en_MEM);
        $display("RD ADDR MEM: %h", uut.datapath_inst.ID_Stage_inst.dataforwarding_control_inst.rd_addr_MEM);
        $display("REG WRITE EN WB: %h", uut.datapath_inst.ID_Stage_inst.dataforwarding_control_inst.reg_write_en_WB);
        $display("RD ADDR WB: %h", uut.datapath_inst.ID_Stage_inst.dataforwarding_control_inst.rd_addr_WB);
        $display("INS_ID:    %b", uut.datapath_inst.ID_Stage_inst.instruction_ID);
        $display("INS OUT:    %b", uut.datapath_inst.ID_Stage_inst.instruction_reg_EX.out);
        $display("INS_IN:    %b", uut.datapath_inst.ID_Stage_inst.instruction_reg_EX.in);
        $display("FLUSH:    %b", uut.datapath_inst.ID_Stage_inst.instruction_reg_EX.flush);
         $display("FREEZE:    %b", uut.datapath_inst.ID_Stage_inst.instruction_reg_EX.freeze);
        // EX STAGE
        $display("\n--- EX STAGE ---");
        $display("PC_EX:       %h", uut.datapath_inst.pc_EX); 
        $display("MUXA_OUT:    %h", uut.datapath_inst.EX_Stage_inst.muxA_out); 
        $display("MUXB_OUT:    %h", uut.datapath_inst.EX_Stage_inst.muxB_out); 
        $display("Imm_EX:      %h", uut.datapath_inst.imm_EX); 
        $display("ALU_Out_Net: %h", uut.datapath_inst.EX_Stage_inst.alu_result_net);
        $display("Overflow:    %b", uut.alu_overflow); 
        $display("ALUOP_EX:    %h", uut.datapath_inst.alu_op_EX); 
        $display("RDADDR_EX:    %h", uut.datapath_inst.rd_addr_EX); 
        $display("CARRY BIT:    %h", uut.datapath_inst.EX_Stage_inst.alu_carry);
        $display("REAL PC CON:    %h", uut.datapath_inst.EX_Stage_inst.branch_decision_inst.real_pc_con);
        $display("WRONG PRED:    %h", uut.datapath_inst.EX_Stage_inst.branch_decision_inst.wrong_pred);
        $display("RS1 DATA:    %h", uut.datapath_inst.EX_Stage_inst.branch_decision_inst.rs1_data);
        $display("RS2 DATA:    %h", uut.datapath_inst.EX_Stage_inst.branch_decision_inst.rs2_data);
        $display("OPCODE:    %b", uut.datapath_inst.EX_Stage_inst.branch_decision_inst.opcode);
        $display("FUNCT3:    %b", uut.datapath_inst.EX_Stage_inst.branch_decision_inst.funct3);
        $display("INS:    %b", uut.datapath_inst.EX_Stage_inst.branch_decision_inst.instruction);
        $display("INS_EX:    %b", uut.datapath_inst.EX_Stage_inst.instruction_EX);
        $display("PC_EX:    %b", uut.datapath_inst.EX_Stage_inst.pc_EX);
    
        // MEM STAGE
        $display("\n--- MEM STAGE ---");
        $display("ALU_Res_MEM: %h", uut.datapath_inst.alu_res_MEM); 
        $display("RT_Pass_MEM: %h", uut.datapath_inst.rt_data_MEM); 
        $display("RDADDR_MEM:    %h", uut.datapath_inst.rd_addr_MEM); 
        
        // WB STAGE
        $display("\n--- WB STAGE ---");
        $display("WB_Data:     %h", uut.datapath_inst.write_back_data_WB); 
        $display("Mem_Data:    %h", uut.datapath_inst.memdata_WB); 
        $display("RD_Addr_WB:  %d", uut.datapath_inst.rd_addr_WB); 
        $display("RegWrite_WB: %b", uut.datapath_inst.reg_write_en_WB); 
        $display("====================================================\n");
    end

endmodule