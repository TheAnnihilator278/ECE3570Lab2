`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/26/2018 12:20:38 AM
// Design Name: 
// Module Name: ForwardingUnit
// Project Name: 
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

module ForwardingUnitTest();
    reg enable;   
    reg [2:0] reg_source_1_addr_fd; // output of fetch/decode stage - reg address
    reg [1:0] reg_source_2_addr_fd; // output of fetch/decode stage - reg address
    reg [9:0] alu_source_1_data_fd; // output of fetch/decode stage - reg data
    reg [9:0] alu_source_2_data_fd; // output of fetch/decode stage - reg data
    reg alu_source_1_select;
    reg [1:0] alu_source_2_select;   
    reg [2:0] reg_dest_addr_em; // output of execute/memory stage - reg address
    reg [9:0] execute_result_em; // output of execute/memory stage - write back data
    wire [9:0] alu_source_1_data_forwarded; // input to pipe reg 1
    wire [9:0] alu_source_2_data_forwarded; // input to pipe reg 1

    ForwardingUnit fwu0(.enable(enable),
                         .reg_source_1_addr_fd(reg_source_1_addr_fd), // output of fetch/decode stage - reg address
                         .reg_source_2_addr_fd(reg_source_2_addr_fd), // output of fetch/decode stage - reg address
                         .alu_source_1_data_fd(alu_source_1_data_fd), // output of fetch/decode stage - reg data
                         .alu_source_2_data_fd(alu_source_2_data_fd), // output of fetch/decode stage - reg data
                         
                         .alu_source_1_select(alu_source_1_select),
                         .alu_source_2_select(alu_source_2_select),
                         
                         .reg_dest_addr_em(reg_dest_addr_em), // output of execute/memory stage - reg address
                         .execute_result_em(execute_result_em), // output of execute/memory stage - write back data
                         
                         .alu_source_1_data_forwarded(alu_source_1_data_forwarded), // input to pipe reg 1
                         .alu_source_2_data_forwarded(alu_source_2_data_forwarded) // input to pipe reg 1
                          );

    initial begin
        enable = 1;   
        reg_source_1_addr_fd = 3'b001;
        reg_source_2_addr_fd = 2'b11;
        alu_source_1_data_fd = 10'b0000000001;
        alu_source_2_data_fd = 10'b0000000010;
        alu_source_1_select = 0;
        alu_source_2_select = 2'b00;   
        reg_dest_addr_em = 3'b001; 
        execute_result_em = 10'b0000001000;
        #10;  
        reg_dest_addr_em = 3'b011; 
        #10;         
        reg_dest_addr_em = 3'b000; 
        #10;
        reg_source_1_addr_fd = 3'b001;
        reg_source_2_addr_fd = 2'b01;
        reg_dest_addr_em = 3'b001;


    
    
    end
endmodule


module ForwardingUnit(
    input wire enable,
    
    input wire [2:0] reg_source_1_addr_fd, // output of fetch/decode stage - reg address
    input wire [1:0] reg_source_2_addr_fd, // output of fetch/decode stage - reg address
    input wire [9:0] alu_source_1_data_fd, // output of fetch/decode stage - reg data
    input wire [9:0] alu_source_2_data_fd, // output of fetch/decode stage - reg data
    
    input wire alu_source_1_select,
    input wire [1:0] alu_source_2_select,
    
    input wire [2:0] reg_dest_addr_em, // output of execute/memory stage - reg address
    input wire [9:0] execute_result_em, // output of execute/memory stage - write back data
    
    output reg [9:0] alu_source_1_data_forwarded, // input to pipe reg 1
    output reg [9:0] alu_source_2_data_forwarded // input to pipe reg 1
    
    );
    
    always@(*)begin
        if( enable == 1 )begin
            if( (reg_dest_addr_em == reg_source_1_addr_fd) && (reg_dest_addr_em == reg_source_2_addr_fd) && (alu_source_1_select == 0) && (alu_source_2_select == 2'b0) ) begin
                alu_source_1_data_forwarded <= execute_result_em;
                alu_source_2_data_forwarded <= execute_result_em;
            end
            else if( (reg_dest_addr_em == reg_source_1_addr_fd) && (alu_source_1_select == 0) )begin
                alu_source_1_data_forwarded <= execute_result_em;
                alu_source_2_data_forwarded <= alu_source_2_data_fd;
            end
            else if( (reg_dest_addr_em == reg_source_2_addr_fd) && (alu_source_2_select == 0) )begin
                alu_source_1_data_forwarded <= alu_source_1_data_fd;
                alu_source_2_data_forwarded <= execute_result_em;        
            end
            
            else begin
                alu_source_1_data_forwarded <= alu_source_1_data_fd;
                alu_source_2_data_forwarded <= alu_source_2_data_fd;
            end
        end
        else begin
            alu_source_1_data_forwarded <= alu_source_1_data_fd;
            alu_source_2_data_forwarded <= alu_source_2_data_fd;
        end
    end
endmodule
