
module Buffer(out, empty_room, dist, packet_size, in, push, pop);
  
  /*********** Parameters ************/
    
  parameter addr_w = 3;
  parameter width = 10;
  parameter size = 5;
  
  /*********** Output-Input ************/
  
  output reg [width-1:0] out;
  output reg [addr_w-1:0] empty_room, packet_size;
  output reg [width-1-2:0] dist;
  
  input [width-1:0] in;
  input push, pop;
  
  /*********** Variables ************/ 
  
  reg [width-1:0] Q [0:size-1];
  reg [addr_w-1:0] head, tail;
  reg is_new_packet;
  
  /*********** Initials ************/
  
  integer i;
  initial begin
    for(i=0;i<size;i=i+1)
      Q[i] = i * 2;
    head = 1;
    tail = 1;
    out = Q[head];
    empty_room = size;
    packet_size = 0;
    dist = 0;
  end
  
  /*********** Code ************/
  
  always @(posedge pop) begin
    if(head != tail) begin
      is_new_packet = 0;
      if(Q[head][width-1:width-2] == 1 || Q[head][width-1:width-2] == 3) is_new_packet = 1;
      head = (head + 1) % size;
      out = Q[head];
      if(is_new_packet) begin
        if(packet_size + empty_room == size) begin
          empty_room = size;
          packet_size = 0;
          dist = 7;
        end
        else update_status();
      end
    end
  end
  
  always @(posedge push) begin
    if(empty_room != 0) begin
      is_new_packet = 0;
      Q[tail] = in;
      if(Q[tail][width-1:width-2] == 1 || Q[tail][width-1:width-2] == 3) is_new_packet = 1;
      tail = (tail + 1) % size;
      if(is_new_packet && empty_room == size) update_status();
    end
  end
  
  task automatic update_status;
    
    reg [addr_w-1:0] i = head, cnt = 0;
    
    begin
      dist = Q[head][width-3:0];
      while(Q[i][width-1:width-2] != 1 && Q[i][width-1:width-2] != 3 && i != tail) begin
        cnt = cnt + 1;
        i = (i + 1) % size;
      end
      empty_room = size - (tail + size - head) % size;
      packet_size = cnt + 1;
      if(Q[i][width-1:width-2] != 1 && Q[i][width-1:width-2] != 3) begin
        empty_room = size;
        packet_size = 0;
        dist = 7;
      end
    end
    
  endtask
  
endmodule
      