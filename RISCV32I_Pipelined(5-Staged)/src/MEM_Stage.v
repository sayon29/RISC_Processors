`timescale 1ns / 1ps

module MEM_Stage(output reg_write_en_WB,
                 output [31:0] alu_res_WB,
                 output [31:0] pc_WB,
                 output [31:0] memdata_WB,
                 output [1:0] mux_writeback_con_WB,
                 output [4:0]  rd_addr_WB,
                 input [31:0] pc_MEM ,
                 input [4:0]  rd_addr_MEM,
                 input clk, 
                 input [31:0]rt_data_MEM,
                 input [31:0]alu_res_MEM,
                 input [3:0]mem_write_en_MEM,
                 input [1:0]mux_writeback_con_MEM,
                 input  mem_enable_MEM,
                 input  reg_write_en_MEM ,
                 input wire rst );

//data_memory
data_mem data_mem_inst(.out(memdata_WB),
                       .clk(clk),
                       .mem_write_en(mem_write_en_MEM),
                       .addr(alu_res_MEM),
                       .in(rt_data_MEM),
                       .enable(mem_enable_MEM));

//PC Reg                     
register_32bit pcreg_MEM(.out(pc_WB),
                         .in(pc_MEM),
                         .clk(clk),
                         .flush(0),
                         .freeze(0),
                         .rst(rst));

//ALU Result                         
register_32bit alu_resreg_MEM(.out(alu_res_WB),
                              .in(alu_res_MEM),
                              .clk(clk),
                              .flush(0),
                              .freeze(0),
                              .rst(rst));
                              
//MUX writeback control signal register                    
register_2bit mux_writeback_conreg_MEM(.out(mux_writeback_con_WB),
                                       .in(mux_writeback_con_MEM),
                                       .clk(clk),
                                       .flush(0),
                                       .rst(rst));

//Reg writeback control signal                                 
register_1bit regwrite_enreg_MEM(.out(reg_write_en_WB),
                                 .in(reg_write_en_MEM),
                                 .clk(clk),
                                 .flush(0),
                                 .rst(rst));

//Rd addr register for WB
register_5bit rd_addrreg_MEM(.out(rd_addr_WB),
                          .in(rd_addr_MEM),
                          .clk(clk),
                          .flush(0),
                          .freeze(0),
                          .rst(rst));

endmodule