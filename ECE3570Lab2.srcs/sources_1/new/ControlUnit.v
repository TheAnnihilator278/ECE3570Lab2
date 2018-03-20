`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: Western Michigan University
// Engineer: Tyler Thompson
// 
// Create Date: 02/22/2018 03:55:32 PM
// Design Name: 
// Module Name: ControlUnit
// Project Name: ECE 3570 Lab 3a
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module ControlUnitTest();
   reg [9:0] instruction;
   wire [1:0]ALU_op;
   wire reg_write;
   wire [2:0] reg_write_addr;
   wire [2:0] reg_read1_addr;
   wire alu_source1_control;
   wire [1:0]alu_source2_control;
   wire [1:0]pc_control;
    
    ControlUnit cu0( .instruction(instruction), .ALU_op(ALU_op), .reg_write(reg_write), .reg_write_addr(reg_write_addr), .reg_read1_addr(reg_read1_addr), .alu_source1_control(alu_source1_control), .alu_source2_control(alu_source2_control), .pc_control(pc_control) );
    
    initial begin
         instruction = 10'b0000000000;
           #8;
           
           instruction = 10'b1001000011; // addi $t1, $zero, 3
           #8;
           instruction = 10'b1001010011; // addi $t1, $t1, 3
           #8;        
           instruction = 10'b1001010011; // addi $t1, $t1, 3
           #8;
           instruction = 10'b1000100001; // addi $t0, $zero, 1
           #8;
           instruction = 10'b1011001111; // sw $t1, -1($t0)
           #8;
           instruction = 10'b1100110010; // lw $t0, 2($t1)
           #8;
           instruction = 10'b0001101010; // add $s0, $t0, $t1 
           #8;
           instruction = 10'b0001111010; // add $s0, $s0, $t1 
           #8;      
           instruction = 10'b1001111100; // tcp $s0, $s0
           #8;
           instruction = 10'b0011110001; // sll $t0, $s0, $t1 
           #8;
           instruction = 10'b0110100011; // beq $t0, $zero, PC=PC+4+3
           #8;
           instruction = 10'b1001010011; // addi $t1, $t1, 3
           #8;
           instruction = 10'b0110110011; // beq $t0, $t1, PC=PC+4+3
           #8;
           instruction = 10'b1110001100; // jr $s0
           #8;
           instruction = 10'b1110111101; // j 01111 (15)
           #8;
           instruction = 10'b1111000010; // jal 10000 (-16)
           #8;
           instruction = 10'b1001010011; // addi $t1, $t1, 3
           #8;
           instruction = 10'b1110011100; // jr $ra
           #8;
           instruction = 10'b1001010011; // addi $t1, $t1, 3
           #8;
           instruction = 10'b0101110001; // cmp $t0, $s0, $t1 
           #8;
           instruction = 10'b1110000011; // halt
           #8;
        
    end
    
    

endmodule

module ControlUnit(
   input wire [9:0] instruction,
   output reg [1:0]ALU_op,
   output reg reg_write,
   output reg [2:0] reg_write_addr,
   output reg [2:0] reg_read1_addr,
   output reg alu_source1_control,
   output reg [1:0]alu_source2_control,
   output reg [1:0]pc_control,
   output reg mem_write,
   output reg mem_to_reg
  // output reg pc_wait
    );
  
    reg [2:0]op_code;
    reg [1:0]funct_code;
    reg [1:0]rs_addr;
    reg [1:0]rt_addr;
    reg [2:0]rd_addr; //also hold immediate value for I type instructions
    reg [4:0]j_addr;
    
    wire reg_write_mux_val;
    reg_write_mux rwm0( .op_code(op_code), .funct_code(funct_code), .reg_write(reg_write_mux_val) );
    
    wire [1:0]ALU_op_mux_val;
    ALU_op_mux aom0( .op_code(op_code), .rd_addr(rd_addr), .tcp(2'b11), .ALU_op(ALU_op_mux_val) );

    wire [1:0]pc_control_mux_val;
    pc_control_mux pcm0( .op_code(op_code), .funct_code(funct_code), .pc_control(pc_control_mux_val) );
    
    wire [2:0]reg_write_addr_control_val;
    reg_write_addr_control_mux rwacm0( .op_code(op_code), .rd_addr(rd_addr), .rs_addr(rs_addr), .write_addr(reg_write_addr_control_val) );
    
    wire [2:0]reg_read1_addr_mux_val; 
    reg_read1_addr_mux rram0( .op_code(op_code), .funct_code(funct_code), .rd_addr(rd_addr), .rs_addr(rs_addr), .rt_addr(rt_addr), .j_addr(j_addr), .read_addr(reg_read1_addr_mux_val) );
    
    wire alu_source1_control_mux_val;
    ALU_source1_control_mux asm1( .op_code(op_code), .funct_code(funct_code), .control(alu_source1_control_mux_val) );
    
    wire [1:0] alu_source2_control_mux_val;
    ALU_source2_control_mux asm2( .op_code(op_code), .funct_code(funct_code), .control(alu_source2_control_mux_val) );
    
    wire mem_write_mux_val;
    mem_write_mux mwm0( .op_code(op_code), .mem_write(mem_write_mux_val) );
    
    wire mem_to_reg_mux_val;
    mem_to_reg_mux mtrm0( .op_code(op_code), .mem_to_reg(mem_to_reg_mux_val) );
    
    //wire pc_wait_mux_val;
   // pc_wait_mux pwm0( .op_code(op_code), .pc_wait(pc_wait_mux_val) );
    
    always@(*) begin
        // instruction decode
        op_code <= instruction[9:7];
        funct_code <= instruction[1:0];
        rs_addr <= instruction[6:5];
        rt_addr <= instruction[4:3];
        rd_addr <= instruction[2:0];
        j_addr <= instruction[6:2];
    
    
       reg_write <= reg_write_mux_val;
       ALU_op <= ALU_op_mux_val;
       pc_control <= pc_control_mux_val;
       reg_write_addr <= reg_write_addr_control_val;
       reg_read1_addr <= reg_read1_addr_mux_val;
       alu_source1_control <= alu_source1_control_mux_val;
       alu_source2_control <= alu_source2_control_mux_val;
       mem_write <= mem_write_mux_val;
       mem_to_reg <= mem_to_reg_mux_val;
      // pc_wait <= pc_wait_mux_val;
   
    end
    
endmodule

module pc_wait_mux(
    input wire [2:0] op_code,
    output reg pc_wait
    );
    reg pc_wait_store;
     always@(*)begin
           case(op_code)
               3'b110: begin // lw
                            if ( pc_wait_store == 1'b0 )begin
                                pc_wait_store <= 1'b1;
                            end
                            else begin
                                pc_wait_store <= 1'b0;
                            end
                        end
               default: begin
                            pc_wait_store <= 1'b0;
                        end
           endcase
           pc_wait <= pc_wait_store;
      end
endmodule

module mem_write_mux(
    input wire [2:0] op_code,
    output reg mem_write
    );
    always@(*)begin
        case(op_code)
            3'b101: mem_write <= 1'b1; // sw
            default: mem_write <= 1'b0;
        endcase
   end
endmodule

module mem_to_reg_mux(
    input wire [2:0] op_code,
    output reg mem_to_reg
    );
    always@(*)begin
        case(op_code)
            3'b110: mem_to_reg <= 1'b1; // lw
            default: mem_to_reg <= 1'b0;
        endcase
    end                
endmodule

// read1_addr
module reg_read1_addr_mux(
        input wire [2:0] op_code,
        input wire [1:0] funct_code,
        input wire [2:0] rd_addr,
        input wire [1:0] rs_addr,
        input wire [1:0] rt_addr,
        input wire [4:0] j_addr,
        output reg [2:0] read_addr
    );
    always@(*)begin
            case(op_code)
                3'b000: read_addr <= rd_addr; // add
                3'b100: read_addr <= rt_addr; // addi
                3'b101: read_addr <= rs_addr; // sw
                3'b110: read_addr <= rt_addr; // lw
                3'b111: begin
                            case(funct_code)
                                2'b00: read_addr <= j_addr; // jr
                                default: read_addr <= rs_addr;
                            endcase
                        end
                default: read_addr <= rs_addr; 
            endcase
        end
endmodule

module reg_write_addr_control_mux(
    input wire [2:0] op_code,
    input wire [2:0] rd_addr,
    input wire [1:0] rs_addr,
    output reg [2:0] write_addr
    );
    always@(*)begin
        case(op_code)
            3'b000: write_addr <= rs_addr; // add
            3'b100: write_addr <= rs_addr; // addi
            3'b110: write_addr <= rs_addr; // lw
            3'b101: write_addr <= rs_addr; // sw
            3'b111: write_addr <= 3'b111; // jal
            default: write_addr <= rd_addr;
        endcase
    end
endmodule

// ALU Source 1 Control
// control:
//  0 -> reg_read1_data
//  1 -> PC
module ALU_source1_control_mux(
    input wire [2:0] op_code,
    input wire [1:0] funct_code,
    output reg control
    );
    always@(*)begin
        case(op_code)
            3'b111: begin
                        case(funct_code)
                            2'b10: control <= 1'b1; // jal 
                            default: control <= 1'b0;            
                        endcase
                    end
            default: control <= 0;
        endcase
    end
endmodule

// ALU Source 2 Control
// control:
//  00 -> reg_read2_data
//  01 -> imm - sign extend
//  10 -> jump_link_offset
module ALU_source2_control_mux(
    input wire [2:0] op_code,
    input wire [1:0] funct_code,
    output reg [1:0]control
    );
    always@(*) begin
        case(op_code)
            3'b100: control <= 1'b01; // addi
            3'b110: control <= 1'b01; // lw
            3'b101: control <= 1'b01; // sw 
            3'b111: begin
                        case(funct_code)
                            2'b10: control <= 2'b10; // jal
                            default: control <= 1'b00;
                        endcase
                    end
            default: control <= 1'b00;
        endcase
    end
endmodule

module pc_control_mux(
    input wire [2:0] op_code,
    input wire [1:0] funct_code,
    output reg [1:0] pc_control
    );
    
    always@(*) begin
        case(op_code)
            3'b011: pc_control <= 2'b11; // beq - branch
            3'b111: begin // J-type
                        case(funct_code)
                            2'b00: pc_control <= 2'b10; // jump_reg
                            default: pc_control <= 2'b01;  // jump
                        endcase
                    end
            default: pc_control <= 2'b00; 
        endcase
    end
    
endmodule  

module ALU_op_mux(
    input wire [2:0] op_code,
    input wire [2:0] rd_addr,
    input wire [1:0] tcp,
    output reg [1:0] ALU_op
    );
    
    always@(*) begin
        case(op_code)
            //3'b000: ALU_op <= 2'b00; //add
            3'b001: ALU_op <= 2'b10; //sll
            3'b010: ALU_op <= 2'b01; //cmp
            3'b011: ALU_op <= 2'b01; //beq
            3'b100: begin
                        case(rd_addr)
                            3'b100: ALU_op <= tcp; //tcp Twos complement
                            default: ALU_op <= 2'b00; //addi
                        endcase        
                    end
            default: ALU_op <= 2'b00;  
        endcase
    end        
    
endmodule    

module reg_write_mux(
    input wire [2:0] op_code,
    input wire [1:0] funct_code,
    output reg reg_write
    );
    always@(*) begin           
            case(op_code)
                3'b011: reg_write <= 0; //beq
                3'b101: reg_write <= 0; //sw:
                3'b111: begin   // j-type
                            case(funct_code)
                                2'b10: reg_write <= 1; // jal
                                default: reg_write <= 0;
                            endcase
                        end
                default: reg_write <= 1;   
            endcase
    end
endmodule    
