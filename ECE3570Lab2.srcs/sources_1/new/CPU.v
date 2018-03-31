`timescale 1ns / 1ns
`include "ALU.v"
`include "Registers.v"
`include "ControlUnit.v"
`include "FetchUnit.v"
`include "Memory.v"
`include "ForwardingUnit.v"

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
    reg enable_forwarding;

    //CPU10Bits cpu0( .clk(clk), .reset(reset), .done(done), .program_result(program_result) );
    CPU10Bits_Pipelined cpu0( .clk(clk), .reset(reset), .enable_forwarding(enable_forwarding), .done(done), .program_result(program_result) );
    
    //toggle clock every 18ns
    always #18 clk = ~clk;
    
    initial begin
        enable_forwarding = 1;
        clk = 1; 
        reset = 1;
        #36;
        reset = 0;
    end
    
endmodule
 
 
module CPU10Bits_Pipelined(
    input wire clk,
    input wire reset,
    input wire enable_forwarding, // forwarding unit enable
    output reg done,
    output reg [9:0] program_result
    );
    
    
    wire [37:0] pipe_reg1_in;
    wire [37:0] pipe_reg1_out;
    wire [13:0] pipe_reg2_in;
    wire [13:0] pipe_reg2_out;
    
    wire mem_to_reg;
    wire mem_write;

    wire [1:0] ALU_op;
    wire [9:0] alu_source1;
    wire [9:0] alu_source2;
    
    wire alu_source_1_select;
    wire [1:0] alu_source_2_select;
    
    wire [9:0] read_data2;
    wire [9:0] instruction;
    
    wire reg_write_fd;
    wire reg_write_em;
    wire reg_write_wb;
    
    wire [2:0] write_addr_fd; // output from fetch/decode
    wire [2:0] write_addr_em; // output from execute/memory
    wire [9:0] write_data_em; // output from execute/memory
    wire [2:0] write_addr_wb; // output from write back
    wire [9:0] write_data_wb; // output from write back
       
    wire [9:0] alu_data_1_forwarded; // output of forwarding unit, input to pipe reg 1
    wire [9:0] alu_data_2_forwarded; // output of forwarding unit, input to pipe reg 1
    
    wire [2:0] reg_source_1_addr; // output of crontrol unit from fetch/decode stage, input to forwarding unit
   
    
    
    ForwardingUnit fwu0( .enable(enable_forwarding),
                         .reg_source_1_addr_fd(reg_source_1_addr), // output of fetch/decode stage - reg address
                         .reg_source_2_addr_fd(instruction[4:3]), // output of fetch/decode stage - reg address
                         .alu_source_1_data_fd(alu_source1), // output of fetch/decode stage - reg data
                         .alu_source_2_data_fd(alu_source2), // output of fetch/decode stage - reg data
                         
                         .alu_source_1_select(alu_source_1_select),
                         .alu_source_2_select(alu_source_2_select),
                         
                         .reg_dest_addr_em(write_addr_em), // output of execute/memory stage - reg address
                         .execute_result_em(write_data_em), // output of execute/memory stage - write back data
                         
                         .alu_source_1_data_forwarded(alu_data_1_forwarded), // input to pipe reg 1
                         .alu_source_2_data_forwarded(alu_data_2_forwarded) // input to pipe reg 1
                          );
       
    Fetch_Decode_Stage fds0( .clk(clk),
                        .reset(reset),
                        .reg_write_in(reg_write_wb),                  

                        .reg_write_data(write_data_wb), // input from writeback
                        .reg_write_addr(write_addr_wb), // input from writeback
                        .mem_to_reg(mem_to_reg), 
                        .mem_write(mem_write),
                        .reg_write_addr_return(write_addr_fd), 
                        .ALU_op(ALU_op), 
                        .alu_source1(alu_source1), 
                        .alu_source2(alu_source2),
                        .alu_source_1_select(alu_source_1_select),
                        .alu_source_2_select(alu_source_2_select),
                        .read_data2(read_data2),
                        .instruction(instruction),
                        .reg_source_1_addr(reg_source_1_addr),
                        .reg_write_en(reg_write_fd)        
                         );
    
    // reg_pipe1
    Register_Pipeline_38bit reg_pipe1( .clk(clk), .reset(reset), .write_en(1'b1), .Din(pipe_reg1_in), .Dout(pipe_reg1_out) );
    
    Execute_Memory_Stage ems0(.clk(clk), 
                              .pipe_reg_data(pipe_reg1_out), // input
                              .write_addr(write_addr_em), // output
                              .write_data(write_data_em), // output
                              .reg_write_en(reg_write_em)  // output
                              );
    
    // reg_pipe2
    Register_Pipeline_14bit reg_pipe2( .clk(clk), .reset(reset), .write_en(1'b1), .Din(pipe_reg2_in), .Dout(pipe_reg2_out) );
    
    Write_Back_Stage wbs0( .pipe_reg_data(pipe_reg2_out), //input
                      .write_addr(write_addr_wb), // output
                      .write_data(write_data_wb), // output, also branch_control for fetch unit
                      .reg_write_en(reg_write_wb) //output
                    );
    
    
    assign pipe_reg1_in[0] = mem_to_reg;
    assign pipe_reg1_in[1] = mem_write;
    assign pipe_reg1_in[4:2] = write_addr_fd;
    assign pipe_reg1_in[6:5] = ALU_op;
    assign pipe_reg1_in[16:7] = alu_data_1_forwarded; // from forwarding unit
    assign pipe_reg1_in[26:17] = alu_data_2_forwarded; // from forwarding unit
    assign pipe_reg1_in[36:27] = read_data2;
    assign pipe_reg1_in[37] = reg_write_fd;
    
    assign pipe_reg2_in[13] = reg_write_em;
    assign pipe_reg2_in[12:3] = write_data_em;
    assign pipe_reg2_in[2:0] = write_addr_em;
    
    always@(*)begin
        
        // connected to output of write data mux   
        program_result <= write_data_wb;
        
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
    input wire reg_write_in,
    input wire [9:0] reg_write_data, // tied to register file for write back
    input wire [2:0] reg_write_addr, // tied to register file for write back
    output reg mem_to_reg, // control line
    output reg mem_write, // control line 
    output reg [1:0] ALU_op,  // control line
    output reg [9:0] alu_source1,   // ALU
    output reg [9:0] alu_source2,  // ALU
    output reg [9:0] read_data2,  // Data memory write data
    output reg [2:0] reg_write_addr_return, // control line, returned from control unit
    output reg [9:0] instruction,
    output reg [2:0] reg_source_1_addr,
    output reg reg_write_en,
    output reg alu_source_1_select,
    output reg [1:0] alu_source_2_select
    );
    
    wire [9:0] instruction_out;
    wire [1:0] ALU_op_out;
    wire mem_to_reg_out;
    wire mem_write_out;
    wire [9:0] alu_source1_out;
    wire [9:0] alu_source2_out;
    
    wire [9:0]PC;
    wire [1:0]pc_control;
    wire [2:0]reg_read1_addr; // source select
    wire [9:0]read1_data;
    wire [9:0]read2_data; 
    wire reg_write;
    wire alu_source1_control;
    wire [1:0]alu_source2_control;
    wire [2:0] reg_write_addr_out;
    
    wire [9:0] brach_control;
    
    branch_comparator bc0( .clk(clk),
                           .reg_data_1(read1_data),
                           .reg_data_2(read2_data),
                           .branch_control(brach_control)
                            );
    
    FetchUnit fu0( .clk(clk), 
                   .reset(reset), 
                   .pc_control(pc_control), 
                   .branch_control(brach_control), 
                   .jump_address(instruction[6:2]), 
                   .branch_address(instruction[2:0]), 
                   .reg_address(read1_data), 
                   .PC_out(PC), 
                   .instruction(instruction_out) 
                   );
         
    ControlUnit cu0( .instruction(instruction), 
                     .ALU_op(ALU_op_out), 
                     .reg_write(reg_write), 
                     .reg_write_addr(reg_write_addr_out), 
                     .reg_read1_addr(reg_read1_addr), 
                     .alu_source1_control(alu_source1_control), 
                     .alu_source2_control(alu_source2_control), 
                     .pc_control(pc_control), 
                     .mem_write(mem_write_out), 
                     .mem_to_reg(mem_to_reg_out) 
                     );
            
    RegisterFile rf0( .clk(clk), 
                      .reset(reset), 
                      .en_write(reg_write_in), 
                      .write_addr(reg_write_addr), 
                      .write_data(reg_write_data), 
                      .read1_addr(reg_read1_addr), 
                      .read2_addr(instruction[4:3]), 
                      .read1_data(read1_data), 
                      .read2_data(read2_data) 
                      );
    
    ALU_source1_mux asm1( .alu_source1_select(alu_source1_control), 
                          .reg_read1_data(read1_data), 
                          .pc(PC), 
                          .alu_source(alu_source1_out) 
                          );
        
    ALU_source2_mux asm2( .alu_source2_select(alu_source2_control), 
                          .reg_read2_data(read2_data), 
                          .imm(instruction[2:0]), 
                          .jump_link_offset(10'b0000000001), 
                          .alu_source(alu_source2_out) 
                          );
                          
    always@(*)begin
        instruction <= instruction_out;
        ALU_op <= ALU_op_out;
        mem_to_reg <= mem_to_reg_out;
        mem_write <= mem_write_out;
        alu_source1 <= alu_source1_out;
        alu_source2 <= alu_source2_out;
        read_data2 <= read2_data;
        reg_write_addr_return <= reg_write_addr_out;
        reg_source_1_addr <= reg_read1_addr;
        reg_write_en <= reg_write;
        alu_source_1_select <= alu_source1_control;
        alu_source_2_select <= alu_source2_control;
    end    
endmodule

module Execute_Memory_Stage(
    input wire clk,
    input wire [37:0] pipe_reg_data,
    output reg [2:0] write_addr,
    output reg [9:0] write_data,
    output reg reg_write_en
    );
    
    reg mem_to_reg;
    reg mem_write;
    reg [1:0] ALU_op;
    reg [9:0] alu_source1;
    reg [9:0] alu_source2;
    reg[9:0] read_data2;
    
    
    wire [9:0] ALU_result;
    wire c_out;
    wire [9:0] read_data;
    wire [9:0] wr_data;
   
    always@(*)begin
    mem_to_reg <= pipe_reg_data[0];
    mem_write <= pipe_reg_data[1];
    write_addr <= pipe_reg_data[4:2];
    ALU_op <= pipe_reg_data[6:5];
    alu_source1 <= pipe_reg_data[16:7];
    alu_source2 <= pipe_reg_data[26:17];
    read_data2 <= pipe_reg_data[36:27];
    reg_write_en <= pipe_reg_data[37];
    write_data = wr_data;
    
    end
    
    ALU alu0( .ALU_op(ALU_op), .a(alu_source1), .b(alu_source2), .f(ALU_result), .c_out(c_out) );
    
    DataMemory dm0( .clk(clk), .address(ALU_result), .en_write(mem_write), .write_data(read_data2), .read_data(read_data) );
    
    write_data_mux wdm0( .write_data_select(mem_to_reg), .alu_result(ALU_result), .read_data(read_data), .write_data(wr_data) );

   /*     assign pipe_reg1_in[0] = mem_to_reg;
    assign pipe_reg1_in[1] = mem_write;
    assign pipe_reg1_in[4:2] = reg_write_addr_return;
    assign pipe_reg1_in[6:5] = ALU_op;
    assign pipe_reg1_in[16:7] = alu_source1;
    assign pipe_reg1_in[26:17] = alu_source2;
    assign pipe_reg1_in[36:27] = read_data2;
    */
    

    
endmodule

module Write_Back_Stage(
    input wire [13:0] pipe_reg_data,
    output reg [2:0] write_addr, 
    output reg [9:0] write_data, // also branch_control for fetch unit
    output reg reg_write_en
    );
    always@(*)begin
        write_addr <= pipe_reg_data[2:0];
        write_data <= pipe_reg_data[12:3];
        reg_write_en <= pipe_reg_data[13];
    end
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

module branch_comparator(
    input wire clk,
    input wire [9:0] reg_data_1,
    input wire [9:0] reg_data_2,
    output reg [9:0] branch_control
    );
    always@(*)begin
        if(reg_data_1 == reg_data_2)begin
            branch_control <= 0;
        end
        else begin
            branch_control <= 10'b1111111111;
        end
    end
endmodule