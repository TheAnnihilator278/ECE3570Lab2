`timescale 1ns / 1ns
`include "ALU.v"
`include "Registers.v"
`include "Memory.v"

//////////////////////////////////////////////////////////////////////////////////
// Company: Western Michigan University
// Engineer: Tyler Thompson
// 
// Create Date: 02/13/2018 02:47:56 PM
// Design Name: 
// Module Name: FetchUnit
// Project Name: ECE 3570 Lab 2
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: ALU.v, Registers.v
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////



module FetchUnitTest();
    reg clk, reset;
    reg [1:0] pc_control;
    reg [9:0] branch_control;
    reg [4:0] jump_address;
    reg [2:0] branch_address;
    reg [9:0] reg_address;
    wire [9:0] PC;
    //toggle clock every 5ns
    always #5 clk = ~clk;
    
    FetchUnit fu0( .clk(clk), .reset(reset), .pc_control(pc_control), .branch_control(branch_control), .jump_address(jump_address), .branch_address(branch_address), .reg_address(reg_address), .PC_out(PC) );
    
    initial begin
        branch_control = 1;
        clk = 0;
        reset = 1; //initialize the program counter
        #20
        reset = 0;
        #15
        
        pc_control = 2'b00; // increment program counter by 1
        #20
        pc_control = 2'b01; jump_address = 5'b00100; // increment program count by 4
        #20
        pc_control = 2'b10; reg_address = 10'b0001000000; // set program counter to 64
        #20
        pc_control = 2'b11; branch_address = 3'b010; branch_control = 0;// branch to address
        #20
        pc_control = 2'b00;
    end
endmodule


// Program Counter control unit
// pc_control:  00 -> increment program count by 1
//              01 -> add jump_address to program counter
//              10 -> set program counter to reg_address
//              11 -> add 4 to program count and then add the branch_address
module FetchUnit(
    input wire clk,
    input wire reset,
    input wire [1:0] pc_control,
    input wire [9:0] branch_control,
    input wire [4:0] jump_address,
    input wire [2:0] branch_address,
    input wire [9:0] reg_address,
    output wire [9:0] PC_out,
    output wire [9:0] instruction
    );
    reg [9:0]PC_in;
    reg [9:0] b;
    wire c_out;
    wire [9:0] sum;
    wire [9:0] branch_offset;
    reg [9:0] branch_ext;   
    
    InstructionMemory im0( .clk(clk), .address(PC_in), .read_data(instruction) );
    
    //Create 10 bit register for program counter
    Register_10bit pc_reg( .clk(clk), .reset(reset), .write_en(1'b1), .Din(PC_in), .Dout(PC_out) );

    //adder for calculating branch offset
    FullAdder_10Bit fa1( .a( branch_ext ), .b(10'b0000000100), .sum(branch_offset), .c_out(c_out) );   
    
    //adder for calculating pc address
    FullAdder_10Bit fa0( .a(PC_out), .b(b), .sum(sum), .c_out(c_out) );
    
    //update the program counter on each clock cycle
    always @(*) begin
            //instruction_out <= instruction;
            //sign extend branch address
            branch_ext <= { {7{branch_address[2]}}, branch_address[2:0] };
            PC_in <= sum;
            b <= 0;

                if ( reset == 0 ) begin
                
                    case(pc_control)
                            2'b00: b <= 10'b0000000001; 
                            2'b01: b <= { {5{jump_address[4]}}, jump_address[4:0] }; // sign extend jump address      
                            2'b10: PC_in <= reg_address;
                            2'b11: begin // branch
                                    if ( branch_control == 0 ) begin
                                        b <= branch_offset;
                                    end
                                    else begin
                                        b <= 10'b0000000001;
                                    end
                                   end
                            default: PC_in <= PC_out;
                        endcase
                                    
                end
                else begin
                    PC_in <= 0;
                end
            
    end
    
  

endmodule
