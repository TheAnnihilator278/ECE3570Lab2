`timescale 1ns / 1ns

module CacheTest;
    wire rdy;
    wire[9:0] readVal;
    reg clk, w_en;
    reg [9:0] addr;
    reg [9:0] wr_data;
    
    Cache tb(clk, w_en, wr_data, addr, readVal, rdy);
    
    always #10 clk = ~clk;
    
    initial begin
        w_en = 0;
        addr = 0;
        wr_data = 0;
        clk = 0;                  #20
        addr = 10'b0000000001;    #80
        addr = 10'b0000000011;
        wr_data = 10'b0000110101; #80
        w_en = 1;                 #80
        w_en = 0;
        addr = 10'b0000000010;    #80
        addr = 10'b0000010010;    #80
        addr = 10'b0000100010;    #80
        w_en = 1;
        addr = 10'b0000101110; 
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
         
    reg[28:0] CacheMem[7:0][1:0];    //29 bits/block, 8 sets, 2 blocks/set
    reg[2:0] index;
    reg block_index_sel;
    reg miss0, miss1, Miss;
    reg dirty;
    
    wire cont_ready;
    wire evict;
    wire ram_load;
    wire ram_ready;
    wire [19:0] ram_data;
    reg [19:0] to_ram;
    reg [9:0] ram_address;
    
    RAM ram0(.read_data(ram_data), .done(ram_ready), .clk(clk), .write_en(evict), .addr(ram_address), .write_data(to_ram) );
    cache_cont cont0(.clk(clk), .miss(Miss), .dirty(dirty), .r_ram(ram_ready), .ld(ram_load), .ev(evict), .rdy(cont_ready));
    
    // initialize cache with all zeros
    integer i, j;
    initial begin
        for (i=0; i<8; i=i+1)
            for (j=0; j<2; j=j+1)
                CacheMem[i][j] <= 29'b0;
    end
        
    always@(*)
    begin
        ready <= cont_ready;
    
        index <= address[3:1];
        
        // Check block 0
        if (CacheMem[index][0][28] == 0 || CacheMem[index][0][25:20] != address[9:4])
            miss0 <= 1'b1;
        else
            miss0 <= 1'b0;
        
        // Check block 1
        if (CacheMem[index][1][28] == 0 || CacheMem[index][1][25:20] != address[9:4])
            miss1 <= 1'b1;
        else
            miss1 <= 1'b0;
                        
        Miss <= miss0 & miss1;
        
        case (Miss)
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
        case (address[0])
            1: read_data <= CacheMem[index][block_index_sel][19:10];
            default: read_data <= CacheMem[index][block_index_sel][9:0];
        endcase
        
        ram_address <= {CacheMem[index][block_index_sel][25:20], index, 1'b0};
        to_ram <= CacheMem[index][block_index_sel][19:0];
    end
    
    // load tag to cache at positive edge if there is a miss
    always@(posedge clk) begin
        if (Miss == 1 || ram_load == 1) begin
           CacheMem[index][block_index_sel][25:20] <= address[9:4];
       end
    end
          
    always@(negedge clk) begin
        // load from ram to cache
        if (ram_load == 1) begin
            if (write_en == 0)
                CacheMem[index][block_index_sel][19:0] <= ram_data;
            else begin
                if (block_index_sel == 1)
                    CacheMem[index][block_index_sel][9:0] <= ram_data[9:0];
                else
                    CacheMem[index][block_index_sel][19:10] <= ram_data[19:10];
            end
       
            CacheMem[index][block_index_sel][28] <= 1'b1;
            CacheMem[index][block_index_sel][27] <= 1'b0;
            CacheMem[index][block_index_sel][26] <= 1'b1;
            CacheMem[index][!block_index_sel][26] <= 1'b0;
        end
        
        // write to cache
        else if (Miss == 0 && write_en == 1) begin
            if (address[0] == 1)
                CacheMem[index][block_index_sel][19:10] <= write_data;
            else
                CacheMem[index][block_index_sel][9:0] <= write_data;
            
            CacheMem[index][block_index_sel][27] <= 1'b1;
            CacheMem[index][block_index_sel][26] <= 1'b1;
            CacheMem[index][!block_index_sel][26] <= 1'b0;
        end
    end
endmodule

module cache_cont (
        output reg ld,  // Load Flag
        output reg ev,  // Eviction Flag
        output reg rdy, // Ready Flag
        input clk,      // Clock input signal
        input miss,     // Indicates cache miss
        input dirty,    // Indicates dirty cache
        input r_ram     // Ram is ready flag
    );
    reg state;
    
    // Set initial values:
    //  No eviction or load initially
    //  The cache is ready
    //  Initial state is 0
    initial {ld,ev,rdy,state}=4'b0010;
    
    always @(*) begin
        ev = miss & dirty & ~state; // If dirty and miss in state 0 set evict flag
        ld = ~ev & state;           // Else, if in state 1 set load flag
        rdy = ~ld & ~miss;          // Else, if no miss, set ready flag
    end
    
    always @(posedge clk) begin 
        if (miss)            // if a miss, toggle state
            state <= ~state;
        if (state & r_ram)   // if in state 1 and ram ready,
            state <= 0;      //  return to state 0
    end
endmodule

module cache_cont_tb ();
    wire ld, ev, rdy;
    reg clk=0, miss=0, dirty=0, r_ram=0;
    
    cache_cont test(ld, ev, rdy, clk, miss, dirty, r_ram);
    
    always #5 clk = ~clk;
    
    initial begin
        miss=1;     #20
        r_ram=1;    #20
        miss=0;
        r_ram=0;    #20
        miss=1;
        dirty=1;    #20
        miss=0;     #20
        miss=1;     #209
        $finish;
    end
endmodule

module RAM(
        input clk,
        input write_en,
        input [9:0] addr, // address of offset 0 or 1 
        input [19:0] write_data, //9:0 offset data 0, 19:10 offset data 1
        output reg [19:0] read_data, //9:0 offset data 0, 19:10 offset data 1 
        output reg done
    );
    
    reg [9:0] memory[1023:0];
    
    integer i;
    
    initial begin
        for ( i = 0; i < 1024; i = i +1 ) begin
            memory[i] <= 0;
        end
    
        memory[0] <= 10'b001110011;
        memory[1] <= 10'b001100001;
        memory[2] <= 10'b000100011;
        memory[3] <= 10'b001100000;
        memory[4] <= 10'b001110011;
        memory[5] <= 10'b001110001;
        memory[6] <= 10'b000101111;
        memory[7] <= 10'b001101000;
    end
    
    always@(*) begin
        read_data[9:0] <= memory[{addr[9:1], 1'b0}];
        read_data[19:10] <= memory[{addr[9:1], 1'b1}];
        
        if(write_en ==1) begin
            if ({memory[{addr[9:1], 1'b1}], memory[{addr[9:1], 1'b0}]} == write_data)
                done <= 1'b1;
            else
                done <= 1'b0;
            end
        else
            done <= 1'b1;
    end 
    
    always@(posedge clk) begin
        if(write_en ==1) begin
          memory[{addr[9:1], 1'b0}] <= write_data[9:0];
          memory[{addr[9:1], 1'b1}] <= write_data[19:10];
        end
   end
endmodule
module RAM_Test();
     reg clk;
     reg write_en;
     reg [9:0] addr;
     reg [19:0] write_data;
     wire [19:0] read_data;
     wire done;
     
    //toggle clock every 4ns
    always #4 clk = ~clk;
    
    RAM ram( .clk(clk), .write_en(write_en), .addr(addr), .write_data(write_data), .read_data(read_data), .done(done));
    
    initial begin
        clk = 1;    
        write_en = 1'b0;  
        addr = 10'b0000000000; 
        #16;

        
        addr = 10'b0000000001;
        write_data = 20'b00000000001111111111;
        
       #16;
       
       write_en = 1'b1;
       addr = 10'b0000000001;
       write_data = 20'b00000000001111111111;
       
       #16;
       
       write_en = 1'b1;
       addr = 10'b0000000011;
       write_data = 20'b01010101010101010101;
       
       #16;
       write_en = 1'b0; 
       addr = 10'b0000000001;
       #16;
       addr = 10'b0000000011;
        
    end
endmodule
