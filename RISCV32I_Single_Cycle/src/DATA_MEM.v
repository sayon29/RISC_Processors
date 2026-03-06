module DATA_MEM(
    input clka,
    input [6:0] addra,
    input [3:0] w_en,
    input enable,
    input [31:0] dina,
    output [31:0] douta
);

reg [31:0] mem [127:0];

initial begin
    $readmemh("datamem.mem", mem);
end

assign douta =(w_en==4'b0000 && enable==1)?mem[addra]:0;

always @(*)begin
    if(enable==1)begin
        if(w_en==4'b0001) mem [addra]=dina[7:0]; //SB
        else if(w_en==4'b0011) mem [addra]=dina[15:0]; //SH
        else if(w_en==4'b1111) mem [addra]=dina[31:0]; //SW
    end
end

endmodule