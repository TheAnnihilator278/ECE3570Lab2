`timescale 1ns / 1ns
`include "ALU.v"
`include "Registers.v"
`include "ControlUnit.v"
`include "FetchUnit.v"
`include "Memory.v"

//////////////////////////////////////////////////////////////////////////////////
// Company: Western Michigan University
// Engineer: Tyler Thompson
// 
// Create Date: 02/22/2018 04:42:19 PM
// Design Name: 
// Module Name: CPU
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

module CPU10Bits_Test();
    reg clk;
    reg reset;
    wire [9:0] program_result;
    wire done;

    //CPU10Bits cpu0( .clk(clk), .reset(reset), .done(done), .program_result(program_result) );
    CPU10Bits_Pipelined cpu0( .clk(clk), .reset(reset), .done(done), .program_result(program_result) );
    
    //toggle clock every 18ns
    always #18 clk = ~clk;
    
    initial begin
        clk = 1; 
        reset = 1;
        #36;
        reset = 0;
    end
    
endmodule
 
 
module CPU10Bits_Pipelined(
    input wire clk,
    input wire reset,
    output reg done,
    output reg [9:0] program_result
    );
    
    
    reg [37:0] pipe_reg1_in;
    wire [37:0] pipe_reg1_out;
    reg [12:0] pipe_reg2_in;
    wire [12:0] pipe_reg2_out;
    
    wire mem_to_reg;
    wire mem_write;
    wire [2:0] reg_write_addr_return;
    wire [1:0] ALU_op;
    wire [9:0] alu_source1;
    wire [9:0] alu_source2;
    wire [9:0] read_data2;
    wire [9:0] instruction;
       
    Fetch_Decode_Stage( .clk(clk),
                        .reset(reset),
                        .alu_result( ), // input from writeback
                        .reg_write_data( ), // input from writeback
                        .reg_write_addr( ), // input from writeback
                        .mem_to_reg(mem_to_reg), 
                        .mem_write(mem_write),
                        .reg_write_addr_return(reg_write_addr_return), 
                        .ALU_op(ALU_op), 
                        .alu_source1(alu_source1), 
                        .alu_source2(alu_source2),
                        .read_data2(read_data2),
                        .instruction(instruction)        
                         );
    
    // pipe_reg1
    Register_Pipeline_37bit( .clk(clk), .reset(reset), .write_en(1'b1), .Din(pipe_reg1_in), .Dout(pipe_reg1_out) );
    
    Execute_Memory_Stage( );
    
    // pipe_reg2
    Register_Pipeline_13bit( .clk(clk), .reset(reset), .write_en(1'b1), .Din(pipe_reg2_in), .Dout(pipe_reg2_out) );
    
    Write_Back_Stage( 
                    
                    );
    
    always@(*)begin
        pipe_reg1_in[0] <= mem_to_reg;
        pipe_reg1_in[1] <= mem_write;
        pipe_reg1_in[2:4] <= reg_write_addr_return;
        pipe_reg1_in[5:6] <= ALU_op;
        pipe_reg1_in[7:16] <= alu_source1;
        pipe_reg1_in[17:26] <= alu_source2;
        pipe_reg1_in[27:36] <= read_data2;
        
        
         //program_result <= alu_result;
           // halt 
          if ( instruction[9:7] == 3'b111 && instruction[1:0] == 2'b11 ) begin            
               done <= 1'b1;   
          end
          else begin              
               done <= 1'b0;
          end 
    end
    
endmodule

module Fetch_Decode_Stage(
    input wire clk,
    input wire reset,
    input wire [9:0] alu_result,  // tied to fetch unit for write back, used from branch control
    input wire [9:0] reg_write_data, // tied to register file for write back
    input wire [2:0] reg_write_addr, // tied to register file for write back
    output reg mem_to_reg, // control line
    output reg mem_write, // control line 
    output reg [1:0] ALU_op,  // control line
    output reg [9:0] alu_source1,   // ALU
    output reg [9:0] alu_source2,  // ALU
    output reg [9:0] read_data2,  // control line
    output reg [2:0] reg_write_addr_return, // control line, returned from control unit
    output reg [9:0] instruction
    );
    
    //wire [9:0] instruction;
    wire [9:0]PC;
    wire [1:0]pc_control;
    wire [2:0]reg_read1_addr; // source select
    wire [9:0]read1_data;
    wire [9:0]read2_data; 
    wire reg_write;
    wire alu_source1_control;
    wire [1:0]alu_source2_control;
    
    FetchUnit fu0( .clk(clk), .reset(reset), .pc_control(pc_control), .branch_control(alu_result), .jump_address(instruction[6:2]), .branch_address(instruction[2:0]), .reg_address(read1_data), .PC_out(PC), .instruction(instruction) );
         
    ControlUnit cu0( .instruction(instruction), .ALU_op(ALU_op), .reg_write(reg_write), .reg_write_addr(reg_write_addr), .reg_read1_addr(reg_read1_addr), .alu_source1_control(alu_source1_control), .alu_source2_control(alu_source2_control), .pc_control(pc_control), .mem_write(mem_write), .mem_to_reg(mem_to_reg) );
            
    RegisterFile rf0( .clk(clk), .reset(reset), .en_write(reg_write), .write_addr(reg_write_addr_return), .write_data(reg_write_data), .read1_addr(reg_read1_addr), .read2_addr(instruction[4:3]), .read1_data(read1_data), .read2_data(read2_data) );
    
    ALU_source1_mux asm1( .alu_source1_select(alu_source1_control), .reg_read1_data(read1_data), .pc(PC), .alu_source(alu_source1) );
        
    ALU_source2_mux asm2( .alu_source2_select(alu_source2_control), .reg_read2_data(read2_data), .imm(instruction[2:0]), .jump_link_offset(10'b0000000001), .alu_source(alu_source2) );
           
endmodule

module Execute_Memory_Stage(

    );
    
endmodule

module Write_Back_Stage(

    );
    
endmodule

module CPU10Bits(
    //input wire [9:0] instruction,
    input wire clk,
    input wire reset,
    output reg done,
    output reg [9:0] program_result
    );
    
    wire [1:0]ALU_op;
    wire reg_write;
    wire [2:0] reg_write_addr; // destination select
    wire [9:0] reg_write_data;
    wire [9:0]alu_source1; // ALU input a
    wire [9:0]alu_source2; // ALU input b
    wire alu_source1_control;
    wire [1:0]alu_source2_control;
    wire [1:0]pc_control;
    wire [9:0]PC;
    wire c_out;
    wire [9:0]alu_result;
    wire [2:0]reg_read1_addr; // source select
    wire [9:0]read1_data;
    wire [9:0]read2_data;   
    wire [9:0] instruction;
    wire [9:0] mem_read_data;
    wire mem_write;
    wire mem_to_reg;

    
    
    DataMemory dm0( .clk(clk), .address(alu_result), .en_write(mem_write), .write_data(read2_data), .read_data(mem_read_data) );
    
    ControlUnit cu0( .instruction(instruction), .ALU_op(ALU_op), .reg_write(reg_write), .reg_write_addr(reg_write_addr), .reg_read1_addr(reg_read1_addr), .alu_source1_control(alu_source1_control), .alu_source2_control(alu_source2_control), .pc_control(pc_control), .mem_write(mem_write), .mem_to_reg(mem_to_reg) );
    
    FetchUnit fu0( .clk(clk), .reset(reset), .pc_control(pc_control), .branch_control(alu_result), .jump_address(instruction[6:2]), .branch_address(instruction[2:0]), .reg_address(read1_data), .PC_out(PC), .instruction(instruction) );
     
    RegisterFile rf( .clk(clk), .reset(reset), .en_write(reg_write), .write_addr(reg_write_addr), .write_data(reg_write_data), .read1_addr(reg_read1_addr), .read2_addr(instruction[4:3]), .read1_data(read1_data), .read2_data(read2_data) );
    
    ALU alu0( .ALU_op(ALU_op), .a(alu_source1), .b(alu_source2), .f(alu_result), .c_out(c_out) );
    
    ALU_source1_mux asm1( .alu_source1_select(alu_source1_control), .reg_read1_data(read1_data), .pc(PC), .alu_source(alu_source1) );
    
    ALU_source2_mux asm2( .alu_source2_select(alu_source2_control), .reg_read2_data(read2_data), .imm(instruction[2:0]), .jump_link_offset(10'b0000000001), .alu_source(alu_source2) );
    
    write_data_mux wdm0( .write_data_select(mem_to_reg), .alu_result(alu_result), .read_data(mem_read_data), .write_data(reg_write_data) );
    
    always@(*) begin
        program_result <= alu_result;
        // halt 
       if ( instruction[9:7] == 3'b111 && instruction[1:0] == 2'b11 ) begin
            
            done <= 1'b1;   
       end
       else begin
            
            done <= 1'b0;
       end 
    end
    
endmodule

// ALU Source 1 Mux
// alu_source1_select:
//  0 -> reg_read1_data
//  1 -> PC
module ALU_source1_mux(
    input wire alu_source1_select,
    input wire [9:0]reg_read1_data,
    input wire [9:0]pc,
    output reg [9:0]alu_source
    );
    always@(*)begin
        case(alu_source1_select)
            1'b1: alu_source <= pc;
            1'b0: alu_source <= reg_read1_data;
            default: alu_source <= reg_read1_data;
        endcase
    end
endmodule

// ALU Source 2 Mux
// alu_source2_select:
//  00 -> reg_read2_data
//  01 -> imm - sign extend
//  10 -> jump_link_offset
module ALU_source2_mux(
    input wire [1:0]alu_source2_select,
    input wire [9:0]reg_read2_data,
    input wire [2:0]imm,
    input wire [9:0]jump_link_offset,
    output reg [9:0]alu_source
    );
    always@(*)begin
        case(alu_source2_select)
            2'b00: alu_source <= reg_read2_data;
            2'b01: alu_source <= { {7{imm[2]}}, imm[2:0] }; //sign extend imm
            2'b10: alu_source <= jump_link_offset;
            default: alu_source <= reg_read2_data;
        endcase
    end
endmodule

// Register write data mux
// wire_data_select:
//  1 -> read_data
//  0 -> alu_result
module write_data_mux(
    input wire write_data_select,
    input wire [9:0]alu_result,
    input wire [9:0]read_data,
    output reg [9:0]write_data
    );
    always@(*)begin
        case(write_data_select)
            1'b1: write_data <= read_data;
            1'b0: write_data <= alu_result;
            default: write_data <= alu_result;
        endcase
    end
endmodule