
module data_memory (
  input wire clk,
  input wire [3:0] wea,         
  input wire [6:0] addra,
  input wire [31:0] dina,
  input wire enable,
  output wire [31:0] douta
);

  DATA_MEM ram_instance (
    .clka(clk),
    .enable(enable),
    .w_en(wea), 
    .addra(addra),
    .dina(dina),
    .douta(douta)
  );

endmodule