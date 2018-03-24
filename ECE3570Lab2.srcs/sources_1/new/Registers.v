`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: Western Michigan University
// Engineer: Tyler Thompson
// 
// Create Date: 02/05/2018 07:30:26 PM
// Design Name: 
// Module Name: Registers
// Project Name: ECE 3570 Lab 2
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

module RegisterFileTest();
     reg clk;
     reg en_write;
     reg [2:0] write_addr;
     reg [9:0] write_data;
     reg [2:0] read1_addr;
     reg [2:0] read2_addr;
     wire [9:0] read1_data;    
     wire [9:0] read2_data;
     reg reset;
     
    //toggle clock every 4ns
    always #4 clk = ~clk;
    
    RegisterFile rf( .clk(clk), .reset(reset), .en_write(en_write), .write_addr(write_addr), .write_data(write_data), .read1_addr(read1_addr), .read2_addr(read2_addr), .read1_data(read1_data), .read2_data(read2_data) );
    
    initial begin
        reset = 1;
        en_write = 0;
        clk = 1;       
        #16;
        reset=0;
        //prove you can't write to the zero register
        en_write = 1; write_addr = 3'b000; write_data = 10'b1111111111; read1_addr = 3'b000; read2_addr = 3'b000;       
        #8;    
        //write to $t0 and read $zero twice
        en_write = 1; write_addr = 3'b001; write_data = 10'b0000001111; read1_addr = 3'b000; read2_addr = 3'b000;       
        #8;
        //write to $t1 and read $t0 and $zero
        en_write = 1; write_addr = 3'b010; write_data = 10'b1010101010; read1_addr = 3'b001; read2_addr = 3'b000;        
        #8;   
        //write to $s0 and read $t1 and $t0
        en_write = 1; write_addr = 3'b011; write_data = 10'b0101010101; read1_addr = 3'b010; read2_addr = 3'b001;       
        #8;  
        //write to $sp and read $s0 and $t1
        en_write = 1; write_addr = 3'b100; write_data = 10'b1111000000; read1_addr = 3'b011; read2_addr = 3'b010;
        #8; 
         //write to $a0 and read $sp and $s0    
        en_write = 1; write_addr = 3'b101; write_data = 10'b0000111111; read1_addr = 3'b100; read2_addr = 3'b011;
        #8; 
        //write to $v0 and read $a0 and $sp  
        en_write = 1; write_addr = 3'b110; write_data = 10'b1111111111; read1_addr = 3'b101; read2_addr = 3'b100;
        #8;   
        //write to $ra and read $v0 and $a0
        en_write = 1; write_addr = 3'b111; write_data = 10'b1100110011; read1_addr = 3'b110; read2_addr = 3'b101;  
        #8;
        //read from $ra and $v0
        en_write = 0; read1_addr = 3'b111; read2_addr = 3'b110;
           
    end
endmodule


// Register file, read and write data to registers
// addressing:  000 -> $zero
//              001 -> $t0
//              010 -> $t1
//              011 -> $s0
//              100 -> $sp
//              101 -> $a0
//              110 -> $v0
//              111 -> $ra
module RegisterFile(
    input wire clk,
    input wire reset,
    input wire en_write,
    input wire [2:0] write_addr,
    input wire [9:0] write_data,
    input wire [2:0] read1_addr,
    input wire [1:0] read2_addr,
    output reg [9:0] read1_data,
    output reg [9:0] read2_data
    );
      
      //Array of data outputs for registers
      wire [9:0]Dout[7:0];
    
      wire [7:0] write_en;

      //Initialize all general purpose registers
      Register_10bit reg_zero(.clk(clk), .reset(1'b1), .Din(write_data), .write_en(write_en[0] & en_write), .Dout(Dout[0]));
      Register_10bit reg_t0(.clk(clk), .reset(reset), .Din(write_data), .write_en(write_en[1] & en_write), .Dout(Dout[1]));
      Register_10bit reg_t1(.clk(clk), .reset(reset), .Din(write_data), .write_en(write_en[2] & en_write), .Dout(Dout[2]));
      Register_10bit reg_s0(.clk(clk), .reset(reset), .Din(write_data), .write_en(write_en[3] & en_write), .Dout(Dout[3]));
      Register_10bit_StackPointer reg_sp(.clk(clk), .reset(reset), .Din(write_data), .write_en(write_en[4] & en_write), .Dout(Dout[4]));
      Register_10bit reg_a0(.clk(clk), .reset(reset), .Din(write_data), .write_en(write_en[5] & en_write), .Dout(Dout[5]));
      Register_10bit reg_v0(.clk(clk), .reset(reset), .Din(write_data), .write_en(write_en[6] & en_write), .Dout(Dout[6]));
      Register_10bit reg_ra(.clk(clk), .reset(reset), .Din(write_data), .write_en(write_en[7] & en_write), .Dout(Dout[7]));
    
      reg_decode rd0( .write_addr(write_addr), .decode_out(write_en) );
      
    always@(*) begin
        read1_data <= Dout[read1_addr];
        read2_data <= Dout[read2_addr];  
    end
     
endmodule


module RegisterTest();
  reg clk, reset;
  //toggle clock every 4ns
  always #4 clk = ~clk;
  
  //Array of data input for registers
  reg [9:0]Din [7:0];
  
  //Array of data outputs for registers
  wire [9:0]Dout[7:0];

  //Initialize all general purpose registers
  Register_10bit reg_zero(.clk(clk), .reset(1'b1), .Din(Din[0]), .Dout(Dout[0]));
  Register_10bit reg_t0(.clk(clk), .reset(reset), .Din(Din[1]), .Dout(Dout[1]));
  Register_10bit reg_t1(.clk(clk), .reset(reset), .Din(Din[2]), .Dout(Dout[2]));
  Register_10bit reg_s0(.clk(clk), .reset(reset), .Din(Din[3]), .Dout(Dout[3]));
  Register_10bit reg_sp(.clk(clk), .reset(reset), .Din(Din[4]), .Dout(Dout[4]));
  Register_10bit reg_a0(.clk(clk), .reset(reset), .Din(Din[5]), .Dout(Dout[5]));
  Register_10bit reg_v0(.clk(clk), .reset(reset), .Din(Din[6]), .Dout(Dout[6]));
  Register_10bit reg_ra(.clk(clk), .reset(reset), .Din(Din[7]), .Dout(Dout[7]));

  //run a test on the registers
  integer i;
  always @(posedge clk) begin
      for( i = 0; i < 8; i = i + 1) begin
          Din[i] = ~Dout[i];
          #4;
      end
  end
  
  initial begin
      clk = 0;
      reset = 0;    
  end  
    
endmodule

module reg_decode(
    input wire [2:0]write_addr,
    output wire [7:0] decode_out
    );
    reg a;
    reg b;
    reg c;
    assign decode_out[0] = (~a) & (~b) & (~c);
    assign decode_out[4] = (~a) & (~b) & (c);
    assign decode_out[2] = (~a) & (b) & (~c);
    assign decode_out[6] = (~a) & (b) & (c);
    assign decode_out[1] = (a) & (~b) & (~c);
    assign decode_out[5] = (a) & (~b) & (c);
    assign decode_out[3] = (a) & (b) & (~c);
    assign decode_out[7] = (a) & (b) & (c);
    always@(*)begin  
        a <= write_addr[0];
        b <= write_addr[1];
        c <= write_addr[2];
    end
endmodule

module Register_10bit(
    input wire clk,
    input wire reset,
    input wire write_en,
    input wire [9:0] Din,
    output reg [9:0] Dout
    );
    
    always @(posedge clk) begin
        if (reset == 1'b1) begin
            Dout <= 10'b0000000000;
        end
        else if (write_en == 1'b1)  begin
            Dout <= Din;
        end
    end
        
endmodule

module Register_10bit_StackPointer(
    input wire clk,
    input wire reset,
    input wire write_en,
    input wire [9:0] Din,
    output reg [9:0] Dout
    );
    
    always @(posedge clk) begin
        if (reset == 1'b1) begin
            Dout <= 10'b1111111111;
        end
        else if (write_en == 1'b1)  begin
            Dout <= Din;
        end
    end
        
endmodule

module Register_Pipeline_37bit(
    input wire clk,
    input wire reset,
    input wire write_en,
    input wire [36:0] Din,
    output reg [36:0] Dout
    );
    
    always @(posedge clk) begin
        if (reset == 1'b1) begin
            Dout <= 37'b0000000000000000000000000000000000000;
        end
        else if (write_en == 1'b1)  begin
            Dout <= Din;
        end
    end
        
endmodule

module Register_Pipeline_13bit(
    input wire clk,
    input wire reset,
    input wire write_en,
    input wire [12:0] Din,
    output reg [12:0] Dout
    );
    
    always @(posedge clk) begin
        if (reset == 1'b1) begin
            Dout <= 13'b0000000000000;
        end
        else if (write_en == 1'b1)  begin
            Dout <= Din;
        end
    end
        
endmodule
