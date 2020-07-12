`timescale 1ns/1ps
//This module implements a parametric queue
//It provides also an output which signals how many values have been 
//stored inside the queue. 
//
//  ------
//  |    |
//  ------
//  | // | <-tail
//  ------
//  | A  |
//  ------
//  | B   | <-head
//  ------
//
module fifo #(
    parameter DWIDTH          = 16,
    parameter COUNT_WIDTH     = 7
)(
  input  logic                  clk,
  input  logic                  reset,
  input  logic [DWIDTH-1:0]     din,
  input  logic                  wr_en,
  input  logic                  rd_en,
  output logic [DWIDTH-1:0]     dout,
  output logic                  full,
  output logic                  empty,
  output logic [COUNT_WIDTH-1:0]data_count
);

logic [2:0]             state_cur, state_next;
logic [COUNT_WIDTH-1:0] head     , head_next ,  head_incremented;
logic [COUNT_WIDTH-1:0] tail     , tail_next ,  tail_incremented;


(* ram_style = "block" *) logic [DWIDTH-1:0]      content [(2**COUNT_WIDTH)-1:0];
logic write_enable, read_enable;
logic [DWIDTH-1:0] from_memory, from_din, middle, middle_next;


always_ff @( posedge clk ) begin 
    if(reset)
    begin
        state_cur <= 3'b000;
        head      <= {(COUNT_WIDTH) {1'b0} };
        tail      <= {(COUNT_WIDTH) {1'b0} };
    end
    else
    begin
        head      <= head_next;
        tail      <= tail_next;
        state_cur <= state_next;
    end
end

always_ff @(posedge clk)begin

    if(write_enable)
    begin
        content[tail] <= din;
    end

    from_memory  <= content[head_incremented];

    middle       <= middle_next;
end
assign from_din = din;

//        +---------------+      W           +---------------+                       
//        |     000       -------------------|     100       |-------> R&W           
//        |               <-------------------               <-------                
//        +-------^-------+      R         -->---------|-----<-------------------+   
//                |                    ---/            |                         |   
//                | R             ----/                |W                        |   
//                |           ---/R&W,_                |                         |   
//        +-------|-------+--/     R         +---------v-----+                   |   
//        |     010       <-------------------     101       |          R&C==2   |   
//        |               ------------------->               |                   |   
//        +-------^-------+        W       /-----------|-----+                   |   
//                |                   /----            |                         |   
//                |R              /---                 |W,_                      |   
//                |          /---- R&W                 |                         |   
// R&W    +-------|-------<--                +---------v-----+                   |   
//   <-----     011       ------------------->   111         |                   |   
//   ----->               |       W,_        |               --------------------+   
//        +---------------+                  +-------|-^-----+                       
//                                                   | |                             
//                                                   | |                             
//                                                   v |                             
//                                                  W,R&W,_                 
always_comb begin //create full empty signals
    data_count       = tail - head;
    head_incremented = head + 1 ;
    tail_incremented = tail + 1 ;

    //empty
    if( head == tail )            empty = 1'b1;
    else                          empty = 1'b0;
    //full
    if( head == tail_incremented) full = 1'b1;
    else                          full = 1'b0;

    //validate read/write signals
    //and compute next_head/next_tail
    write_enable     = 1'b0;
    read_enable      = 1'b0;
    tail_next        = tail;
    head_next        = head;

    if(wr_en && ~full )
    begin
        write_enable = 1'b1;
        tail_next    = tail_incremented;
    end

    if(rd_en && ~empty)
    begin
        read_enable = 1'b1;
        head_next   = head_incremented;
    end
    
    //little FSM to track validity of 
    //middle register and memory
    //bit states represent: register, memory_output, memory_content 
    // validity.
    state_next  = state_cur;
    middle_next = middle;
    dout        = middle;
    case(state_cur)
    3'b000:
    begin
        if(write_enable) 
        begin
            state_next = 3'b100;  
            middle_next= from_din;  
        end    
    end
    3'b100:
    begin
        dout = middle;
        case({write_enable, read_enable})
            2'b11:
            begin
                state_next = state_cur;
                middle_next= from_din;  
            end
            2'b10:
            begin
                state_next = 3'b101;    
                //middle kept
            end    
            2'b01:
            begin
                state_next = 3'b000;
                //void queue even if middle kept no problem, would be invalid.
            end
        endcase
    end
    3'b101:
    begin
        dout = middle;
        case({write_enable, read_enable})
            2'b11:
            begin
                state_next = 3'b011;
                //middle can't be updated (memory invalid)
            end
            2'b10:
            begin
                state_next = 3'b111;
                //middle don't need to be updated
            end
            2'b01:
            begin
                state_next = 3'b010;
                //middle can't be updated (memory invalid)
            end
            default:
            begin
                state_next = 3'b111;
                //middle don't need to be updated
            end
        endcase
    end
    3'b010:
    begin
        dout = from_memory;
        case({write_enable, read_enable})
            2'b11:
            begin
                state_next = 3'b100;
                middle_next= from_din;
            end
            2'b10:
            begin
                state_next = 3'b101;
                middle_next= from_memory;
            end
            2'b01:
            begin
                state_next = 3'b000;
                //queue is void
            end
            default:
            begin
                state_next = 3'b100;
                middle_next= from_memory;
            end
        endcase
    end
    3'b011:
    begin
        dout = from_memory;
        case({write_enable, read_enable})
            2'b11:
            begin
                state_next = state_cur;
                //data_in is written in memory and 
                //middle  is not used
            end
            2'b10:
            begin
                state_next = 3'b111;
                middle_next= from_memory;
            end
            2'b01:
            begin
                state_next = 3'b010;
            end
            default:
            begin
                state_next = 3'b111;
                middle_next= from_memory;
            end
        endcase
    end
    3'b111:
    begin
        dout = middle;
        
        if(read_enable )
        begin 
            middle_next= from_memory;
            if(data_count == 2 )
            begin
                state_next = 3'b100;
            end
            
        end
    end
    endcase
end



endmodule
