`timescale 1ns / 1ns
`include "CPU.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/13/2018 11:45:39 AM
// Design Name: 
// Module Name: CPUTests
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


module CPU10Bits_jump_test();
    reg clk;
    reg reset;
    reg [9:0] instruction;
    wire done;

    CPU10Bits cpu0( .instruction(instruction), .clk(clk), .reset(reset), .done(done) );
    
    //toggle clock every 4ns
    always #4 clk = ~clk;
    
    initial begin
        clk = 1; 
        reset = 1;
        instruction = 10'b0000000000; // NOP
        #8;
        reset = 0;
                   
        instruction = 10'b1001100011; // addi $s0, $zero, 3
        #8;
        instruction = 10'b1110001100; // jr $s0
        #8;
        instruction = 10'b1110111101; // j 01111 (15)
        #8;
        instruction = 10'b1111000010; // jal 10000 (-16)
        #8;
        instruction = 10'b0000000000; // NOP
        #8;
        instruction = 10'b1110011100; // jr $ra
        #8;
        instruction = 10'b1110000011; // halt
        #8;
        reset = 1;       
    end
endmodule

module CPU10Bits_branch_test();
    reg clk;
    reg reset;
    reg [9:0] instruction;
    wire done;
    
    CPU10Bits cpu0( .instruction(instruction), .clk(clk), .reset(reset), .done(done) );
    
    //toggle clock every 4ns
    always #4 clk = ~clk;
    
    initial begin
        clk = 1; 
        reset = 1;
        instruction = 10'b0000000000; // NOP
        #8;
        reset = 0;
                   
        instruction = 10'b1000100001; // addi $t0, $zero, 1
        #8;
        instruction = 10'b0110100011; // beq $t0, $zero, PC=PC+4+3
        #8;
        instruction = 10'b1001000001; // addi $t1, $zero, 1
        #8;
        instruction = 10'b0110110011; // beq $t0, $t1, PC=PC+4+3
        #8;
        instruction = 10'b1110000011; // halt
        #8;
        reset = 1;       
    end
endmodule

module CPU10Bits_twos_complement_test();
    reg clk;
    reg reset;
    reg [9:0] instruction;
    wire done;
    
    CPU10Bits cpu0( .instruction(instruction), .clk(clk), .reset(reset), .done(done) );
    
    //toggle clock every 4ns
    always #4 clk = ~clk;
    
    initial begin
        clk = 1; 
        reset = 1;
        instruction = 10'b0000000000; // NOP
        #8;
        reset = 0;
                
        instruction = 10'b1001000011; // addi $t1, $zero, 3
        #8;
        instruction = 10'b0001010010;  // add $t1, $t1, $t1
        #8;
        instruction = 10'b0001010010;  // add $t1, $t1, $t1
        #8;
        instruction = 10'b1001010100; // tcp $t1, $t1
        #8;
        instruction = 10'b0001010010;  // add $t1, $t1, $t1
        #8;
        instruction = 10'b1001010100; // tcp $t1, $t1
        #8;
        instruction = 10'b1110000011; // halt
        #8;
        reset = 1;       
    end
endmodule

module CPU10Bits_compare_test();
    reg clk;
    reg reset;
    reg [9:0] instruction;
    wire done;
    
    CPU10Bits cpu0( .instruction(instruction), .clk(clk), .reset(reset), .done(done) );
    
    //toggle clock every 4ns
    always #4 clk = ~clk;
    
    initial begin
        clk = 1; 
        reset = 1;
        instruction = 10'b0000000000; // NOP
        #8;
        reset = 0;
    
        instruction = 10'b1001000011; // addi $t1, $zero, 3
        #8;
        instruction = 10'b1000100010;  // addi $t0, $zero, 2
        #8;
        instruction = 10'b0101001011; // cmp $s0, $t1, $t0
        #8;
        instruction = 10'b0100110011; // cmp $s0, $t0, $t1
        #8;
        instruction = 10'b1001000010; // addi $t1, $zero, 2
        #8;
        instruction = 10'b0100110011; // cmp $s0, $t0, $t1
        #8;
        instruction = 10'b1001000101; // addi $t1, $zero, -3
        #8;
        instruction = 10'b1000100110;  // addi $t0, $zero, -2
        #8;
        instruction = 10'b0101001011; // cmp $s0, $t1, $t0
        #8;
        instruction = 10'b0100110011; // cmp $s0, $t0, $t1
        #8;
        instruction = 10'b1110000011; // halt
        #8;
        reset = 1;       
    end
endmodule

module CPU10Bits_store_load_test();
    reg clk;
    reg reset;
    reg [9:0] instruction;
    wire done;
    
    CPU10Bits cpu0( .instruction(instruction), .clk(clk), .reset(reset), .done(done) );
    
    //toggle clock every 4ns
    always #4 clk = ~clk;
    
    initial begin
        clk = 1; 
        reset = 1;
        instruction = 10'b0000000000; // NOP
        #8;
        reset = 0;
        
        instruction = 10'b1001000011; // addi $t1, $zero, 3
        #8;
        instruction = 10'b1000100010;  // addi $t0, $zero, 2
        #8;
        instruction = 10'b1010110010; // sw $t0, 2($t1)
        #8;
        instruction = 10'b1011001111; // sw $t1, -1($t0)
        #8;
        instruction = 10'b1100110010; // lw $t0, 2($t1)
        #8;
        instruction = 10'b1101001111; // lw $t1, -1($t0)
        #8;
        instruction = 10'b1110000011; // halt
        #8;
        reset = 1;       
    end
endmodule

module CPU10Bits_shift_test();
    reg clk;
    reg reset;
    reg [9:0] instruction;
    wire done;

    CPU10Bits cpu0( .instruction(instruction), .clk(clk), .reset(reset), .done(done) );
    
    //toggle clock every 4ns
    always #4 clk = ~clk;
    
    initial begin
        clk = 1; 
        reset = 1;
        instruction = 10'b0000000000; // NOP
        #8;
        reset = 0;
        
        instruction = 10'b1001000011; // addi $t1, $zero, 3
        #8;
        instruction = 10'b0001010010;  // add $t1, $t1, $t1
        #8;
        instruction = 10'b0001010010;  // add $t1, $t1, $t1
        #8;
        instruction = 10'b1000100011;  // addi $t0, $zero, 3
        #8;
        instruction = 10'b1001100101;  // addi $s0, $zero, -3
        #8;
        instruction = 10'b0011001010; // sll $t1, $t1, $t0
        #8;
        instruction = 10'b0011011010; // sll $t1, $t1, $s0
        #8;
        instruction = 10'b1110000011; // halt
        #8;
        reset = 1;       
    end
endmodule

module CPU10Bits_add_addi_test();
    reg clk;
    reg reset;
    reg [9:0] instruction;
    wire done;

    CPU10Bits cpu0( .instruction(instruction), .clk(clk), .reset(reset), .done(done) );
    
    //toggle clock every 4ns
    always #4 clk = ~clk;
    
    initial begin
        clk = 1; 
        reset = 1;
        instruction = 10'b0000000000; // NOP
        #8;
        reset = 0;
        
        instruction = 10'b1001000011; // addi $t1, $zero, 3
        #8;
        instruction = 10'b0001010010;  // add $t1, $t1, $t1
        #8;
        instruction = 10'b1000100011;  // addi $t0, $zero, 3
        #8;
        instruction = 10'b1000101010;  // addi $t0, $t0, 2
        #8;
        instruction = 10'b0001110001;  // add $s0, $t1, $t0
        #8;
        instruction = 10'b1000101110;  // addi $t0, $t0, -2
        #8;
        instruction = 10'b1001000111;  // addi $t1, $zero, -1
        #8;
        instruction = 10'b1001100101;  // addi $s0, $zero, -3
        #8;
        instruction = 10'b0000111010;  // add $t0, $s0, $t1
        #8;
        instruction = 10'b1110000011; // halt
        #8;
        reset = 1;       
    end
endmodule


// Program 3, f = (x * y) - 4
// x = 3 -> $t1, y = 4 -> $s0, f = 8 -> $v0 
// TEST 1
module CPU10Bits_program_test1();
    reg clk;
    reg reset;
    reg [9:0] instruction;
    wire done;
    
    integer x = 3;
    integer index = 0;
    integer x_neg = 0;

    CPU10Bits cpu0( .instruction(instruction), .clk(clk), .reset(reset), .done(done) );
    
    //toggle clock every 4ns
    always #4 clk = ~clk;
    
    initial begin
        clk = 1; 
        reset = 1;
        instruction = 10'b0000000000; // NOP
        #8;
        reset = 0;
        instruction = 10'b1001000011; // addi $t1, $zero, 3; $t1 = x
        #8;
        instruction = 10'b0011000101;   //   sll $a0, $t1, $zero 
        #8;
        instruction = 10'b1001100010; // addi $s0, $zero, 2; $s0 = y
        #8;
        instruction = 10'b1001111010; // addi $s0, $s0, 2;
        #8;
        instruction = 10'b0000111000; // add $t0, $s0, $zero
        #8;
        
        for ( index = 0; index < (x - 1); index = index + 1 ) begin
            instruction = 10'b0111000000; //beq $t1, $zer0, 0
            #8;                           
            instruction = 10'b0001111001; //add $s0, $s0, $t0
            #8;
            instruction = 10'b1001010111; //addi $t1, $t1, -1
            #8;
            instruction = 10'b1111110101; //j 11101 (-3)
            #8;
        end
        instruction = 10'b0001000101;    //  add $t1, $zero, $a0     ;load original x
        #8;
        instruction = 10'b0101000010;    //  cmp $t1, $t1, $zer0
        #8;
        instruction = 10'b1000100001;    //  addi $t0, $zero, 1
        #8;
        instruction = 10'b0110110101;    //  beq $t0, $t1, -2        ;if x is pos, pc=pc+2
        #8;
        if ( x_neg == 1 ) begin
            instruction = 10'b1001111100;    //  tcp $s0, $s0            ;two comp of y
            #8;
        end
        instruction = 10'b1001111110; // addi $s0, $s0, -2;
        #8;
        instruction = 10'b1001111110; // addi $s0, $s0, -2;
        #8;
        instruction = 10'b0011100110; // sll $v0, $s0, $zer0
        #8;
        instruction = 10'b1110000011; // halt
        #8;
        reset = 1;
        
    
    end
endmodule

// Program 3, f = (x * y) - 4
// x = -5 -> $t1, y = 6 -> $s0, f = -34 -> $v0 
// TEST 2
module CPU10Bits_program_test2();
   reg clk;
    reg reset;
    reg [9:0] instruction;
    wire done;
    
    integer x = 5;
    integer index = 0;
    integer x_neg = 1;

    CPU10Bits cpu0( .instruction(instruction), .clk(clk), .reset(reset), .done(done) );
    
    //toggle clock every 4ns
    always #4 clk = ~clk;
    
    initial begin
        clk = 1; 
        reset = 1;
        instruction = 10'b0000000000; // NOP
        #8;
        reset = 0;
        instruction = 10'b1001000101; // addi $t1, $zero, -3; $t1 = x
        #8;
        instruction = 10'b1001010110; // addi $t1, $t1, -2; $t1 = x = -5
        #8;
        instruction = 10'b1001100011; // addi $s0, $zero, 3; $s0 = y =6
        #8;
        instruction = 10'b1001111011; // addi $s0, $s0, 3;
        #8;
        instruction = 10'b0000111000; // add $t0, $s0, $zero
        #8;
        
        for ( index = 0; index < (x - 1); index = index + 1 ) begin
            instruction = 10'b0111000000; //beq $t1, $zer0, 0
            #8;                           
            instruction = 10'b0001111001; //add $s0, $s0, $t0
            #8;
            instruction = 10'b1001010111; //addi $t1, $t1, -1
            #8;
            instruction = 10'b1111110101; //j 11101 (-3)
            #8;
        end
        instruction = 10'b0001000101;    //  add $t1, $zero, $a0     ;load original x
        #8;
        instruction = 10'b0101000010;    //  cmp $t1, $t1, $zer0
        #8;
        instruction = 10'b1000100001;    //  addi $t0, $zero, 1
        #8;
        instruction = 10'b0110110101;    //  beq $t0, $t1, -2        ;if x is pos, pc=pc+2
        #8;
        if ( x_neg == 1 ) begin
            instruction = 10'b1001111100;    //  tcp $s0, $s0            ;two comp of y
            #8;
        end
        instruction = 10'b1001111110; // addi $s0, $s0, -2;
        #8;
        instruction = 10'b1001111110; // addi $s0, $s0, -2;
        #8;
        instruction = 10'b0011100110; // sll $v0, $s0, $zer0
        #8;
        instruction = 10'b1110000011; // halt
        #8;
        reset = 1;
        
    
    end
    
endmodule

// Program 3, f = (x * y) - 4
// x = 2 -> $t1, y = -8 -> $s0, f = -20 -> $v0 
// TEST 3
module CPU10Bits_program_test3();
    reg clk;
    reg reset;
    reg [9:0] instruction;
    wire done;
    
    integer x = 2;
    integer index = 0;
    integer x_neg = 0;

    CPU10Bits cpu0( .instruction(instruction), .clk(clk), .reset(reset), .done(done) );
    
    //toggle clock every 4ns
    always #4 clk = ~clk;
    
    initial begin
        clk = 1; 
        reset = 1;
        instruction = 10'b0000000000; // NOP
        #8;
        reset = 0;
        instruction = 10'b1001000010; // addi $t1, $zero, 2; $t1 = x
        #8;
        instruction = 10'b1001100101; // addi $s0, $zero, -3; $s0 = y
        #8;
        instruction = 10'b1001111101; // addi $s0, $s0, -3;
        #8;
        instruction = 10'b1001111110; // addi $s0, $s0, -2;
        #8;
        instruction = 10'b0000111000; // add $t0, $s0, $zero
        #8;
        
        for ( index = 0; index < (x - 1); index = index + 1 ) begin
            instruction = 10'b0111000000; //beq $t1, $zer0, 0
            #8;                           
            instruction = 10'b0001111001; //add $s0, $s0, $t0
            #8;
            instruction = 10'b1001010111; //addi $t1, $t1, -1
            #8;
            instruction = 10'b1111110101; //j 11101 (-3)
            #8;
        end
        instruction = 10'b0001000101;    //  add $t1, $zero, $a0     ;load original x
        #8;
        instruction = 10'b0101000010;    //  cmp $t1, $t1, $zer0
        #8;
        instruction = 10'b1000100001;    //  addi $t0, $zero, 1
        #8;
        instruction = 10'b0110110101;    //  beq $t0, $t1, -2        ;if x is pos, pc=pc+2
        #8;
        if ( x_neg == 1 ) begin
            instruction = 10'b1001111100;    //  tcp $s0, $s0            ;two comp of y
            #8;
        end
        instruction = 10'b1001111110; // addi $s0, $s0, -2;
        #8;
        instruction = 10'b1001111110; // addi $s0, $s0, -2;
        #8;
        instruction = 10'b0011100110; // sll $v0, $s0, $zer0
        #8;
        instruction = 10'b1110000011; // halt
        #8;
        reset = 1;
        
    
    end
endmodule

// Program 3, f = (x * y) - 4
// x = -5 -> $t1, y = -2 -> $s0, f = 6 -> $v0 
// TEST 4
module CPU10Bits_program_test4();
   reg clk;
    reg reset;
    reg [9:0] instruction;
    wire done;
    
    integer x = 5;
    integer index = 0;
    integer x_neg = 1;
    
    CPU10Bits cpu0( .instruction(instruction), .clk(clk), .reset(reset), .done(done) );
    
    //toggle clock every 4ns
    always #4 clk = ~clk;
    
    initial begin
        clk = 1; 
        reset = 1;
        instruction = 10'b0000000000; // NOP
        #8;
        reset = 0;
        instruction = 10'b1001000101; // addi $t1, $zero, -3; $t1 = x
        #8;
        instruction = 10'b1001010110; // addi $t1, $t1, -2; $t1 = x=-5
        #8;
        instruction = 10'b1001100110; // addi $s0, $zero, -2; $s0 = y
        #8;
        instruction = 10'b0000111000; // add $t0, $s0, $zero
        #8;
        
        for ( index = 0; index < (x - 1); index = index + 1 ) begin
            instruction = 10'b0111000000; //beq $t1, $zer0, 0
            #8;                           
            instruction = 10'b0001111001; //add $s0, $s0, $t0
            #8;
            instruction = 10'b1001010111; //addi $t1, $t1, -1
            #8;
            instruction = 10'b1111110101; //j 11101 (-3)
            #8;
        end
        instruction = 10'b0001000101;    //  add $t1, $zero, $a0     ;load original x
        #8;
        instruction = 10'b0101000010;    //  cmp $t1, $t1, $zer0
        #8;
        instruction = 10'b1000100001;    //  addi $t0, $zero, 1
        #8;
        instruction = 10'b0110110101;    //  beq $t0, $t1, -2        ;if x is pos, pc=pc+2
        #8;
        if ( x_neg == 1 ) begin
            instruction = 10'b1001111100;    //  tcp $s0, $s0            ;two comp of y
            #8;
        end
        instruction = 10'b1001111110; // addi $s0, $s0, -2;
        #8;
        instruction = 10'b1001111110; // addi $s0, $s0, -2;
        #8;
        instruction = 10'b0011100110; // sll $v0, $s0, $zer0
        #8;
        instruction = 10'b1110000011; // halt
        #8;
        reset = 1;
        
    
    end
endmodule  
