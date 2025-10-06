`timescale 1ns / 1ps

module fifo_axitb();
    parameter DATA_WIDTH = 32;
    parameter FIFO_DEPTH = 16;

    reg aclk;
    reg aresetn;

    // Slave interface
    reg  [DATA_WIDTH-1:0] s_data;
    reg  s_valid;
    wire s_ready;

    // Master interface
    wire [DATA_WIDTH-1:0] m_data;
    wire m_valid;
    reg  m_ready;
    integer i,j,w_done,r_done,x,y;
    // DUT instantiation
    fifo_axi #(DATA_WIDTH,FIFO_DEPTH) dut (aclk,aresetn,s_data,s_valid,s_ready,m_data,m_valid,m_ready);
    
    // Clock generation
    initial aclk=0;
    always #5 aclk = ~aclk;
    
    initial begin
   
    aresetn = 0;
    s_valid = 0;
    s_data  = 0;
    m_ready = 0;

    #20 aresetn = 1;
    end

    task write(input [DATA_WIDTH-1:0] in, output integer wf);
    begin
    @(posedge aclk);
    wf=0;
    s_valid = $urandom_range(0,1);
    if(s_valid) begin
    s_data = in;
    wf=1;
   // #10;
    //s_valid=0;
    end
    else s_valid = 0;
    @(posedge aclk);
    end
    endtask
    
    
    task read(output integer rf);
    begin
    @(posedge aclk);
    rf=0;
    m_ready=$urandom_range(0,1);
    if(m_ready) begin
    rf=1; //#10;
    //m_ready=0;
    end
    end
    endtask
    

    initial begin
    
    @(posedge aresetn);
    @(posedge aclk);
    
    $display("Writing data into fifo until it's full ");
    
    i=0;
    
    while(i<=FIFO_DEPTH) 
    begin
    //@(posedge aclk);
    write($random,w_done);
    if(w_done) i=i+1;
    #10;
    s_valid=0;
    end
    
    s_valid=0;
    
    $display("Reading data from fifo until it's empty ");
    j=0;
    while(j<=FIFO_DEPTH) begin
    read(r_done);
    if(r_done) j=j+1;
    #10;
    end
    
    m_ready=0;
    
    $display("Simultaneous writing and reading data for fifo ");
    
    fork
    
    begin
    x=0;
    
    while(x<=(FIFO_DEPTH+FIFO_DEPTH)) 
    begin
    @(posedge aclk);
    write($random,w_done);
    if(w_done) x=x+1;
    #10;
    s_valid=0;
    end 
    
    end
    
    begin
    y=0;
    while(y<=(FIFO_DEPTH+FIFO_DEPTH)) begin
    read(r_done);
    if(r_done) y=y+1;
    #10;
    end
    end
    join
    
    #20 $finish;
    end
endmodule
