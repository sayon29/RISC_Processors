module control_unit(
    input  wire        clk,
    input  wire        rst,
    input  wire [31:0] instruction,

    output reg         reg_write_en,
    output reg         alu_srcA,
    output reg         alu_srcB,
    output reg  [3:0]  alu_op,
    output reg  [3:0]  mem_write_en,
    output reg  [1:0]  write_back,
    output reg         mem_enable
);

    reg [6:0] opcode;
    reg [6:0] funct7;
    reg [2:0] funct3;
    
    always@(instruction)begin
        opcode = instruction[6:0];
        funct7 = instruction[31:25];
        funct3 = instruction[14:12];
            case(opcode)
                7'b0110011:begin                    //Register and Multiply Type
                    case(funct7)
                        7'd0:begin
                                case(funct3)
                                    3'd0:alu_op=2;  //ADD
                                    3'd1:alu_op=8;  //SLL
                                    3'd2:alu_op=14; //SLT
                                    3'd3:alu_op=15; //SLTU
                                    3'd4:alu_op=4;  //XOR
                                    3'd5:alu_op=7;  //SRL
                                    3'd6:alu_op=5;  //OR
                                    3'd7:alu_op=6;  //AND
                                endcase
                        end
                        7'd32:begin
                                case(funct3)
                                    3'd0:alu_op=3;  //SUB
                                    3'd5:alu_op=9;  //SRA
                                 endcase
                        end
                        7'd1:begin
                                case(funct3)
                                    3'd0:alu_op=10; //MUL
                                    3'd1:alu_op=11; //MULH
                                    3'd4:alu_op=12; //DIV
                                    3'd6:alu_op=13; //REM
                                 endcase
                        end
                        default:alu_op=0;
                        endcase
                end
                7'b1100011:begin     //Branch-type
                    case(funct3)
                    3'd0,3'd1,3'd4,3'd5,3'd6,3'd7:  //BEQ BNE BLT BGE BLTU BGEU
                        alu_op=2;
                    default:alu_op=0;
                    endcase     
                end
                7'b0010011:begin     //Immediate arithmatic-type
                    case(funct3)
                    3'd0:alu_op=2;  //ADDI
                    3'd2:alu_op=14; //SLTI
                    3'd3:alu_op=15; //SLTUI
                    3'd4:alu_op=4;  //XORI
                    3'd6:alu_op=5;  //ORI
                    3'd7:alu_op=6;  //ANDI
                    3'd1: begin if(funct7==0) alu_op=8;  //SLLI
                    end
                    3'd5:begin      
                    if(funct7==0) alu_op=7; //SRLI
                    else if(funct7==32) alu_op=9;   //SRAI
                    end      
                    endcase     
                end
                7'b0000011:begin     //Immediate load-type
                    case(funct3)
                    3'd0,3'd1,3'd2,3'd4,3'd5:   //LB LH LW LBU LHU
                        alu_op=2;
                    default:alu_op=0;
                    endcase     
                end
                7'b0110111:alu_op=1; //LUI
                7'b0100011:begin     //S-type
                    case(funct3)
                    3'd0,3'd1,3'd2:     //SB SH SW
                        alu_op=2;
                    default:alu_op=0;
                    endcase     
                end
                7'b1101111:alu_op=2; //JAL
                7'b0010111:alu_op=2; //AUIPC
                7'b1100111:alu_op=2; //JALR
            endcase
        end
        
    //alu_srcB
    always@(instruction) begin
        opcode = instruction[6:0];
        case(opcode)
            7'b0110011: alu_srcB = 1; //R_type
            default: alu_srcB = 0;  // All Other Types
        endcase
    end
    
    //reg_write_en
    always@(instruction) begin
        opcode = instruction[6:0];
        case(opcode)
            7'b0110111, 7'b1101111, 7'b0000011, 7'b0110011, 7'b0010011, 7'b1100111, 7'b0010111: reg_write_en = 1; //LUI, JAL, L_type, I_type, R_type, JALR, AUIPC
            default: reg_write_en = 0; //B_type, S_type
        endcase
    end
    
    //write_back
    always@(instruction) begin
        opcode = instruction[6:0];
        case(opcode)
           7'b0000011: write_back = 0; //L_type
           7'b0110111, 7'b0110011, 7'b0010011, 7'b0010111: write_back = 1; //LUI, R_type, I_type, AUIPC
           7'b1101111, 7'b1100111: write_back = 2; //JAL, JALR
           default: write_back = 1;
        endcase
    end
    
    //for alu_srcA
    always@(instruction)begin
        opcode= instruction[6:0];
        case(opcode)
            7'b1100011:alu_srcA=0;  //B-type:BEW BNE BLT BGE BLTU BGEU
            7'b1101111:alu_srcA=0;  //J-type:JAL
            7'b0010111:alu_srcA=0;  //AUIPC
            default:alu_srcA=1;
        endcase
    end
    
    //for mem_write_en
    always@(instruction)begin
        opcode= instruction[6:0];
        funct3 = instruction[14:12];
        case(opcode)
            7'b0100011:begin    //S-types
                case(funct3)
                    3'b000:mem_write_en=4'b0001;    //SB
                    3'b001:mem_write_en=4'b0011;    //SH
                    3'b010:mem_write_en=4'b1111;    //SW
                    default:mem_write_en=0;
                endcase
            end 
            default:mem_write_en=0;
        endcase
    end
    
    //for mem_enable (write or read)
    always@(instruction)begin
        opcode= instruction[6:0];
        case(opcode)
            7'b0100011, 7'b0000011 : mem_enable = 1; //L_type, S_type
            default: mem_enable = 0; //Others
        endcase
    end
    
endmodule