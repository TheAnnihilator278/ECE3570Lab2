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


module ForwardingUnit(
    input wire enable,
    
    input wire [2:0] reg_source_1_addr_fd, // output of fetch/decode stage - reg address
    input wire [2:0] reg_source_2_addr_fd, // output of fetch/decode stage - reg address
    input wire [9:0] alu_source_1_data_fd, // output of fetch/decode stage - reg data
    input wire [9:0] alu_source_2_data_fd, // output of fetch/decode stage - reg data
    
    input wire [2:0] reg_dest_addr_em, // output of execute/memory stage - reg address
    input wire [9:0] execute_result_em, // output of execute/memory stage - write back data
    
    output reg [9:0] alu_source_1_data_forwarded, // input to pipe reg 1
    output reg [9:0] alu_source_2_data_forwarded // input to pipe reg 1
    
    );
    
    always@(*)begin
        if( enable == 1 )begin
            if( reg_dest_addr_em == reg_source_1_addr_fd )begin
                alu_source_1_data_forwarded <= execute_result_em;
                alu_source_2_data_forwarded <= alu_source_2_data_fd;
            end
            else if(reg_dest_addr_em == reg_source_2_addr_fd )begin
                alu_source_1_data_forwarded <= alu_source_1_data_fd;
                alu_source_2_data_forwarded <= execute_result_em;        
            end
            else if( (reg_dest_addr_em == reg_source_1_addr_fd) && (reg_dest_addr_em == reg_source_2_addr_fd) ) begin
                alu_source_1_data_forwarded <= execute_result_em;
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
