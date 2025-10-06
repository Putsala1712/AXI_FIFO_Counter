`timescale 1ns / 1ps

module fifo_axi #(parameter DATA_WIDTH=32, FIFO_DEPTH=16)(
//Global Signals
input aclk, aresetn,
//Input slave interface
input [DATA_WIDTH-1:0] s_data,
input s_valid,
output  s_ready,
//Output master interface
output reg [DATA_WIDTH-1:0] m_data,
output  m_valid,
input m_ready
    );
    //fifo parameters
    localparam ptr_width = $clog2(FIFO_DEPTH);
    reg [DATA_WIDTH-1:0] fifo_mem [0:FIFO_DEPTH-1]; // memory array 
    reg [ptr_width-1:0] rd_ptr,wr_ptr; // read and write pointers
    reg [ptr_width:0]count;
    
    wire empty = (count == 0);  
    wire full  = (count == FIFO_DEPTH);
     
    assign s_ready = !full;
    assign m_valid = !empty;
  
    wire rd_en = (m_valid && m_ready);
    wire wr_en = (s_valid && s_ready);
    
    always@(*) begin
    if(empty) m_data = 32'hx;
    else m_data = fifo_mem[rd_ptr];
    end
    
    always@(posedge aclk or negedge aresetn)
    begin
  
    if(!aresetn) begin
    wr_ptr <= 0;
    rd_ptr <= 0;
    count <= 0;
    
    end
    
    else begin
    
    //Writing data into the FIFO
    if (wr_en) 
    begin
         fifo_mem[wr_ptr] <= s_data;
         wr_ptr <= wr_ptr + 1 ;
    end
       
    //Reading data from FIFO
    if (rd_en) 
    begin
          rd_ptr <= rd_ptr + 1;
          
    end
    
    case({wr_en , rd_en})
    2'b10 : count <= count + 1;
    2'b01 : count <= count - 1;
    default : count <= count;
    endcase
    end 
    end
    
endmodule
