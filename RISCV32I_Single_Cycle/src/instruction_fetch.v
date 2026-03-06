module instruction_fetch(
    input  wire        clk,
    input  wire [6:0] pc_address,  
    output wire [31:0] instruction
);

    INS_MEM instruction_rom_inst (
    .clka(clk),
    .addra(pc_address),
    .douta(instruction)
  );
endmodule