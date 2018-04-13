`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/09/2018 02:45:48 PM
// Design Name: 
// Module Name: Cache
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

module CacheTest();
    reg clk;
    reg write_en;
    reg [9:0] write_data;
    reg [9:0] address;
    
    wire [9:0] read_data;
    wire ready;
    
    Cache c0( .clk(clk), .write_en(write_en), .address(address), .read_data(read_data), .ready(ready) );


    //toggle clock every 18ns
    always #5 clk = ~clk;
    
    initial begin
        clk = 1; 
        // write some test data
        write_en = 1;
        address = 10'b0000000000;
        write_data = 10'b1111000011;
        #10;
        address = 10'b0000000001;
        write_data = 10'b0000111111;
        #10;
        address = 10'b0000000010;
        write_data = 10'b1111001111;
        #10;
        address = 10'b0000000011;
        write_data = 10'b1111110011;
        #10;
        // read that test data
        write_en = 0;
        address = 10'b0000000000;
        #10;
        address = 10'b0000000001;
        #10;
        address = 10'b0000000010;
        #10;
        address = 10'b0000000011;
        #10;
    end
endmodule

module Cache(    
    input clk, 
    input write_en,
    input [9:0] write_data,
    input [9:0] address,
    output reg[9:0] read_data,
    output reg ready
    );
         
    reg[29:0] CacheMem[7:0][1:0];    // 29 bits/block, 8 sets, 2 blocks/set
        
    reg block_index_sel;     
    
    reg Miss;
    reg miss0;
    reg miss1;
    reg dirty;
    reg[2:0] index;
    
    wire evict;
    wire ram_load;
    wire ram_ready;
    wire [19:0] ram_data;
    reg [19:0] to_ram;
    reg [9:0] ram_address;
    
    DataRam ram0(ram_data, ram_ready, clk, evict, ram_address, to_ram);
    CacheController cont0( clk, Miss, dirty, ram_ready, ram_load, evict, ready);
    
    // initialize cache with all zeros
    reg[7:0] i; 
    reg[2:0] j;
    initial begin
        for (i = 0; i < 8; i = i + 1) begin
            for (j = 0; j < 2; j = j + 1)begin
                CacheMem[i][j] <= 29'b0;
            end
        end
    end
        
    always@(*)
    begin
        index <= address[3:1];
        
        // check block 0
        if (CacheMem[index][0][28] == 0 || CacheMem[index][0][25:20] != address[9:4])
            miss0 <= 1'b1;
        else
            miss0 <= 1'b0;
        
        // check clock 1
        if (CacheMem[index][1][28] == 0 || CacheMem[index][1][25:20] != address[9:4])
            miss1 <= 1'b1;
        else
            miss1 <= 1'b0;
                        
        Miss <= miss0 & miss1;
             
        case(Miss)
        // HIT
            0: begin
                block_index_sel <= miss0;
                dirty <= 1'b0;
            end
        // MISS
            1: begin
                block_index_sel <= CacheMem[index][0][26];
                dirty <= CacheMem[index][block_index_sel][27];
            end
            default: begin
                block_index_sel <= 1'b0;
                dirty <= 1'b0;
            end
        endcase
        
        // cache HIT read data
        case(address[0])
            1: read_data <= CacheMem[index][block_index_sel][19:10];
            default: read_data <= CacheMem[index][block_index_sel][9:0];
        endcase
        
        ram_address <= {CacheMem[index][block_index_sel][25:20], index, 1'b0}; 
        to_ram <= CacheMem[index][block_index_sel][19:0];
    end       
          
    always@(negedge clk)begin
        // load from ram to cache
        if (ram_load == 1) begin
            if (write_en == 0)
                CacheMem[index][block_index_sel][19:0] <= ram_data;
            else begin
                if (block_index_sel == 1)begin
                    CacheMem[index][block_index_sel][9:0] <= ram_data[9:0];
                end
                else begin
                    CacheMem[index][block_index_sel][19:10] <= ram_data[19:10];
                end
            end
       
            CacheMem[index][block_index_sel][28] <= 1'b1;
            CacheMem[index][block_index_sel][27] <= 1'b0;
            CacheMem[index][block_index_sel][26] <= 1'b1;
            CacheMem[index][!block_index_sel][26] <= 1'b0;
        end
        
        // write to cache
        else if (Miss == 0 && write_en == 1) begin
            if (address[0] == 1)begin
                CacheMem[index][block_index_sel][19:10] <= write_data;
            end
            else begin
                CacheMem[index][block_index_sel][9:0] <= write_data;
            end
            
            CacheMem[index][block_index_sel][27] <= 1'b1;
            CacheMem[index][block_index_sel][26] <= 1'b1;
            CacheMem[index][!block_index_sel][26] <= 1'b0;
            
        end
    end
    
    // load tag to cache at positive edge if there is a miss
    always@(posedge clk) begin
        if (Miss == 1 || ram_load == 1)begin
           CacheMem[index][block_index_sel][25:20] <= address[9:4];
        end
    end
endmodule

