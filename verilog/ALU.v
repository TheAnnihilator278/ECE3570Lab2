`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: Western Michigan University
// Engineer: Tyler Thompson
// 
// Create Date: 02/13/2018 02:44:18 PM
// Design Name: 
// Module Name: ALU
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


module ALUTest();

    wire [9:0] result;
    wire c_out;
    
    reg [9:0] a;
    reg [9:0] b;
    reg [1:0] ALU_op;
    
    ALU alu0( .ALU_op(ALU_op), .a(a), .b(b), .f(result), .c_out(c_out) );
   
    initial begin
        ALU_op = 2'b00;
        a = 10'b0000000000;
        b = 10'b0000000000;
    end

    always @(a or b) begin
        //adder test
         a = 10'b0000000001; b = 10'b0000000001; ALU_op = 2'b00; // 1 + 1
         #8;
         a = 10'b0000000011; b = 10'b0000000001; ALU_op = 2'b00; // 3 + 1
         #8;
         a = 10'b0000000010; b = 10'b0000000001; ALU_op = 2'b00; // 2 + 1
         #8;
         a = 10'b0010110010; b = 10'b0011001101; ALU_op = 2'b00; // 178 + 205 = 383
         #8;
         a = 10'b1101001110; b = 10'b0011001101; ALU_op = 2'b00; // -178 + 205 = 27 
         #8;
         a = 10'b1101001110; b = 10'b1111111110; ALU_op = 2'b00; // -178 + -2 = -180 
         #8;
        
        //shifter test
        a = 10'b0001000000; b = 10'b1111111111; ALU_op = 2'b10; //shift a right by 1
        #8;
        a = 10'b0000000001; b = 10'b0000000001; ALU_op = 2'b10; //shift a left by 1
        #8;
        a = 10'b0001000000; b = 10'b1111111100; ALU_op = 2'b10; //shift a right by 4
        #8;
        a = 10'b0000000001; b = 10'b0000000100; ALU_op = 2'b10; //shift a left by 4
        #8;
        
        //comparator test
        a = 10'b0000000010; b = 10'b0000000001; ALU_op = 2'b01; //test if 2 is greater than 1
        #8;
        a = 10'b0000000001; b = 10'b0000000010; ALU_op = 2'b01; //test if 1 is greater than 2
        #8;
        a = 10'b0000000001; b = 10'b0000000001; ALU_op = 2'b01; //test if 1 is greater than 1
        #8;
        a = 10'b1111111111; b = 10'b0000000001; ALU_op = 2'b01; //test if -1 is greater than 1
        #8;
        a = 10'b0000000001; b = 10'b1111111111; ALU_op = 2'b01; //test if 1 is greater than -1
        #8;
        a = 10'b1111111110; b = 10'b1111111111; ALU_op = 2'b01; //test if -2 is greater than -1
        #8;
        a = 10'b1111111111; b = 10'b1111111110; ALU_op = 2'b01; //test if -1 is greater than -2
        #8;
        a = 10'b1111110000; b = 10'b1111111100; ALU_op = 2'b01; //test if -16 is greater than -4
        #8;
        a = 10'b1111111000; b = 10'b1111101100; ALU_op = 2'b01; //test if -8 is greater than -20
        #8;
        a = 10'b1000000000; b = 10'b1000000010; ALU_op = 2'b01; //test if -512 is greater than -510
        #8;
        a = 10'b1000000010; b = 10'b1000000000; ALU_op = 2'b01; //test if -510 is greater than -512
        #8;
        a = 10'b0111111111; b = 10'b0111111110; ALU_op = 2'b01; //test if 511 is greater than 510
    end

endmodule


// Arithmetic Logic Unit
// Supports add, shift, and compare operations
// ALU_op: 00 -> adder
//         01 -> comparator
//         10 -> shifter
//         11 -> Twos Complement
module ALU(
    input wire [1:0] ALU_op,
    input wire [9:0] a,
    input wire [9:0] b,
    output wire [9:0] f,
    output c_out
    );
    wire [9:0] add_result;
    wire [9:0] shift_result;
    wire [9:0] comp_result;
    wire [9:0] complement_result;
  
    FullAdder_10Bit fa0( .a(a), .b(b), .sum(add_result), .c_out(c_out) );
    Comparator cp0( .a(a), .b(b), .out(comp_result) );
    Shifter sh0( .a(a), .shift_amount(b), .out(shift_result) );
    Complementor cptr0( .a(a), .out(complement_result) );
    ALU_mux mx0( .ALU_op(ALU_op), .add_result(add_result), .comp_result(comp_result), .shift_result(shift_result), .complement_result(complement_result), .final_answer(f) );
   
endmodule


// Multiplexer for ALU output selection
// ALU_op: 00 -> adder
//         01 -> comparator
//         10 -> shifter
//         11 -> complementor
module ALU_mux(
     input wire [1:0] ALU_op,
	 input wire [9:0] add_result,
	 input wire [9:0] comp_result,
	 input wire [9:0] shift_result,
	 input wire [9:0] complement_result,
	 output reg [9:0] final_answer
	 );
	 
	 always@(*) begin
		case(ALU_op)
			 2'b00: final_answer <= add_result;
			 2'b01: final_answer <= comp_result;
	         2'b10: final_answer <= shift_result;
	         2'b11: final_answer <= complement_result;
	         default: final_answer <= 10'b0;
		endcase
	end	
endmodule

// takes the twos complement of an input.
module Complementor(
    input wire [9:0] a,
    output reg [9:0] out
    );
   reg [9:0] not_a;
   wire c_out;
   wire [9:0] sum;
   FullAdder_10Bit fa1( .a(not_a), .b(10'b0000000001), .sum(sum), .c_out(c_out) );
   
   always@(*)begin
        not_a <= ~a;
        out <= sum;
   end 
endmodule


// Compares a to b
// out = 2 if a is grater than b and 0 if a is equal to b and 1 if a is less than b
module Comparator(
    input wire [9:0] a,
    input wire [9:0] b,
    output reg [9:0] out //2 -> a is greater than b, 0 -> a equal to b, 1-> a is less than b
    );
    
    reg [9:0]temp0;
    wire [9:0] temp1;
    wire c_out;
    wire [9:0]sum;
    wire c_out1;
    
    //adder for twos complement
    FullAdder_10Bit fa1( .a(10'b0000000001), .b(temp0), .sum(temp1), .c_out(c_out) );
    
    FullAdder_10Bit fa2( .a(b), .b(temp1), .sum(sum), .c_out(c_out1) );
    always@(*) begin
        temp0 <= 0;
        // a and b are equal
        if ( a == b ) begin
            out = 10'b0000000000;
        end
        //both a and b are negative
        else if ( (a[9] & b[9]) == 1 ) begin
           //twos complement of a
           temp0 <= ~a;
           
           if (c_out1 == 1) begin
                out = 10'b0000000001;
               
           end
           else begin
                out = 10'b0000000010;
                
           end
        end
        //a is negative and b is positive
        else if ( a[9] == 1 ) begin  
            out = 10'b0000000001;
        end
        //a is positive and b is negative
        else if ( b[9] == 1 ) begin
            out = 10'b0000000010;
        end
        //a is positive and b is positive
        else begin  
            //twos completment of a
            temp0 <= ~a;
            
            if ( sum[9] == 1 ) begin
                out = 10'b0000000010;
            end
            else begin
                out = 10'b0000000001;
            end
         end
      
    end
endmodule


// Shift a number left or right
// a positive shift_amount value will shift the number left
// a negative shift_amount value will shift the number right
module Shifter(
    input [9:0] a,
    input [9:0] shift_amount,
    output reg [9:0] out
    );
    reg [9:0] x;
    wire [9:0] sum;
    wire c_out;
    FullAdder_10Bit fa2( .a(x), .b(10'b0000000001), .sum(sum), .c_out(c_out) );
   always @(*) begin 
        //if shift_amount is negative, take twos complement and shift right
        if ( shift_amount[9] == 1'b1 ) begin
           x <= ~shift_amount ;
            out = a >> sum;
        end 
        else begin
            out = a << shift_amount;
            x <= 0;
        end
    end
endmodule

// Ripple adder for 10 bit numbers
module FullAdder_10Bit(
    input [9:0] a,
    input [9:0] b,
    output [9:0] sum,
    output c_out
    );  
        wire [8:0]ripple;
        
        FullAdder_1Bit f0( .a( a[0] ), .b( b[0] ), .c_in( 1'b0 ), .s( sum[0]), .c_out( ripple[0] ) );
        FullAdder_1Bit f1( .a( a[1] ), .b( b[1] ), .c_in( ripple[0] ), .s( sum[1]), .c_out(ripple[1]) );
        FullAdder_1Bit f2( .a( a[2] ), .b( b[2] ), .c_in( ripple[1] ), .s( sum[2]), .c_out(ripple[2]) );
        FullAdder_1Bit f3( .a( a[3] ), .b( b[3] ), .c_in( ripple[2] ), .s( sum[3]), .c_out(ripple[3]) );
        FullAdder_1Bit f4( .a( a[4] ), .b( b[4] ), .c_in( ripple[3] ), .s( sum[4]), .c_out(ripple[4]) );
        FullAdder_1Bit f5( .a( a[5] ), .b( b[5] ), .c_in( ripple[4] ), .s( sum[5]), .c_out(ripple[5]) );
        FullAdder_1Bit f6( .a( a[6] ), .b( b[6] ), .c_in( ripple[5] ), .s( sum[6]), .c_out(ripple[6]) );
        FullAdder_1Bit f7( .a( a[7] ), .b( b[7] ), .c_in( ripple[6] ), .s( sum[7]), .c_out(ripple[7]) );
        FullAdder_1Bit f8( .a( a[8] ), .b( b[8] ), .c_in( ripple[7] ), .s( sum[8]), .c_out(ripple[8]) );
        FullAdder_1Bit f9( .a( a[9] ), .b( b[9] ), .c_in( ripple[8] ), .s( sum[9]), .c_out(c_out) );
        
    endmodule

//simple adder for adding two bits
module FullAdder_1Bit(
    input wire a,
    input wire b,
    input wire c_in, //carry in
	output wire s, //sum
	output wire c_out //carry out
    );	
    
	assign s = a ^ b ^ c_in;
	assign c_out = ((a ^ b) & c_in) | (a & b);
	
endmodule
