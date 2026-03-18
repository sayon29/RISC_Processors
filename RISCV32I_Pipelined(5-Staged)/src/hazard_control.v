`timescale 1ns / 1ps



module hazard_control(input flush_ID_DF,
                       input freeze_PC_DF,
                       input freeze_IF_DF,
                       input flush_ID_BD,
                       input flush_IF_BP,
                       input flush_IF_BD,
                       output flush_ID,
                       output freeze_IF,
                       output flush_IF,
                       output freeze_PC);
                       
assign flush_ID=  flush_ID_DF || flush_ID_BD ;
assign freeze_PC=  freeze_PC_DF;
assign flush_IF= flush_IF_BD || (flush_IF_BP && !freeze_IF_DF);
assign freeze_IF= freeze_IF_DF;

endmodule
