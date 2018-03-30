`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: Western Michigan University
// Engineer: Tyler Thompson
// 
// Create Date: 03/13/2018 11:49:00 AM
// Design Name: 
// Module Name: Memory
// Project Name: ECE3570 Lab3b
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


module InstructionMemory(
    input wire clk,
    input wire [9:0] address,
    output reg [9:0] read_data
    );
    reg [9:0] memory[1023:0];
    
    always@(posedge clk)begin
        read_data <= memory[address];
    end
    
    initial begin
       
       // load and store test - Instruction and Data memory test
//        memory[0] <= 10'b1001000011; // addi $t1, $zero, 3
//        memory[1] <= 10'b1001100010; //   addi $s0, $zero, 2
//        memory[2] <= 10'b1011110000; // sw $t1, 0($s0)
//        memory[3] <= 10'b1100111000; // lw $t0, 0($s0)
//        memory[4] <= 10'b1000101011; // addi $t0, $t0, 3
//        memory[5] <= 10'b1011101001; // sw $t0, 1($s0)
//        memory[6] <= 10'b1101011001; // lw $t1, 1($s0)
//        memory[7] <= 10'b0001100100; // add $s0, $zero, $sp
//        memory[8] <= 10'b1011101111; // sw $t0, -1($s0)
//        memory[9] <= 10'b1110000011;  //  halt
        
        // Program 2, F = ( X*Y ) - 4
//        memory[0] <= 10'b1101000000; // lw $t1, 0($zero) ;$t1=x
//        memory[1] <= 10'b0011000101;	// sll $a0, $t1, $zero	;store original x in $a0
//        memory[2] <= 10'b1001010111;  //  addi $t1, $t1, -1    ;x--
//        memory[3] <= 10'b1101100001; //   lw $s0, 1($zero) ;$s0=y
//        memory[4] <= 10'b0000111000; //   add $t0, $s0, $zer0    ;$t0=4        
//        memory[5] <= 10'b0111000000;  //  beq $t1, $zer0, 0    ;if x==0, pc=pc+4
//        memory[6] <= 10'b0001111001;  //  add $s0, $s0, $t0    ;y=y+4
//        memory[7] <= 10'b1001010111;  //  addi $t1, $t1, -1    ;x--
//        memory[8] <= 10'b1111110101;  //  j -3            ;pc=pc-3        
//        memory[9] <= 10'b0001000101;  //  add $t1, $zero, $a0    ;load original x
//        memory[10] <= 10'b0101000010;  //  cmp $t1, $t1, $zer0
//        memory[11] <= 10'b1000100010;  //  addi $t0, $zero, 2
//        memory[12] <= 10'b0110110110;  //  beq $t0, $t1, -2    ;if x is pos, pc=pc+2
//        memory[13] <= 10'b1001111100;  //  tcp $s0, $s0        ;two comp of y
//        memory[14] <= 10'b1001111110;  //  addi $s0, $s0, -2    
//        memory[15] <= 10'b1001111110;  //  addi $s0, $s0, -2    ;y=y-4
//        memory[16] <= 10'b0011100110;  //  sll $v0, $s0, $zero    ;f=(x*y)-4 
//        memory[17] <= 10'b1110000011;  //  halt

// Program 2, F = ( X*Y ) - 4, rewrite for pipeline
        memory[0] <= 10'b1100100010; // lw $t0, 2($zero)
        memory[1] <= 10'b0010100111; // sll $ra, $t0, $zero
        memory[2] <= 10'b1101000000; // lw $t1, 0($zero) ;$t1=x
        memory[3] <= 10'b0011000101;    // sll $a0, $t1, $zero  ;store original x in $a0
        memory[4] <= 10'b1001010111;  //  addi $t1, $t1, -1    ;x--
        memory[5] <= 10'b1101100001; //   lw $s0, 1($zero) ;$s0=y
        memory[6] <= 10'b0000111000; //   add $t0, $s0, $zer0    ;$t0=4
        memory[7] <= 10'b0111000001;  //  beq $t1, $zer0, 1    ;if x==0, pc=pc+4
        memory[8] <= 10'b0000000000; //nop
        memory[9] <= 10'b0001111001;  //  add $s0, $s0, $t0    ;y=y+4
        memory[10] <= 10'b1001010111;  //  addi $t1, $t1, -1    ;x--
        //memory[9] <= 10'b1111110101;  //  j -3            ;pc=pc-3
        memory[11] <= 10'b1110011100; // jr $ra
        memory[12] <= 10'b0000000000; //nop
        memory[13] <= 10'b0001000101;  //  add $t1, $zero, $a0    ;load original x
        memory[14] <= 10'b0101000010;  //  cmp $t1, $t1, $zer0
        memory[15] <= 10'b1000100010;  //  addi $t0, $zero, 2
        memory[16] <= 10'b0110110111;  //  beq $t0, $t1, -1    ;if x is pos, pc=pc+2
        memory[17] <= 10'b0000000000; //nop
        memory[18] <= 10'b1001111100;  //  tcp $s0, $s0        ;two comp of y
        memory[19] <= 10'b1001111110;  //  addi $s0, $s0, -2
        memory[20] <= 10'b1001111110;  //  addi $s0, $s0, -2    ;y=y-4
        memory[21] <= 10'b0011100110;  //  sll $v0, $s0, $zero    ;f=(x*y)-4
        memory[22] <= 10'b1110000011;  //  halt


        // program 3, array copy
//        memory[0] <= 10'b1100100000; // lw $t0, 0($zero) ;t0 = A address
//        memory[1] <= 10'b1101000001; // lw $t1, 1($zero) ;t1 = new_A address
//        memory[2] <= 10'b1101101000; // lw $s0, 0($t0) ;load A[i]
//        memory[3] <= 10'b0111100001; // beq $s0 $zero, 1 ;branch to finish if araay reaches end
//        memory[4] <= 10'b1011011000; // sw $s0, 0($t1) ;store new_A[i]
//        memory[5] <= 10'b1000101001; // addi $t0, $t0, 1 ;increment pointers
//        memory[6] <= 10'b1001010001; // addi $t1, $t1, 1
//        memory[7] <= 10'b1111101101; // j -5
//        memory[8] <= 10'b1000100011; // addi $t0, $zero, 3
//        memory[9] <= 10'b1000101011; // addi $t0, $t0, 3
//        memory[10] <= 10'b1000101011; // addi $t0, $t0, 3
//        memory[11] <= 10'b1000101001; // addi $t0, $t0, 1 ;t0 = 10
//        memory[12] <= 10'b0010100110; // sll $v0, $t0, $zero ;v0 = 10
//        memory[13] <= 10'b1110000011; // halt

        

//program 1
//memory[0] <= 10'b1010000011; // sw $zero, 3($zero)
//memory[1] <= 10'b1100100010; //  lw $t0, 2($zero) // t0 = i
//memory[2] <= 10'b1101000000; //  lw $t1, 0($zero) // t1 = n-3
//memory[3] <= 10'b1001010001; //  addi $t1, $t1, 1 // t1 = n-2
//memory[4] <= 10'b0100110011; //  cmp $s0, $t0, $t1  // i > n - 2 => 2
//memory[5] <= 10'b1000101001; //  addi $t0, $t0, 1 // i++
//memory[6] <= 10'b1010001010; //  sw $t0, 2($zero) // store i
//memory[7] <= 10'b1000100010; //  addi $t0, $zero, 2
//memory[8] <= 10'b0111101110; //  beq $s0, $t0, -2
//memory[9] <= 10'b1110001001; //   j 2
//memory[10] <= 10'b1110000011; //   halt

//memory[11] <= 10'b1100100011; //  lw $t0, 3($zero) // t0 = j
//memory[12] <= 10'b1101100001; //  lw $s0, 1($zero) // s0 = v
//memory[13] <= 10'b0001111001; //  add $s0, $s0, $t0  // s0 = addr v[j]
//memory[14] <= 10'b1101011000; //  lw $t1, 0($s0)  // t1 = v[j]
//memory[15] <= 10'b1101111001; //  lw $s0, 1($s0) // s0 = v[j + 1]
//memory[16] <= 10'b0101011001; //  cmp $t0, $t1, $s0  // v[j] > v[j+1] => 2
//memory[17] <= 10'b1001100010; //  addi $s0, $zero, 2 // s0 = 2
//memory[18] <= 10'b0111101110; //  beq $s0, $t0, -2
//memory[19] <= 10'b1110100001; //   j 8

//memory[20] <= 10'b1100100011; //  lw $t0, 3($zero) // t0 = j
//memory[21] <= 10'b1101100001; //  lw $s0, 1($zero) // s0 = v
//memory[22] <= 10'b0001111001; //  add $s0, $s0, $t0  // s0 = addr v[j]
//memory[23] <= 10'b1101011000; //  lw $t1, 0($s0)  // t1 = v[j]
//memory[24] <= 10'b1100111001; //  lw $t0, 1($s0) // s0 = v[j + 1]
//memory[25] <= 10'b1011110001; //  sw $t1, 1($s0) // v[j+1] = v[j]
//memory[26] <= 10'b1011101000; //  sw $t0, 0($s0) // v[j] = v[j+1]

//memory[27] <= 10'b1100100011; //  lw $t0, 3($zero) // t0 = j
//memory[28] <= 10'b1101000000; //  lw $t1, 0($zero) // t1 = n-3
//memory[29] <= 10'b0100110011; //  cmp $s0, $t0, $t1  // i > n - 2 => 2
//memory[30] <= 10'b1000101001; //  addi $t0, $t0, 1 // j++
//memory[31] <= 10'b1010001011; //  sw $t0, 3($zero) // store j
//memory[32] <= 10'b1000100010; //  addi $t0, $zero, 2
//memory[33] <= 10'b0111101000; //  beq $s0, $t0, 0
//memory[34] <= 10'b1000100011; //  addi $t0, $zero, 3
//memory[35] <= 10'b1101001001; //  lw $t1, 1($t0) // t1 = 10
//memory[36] <= 10'b1110001000; //   jr $t1 // j l2
//memory[37] <= 10'b1110000000; //   jr $zero // j l1

    end
endmodule


module DataMemory(
    input wire clk,
    input wire [9:0] address,
    input wire en_write,
    input wire [9:0] write_data,
    output reg [9:0] read_data
    );
    reg [9:0] memory[1023:0];

    integer i;
    always@(*)begin
        read_data <= memory[address];
    end
    
    always@(posedge clk)begin
        if ( en_write == 1'b1 ) begin
            memory[address] <= write_data;
        end
    end

    
    initial begin
        
        for ( i = 0; i < 1024; i = i +1 ) begin
            memory[i] <= 0;
        end
        memory[0] <= 10'b0000000100; // X for program 2
        memory[1] <= 10'b0000001000; // Y for program 2
        memory[2] <= 10'b0000000111;
        
        // Array A for program 3
//        memory[10] <= 10'b0000000001;
//        memory[11] <= 10'b0000000010;
//        memory[12] <= 10'b0000000011;
//        memory[13] <= 10'b0000000100;
//        memory[14] <= 10'b0000000101;
//        memory[15] <= 10'b0000000110;
//        memory[16] <= 10'b0000000111;
//        memory[17] <= 10'b0000001000;
//        memory[18] <= 10'b0000001001;
//        memory[19] <= 10'b0000001010;
        
//        memory[0] <= 10'b0000001010; // Base address for A in program 3, addr = 10
//        memory[1] <= 10'b0001100100; // Base address for new_A in program 3, addr = 100


// array for program 1
//        memory[109] <= 10'b0000000001;
//        memory[108] <= 10'b0000000010;
//        memory[107] <= 10'b0000000011;
//        memory[106] <= 10'b0000000100;
//        memory[105] <= 10'b0000000101;
//        memory[104] <= 10'b0000000110;
//        memory[103] <= 10'b0000000111;
//        memory[102] <= 10'b0000001000;
//        memory[101] <= 10'b0000001001;
//        memory[100] <= 10'b0000001010;
//        memory[99] <= 10'b0000000001;
//        memory[98] <= 10'b0000000010;
//        memory[97] <= 10'b0000000011;
//        memory[96] <= 10'b0000000100;
//        memory[95] <= 10'b0000000101;
//        memory[94] <= 10'b0000000110;
//        memory[93] <= 10'b0000000111;
//        memory[92] <= 10'b0000001000;
//        memory[91] <= 10'b0000001001;
//        memory[90] <= 10'b0000001010;
//        memory[99] <= 10'b0000000001;
//        memory[98] <= 10'b0000000010;
//        memory[97] <= 10'b0000000011;
//        memory[96] <= 10'b0000000100;
//        memory[95] <= 10'b0000000101;
//        memory[94] <= 10'b0000000110;
//        memory[93] <= 10'b0000000111;
//        memory[92] <= 10'b0000001000;
//        memory[91] <= 10'b0000001001;
//        memory[90] <= 10'b0000001010;
//        memory[89] <= 10'b0000000001;
//        memory[88] <= 10'b0000000010;
//        memory[87] <= 10'b0000000011;
//        memory[86] <= 10'b0000000100;
//        memory[85] <= 10'b0000000101;
//        memory[84] <= 10'b0000000110;
//        memory[83] <= 10'b0000000111;
//        memory[82] <= 10'b0000001000;
//        memory[81] <= 10'b0000001001;
//        memory[80] <= 10'b0000001010;
//        memory[79] <= 10'b0000000001;
//        memory[78] <= 10'b0000000010;
//        memory[77] <= 10'b0000000011;
//        memory[76] <= 10'b0000000100;
//        memory[75] <= 10'b0000000101;
//        memory[74] <= 10'b0000000110;
//        memory[73] <= 10'b0000000111;
//        memory[72] <= 10'b0000001000;
//        memory[71] <= 10'b0000001001;
//        memory[70] <= 10'b0000001010;
//        memory[69] <= 10'b0000000001;
//        memory[68] <= 10'b0000000010;
//        memory[67] <= 10'b0000000011;
//        memory[66] <= 10'b0000000100;
//        memory[65] <= 10'b0000000101;
//        memory[64] <= 10'b0000000110;
//        memory[63] <= 10'b0000000111;
//        memory[62] <= 10'b0000001000;
//        memory[61] <= 10'b0000001001;
//        memory[60] <= 10'b0000001010;
//        memory[59] <= 10'b0000000001;
//        memory[58] <= 10'b0000000010;
//        memory[57] <= 10'b0000000011;
//        memory[56] <= 10'b0000000100;
//        memory[55] <= 10'b0000000101;
//        memory[54] <= 10'b0000000110;
//        memory[53] <= 10'b0000000111;
//        memory[52] <= 10'b0000001000;
//        memory[51] <= 10'b0000001001;
//        memory[50] <= 10'b0000001010;
//        memory[49] <= 10'b0000000001;
//        memory[48] <= 10'b0000000010;
//        memory[47] <= 10'b0000000011;
//        memory[46] <= 10'b0000000100;
//        memory[45] <= 10'b0000000101;
//        memory[44] <= 10'b0000000110;
//        memory[43] <= 10'b0000000111;
//        memory[42] <= 10'b0000001000;
//        memory[41] <= 10'b0000001001;
//        memory[40] <= 10'b0000001010;
//        memory[39] <= 10'b1001000001;
//        memory[38] <= 10'b1001000010;
//        memory[37] <= 10'b1001000011;
//        memory[36] <= 10'b1001000100;
//        memory[35] <= 10'b1000000101;
//        memory[34] <= 10'b1000100110;
//        memory[33] <= 10'b1000100111;
//        memory[32] <= 10'b1000101000;
//        memory[31] <= 10'b1000101001;
//        memory[30] <= 10'b1000101010;
//        memory[29] <= 10'b1010000001;
//        memory[28] <= 10'b1010000010;
//        memory[27] <= 10'b1010000011;
//        memory[26] <= 10'b1010000100;
//        memory[25] <= 10'b1010000101;
//        memory[24] <= 10'b1000100110;
//        memory[23] <= 10'b1000100111;
//        memory[22] <= 10'b1000101000;
//        memory[21] <= 10'b1001001001;
//        memory[20] <= 10'b1000101010;
//        memory[19] <= 10'b0010000001;
//        memory[18] <= 10'b0010000010;
//        memory[17] <= 10'b0010000011;
//        memory[16] <= 10'b0010000100;
//        memory[15] <= 10'b0010000101;
//        memory[14] <= 10'b0010000110;
//        memory[13] <= 10'b0010000111;
//        memory[12] <= 10'b0010001000;
//        memory[11] <= 10'b0010001001;
//        memory[10] <= 10'b0010001010;
//        memory[29] <= 10'b0000100001;
//        memory[28] <= 10'b0000100010;
//        memory[27] <= 10'b0000100011;
//        memory[26] <= 10'b0000100100;
//        memory[25] <= 10'b0000100101;
//        memory[24] <= 10'b0000100110;
//        memory[23] <= 10'b0000100111;
//        memory[22] <= 10'b0000101000;
//        memory[21] <= 10'b0000101001;
//        memory[20] <= 10'b0001001010;
//        memory[19] <= 10'b0100000001;
//        memory[18] <= 10'b0100000010;
//        memory[17] <= 10'b0100000011;
//        memory[16] <= 10'b0100000100;
//        memory[15] <= 10'b0100000101;
//        memory[14] <= 10'b0100000110;
//        memory[13] <= 10'b0100000111;
//        memory[12] <= 10'b0100001000;
//        memory[11] <= 10'b0100001001;
//        memory[10] <= 10'b0100001010;
               
               //variables for program 1
               //memory[0] <= 10'b0001100001; // n - 3, n =100
               //memory[0] <= 10'b0000011011; // n - 3, n = 30
//               memory[0] <= 10'b0000000111; // n - 3, n = 10
//               memory[1] <= 10'b0000001010; // v address
//               memory[2] <= 10'b0000000000; // i
//               memory[3] <= 10'b0000000000; // j
//               memory[4] <= 10'b0000001011; // 11
        
    end
    
endmodule