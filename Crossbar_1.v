module Crossbar(
  out_top, push_top, pop_top,
  out_right, push_right, pop_right,
  out_bottom, push_bottom, pop_bottom,
  out_left, push_left, pop_left,
  
  in_top, empty_room_top, dist_top, packet_size_top,
  in_right, empty_room_right, dist_right, packet_size_right,
  in_bottom, empty_room_bottom, dist_bottom, packet_size_bottom,
  in_left, empty_room_left, dist_left, packet_size_left,
  
  clk
  );
  
  /*********** Parameters ************/
    
  parameter addr_w = 3, width = 10;
  parameter id = 0, network_width = 1;
  
  /*********** Output-Input ************/
  
  output reg [width-1:0] out_top, out_right, out_bottom, out_left;
  output reg push_top, pop_top, push_right, pop_right, push_bottom, pop_bottom, push_left, pop_left;
  
  input [width-1:0] in_top, in_right, in_bottom, in_left;
  input [addr_w-1:0] empty_room_top, packet_size_top,
                     empty_room_right, packet_size_right,
                     empty_room_bottom, packet_size_bottom,
                     empty_room_left, packet_size_left;
                     
  input [width-3:0] dist_top, dist_right, dist_bottom, dist_left;
  input clk;
  
  /*********** Variables ************/
  
  reg [width-1:0] out;
  reg [addr_w-1:0] empty_room, packet_size;
  reg [width-3:0] dist;
  reg is_sending;
  integer i, dir;
  
  /*********** Code ************/
  
  always @(posedge clk) begin : block
    for(i=0;i<4;i=i+1) begin
      is_sending = 0;
      copy();
      send_if_possible();
      if(is_sending) disable block;
    end
  end

  task automatic copy_empty_room;
    begin
      case(dir)
        0: empty_room = empty_room_bottom;
        1: empty_room = empty_room_left;
        2: empty_room = empty_room_right;
        3: empty_room = empty_room_top;
      endcase
    end
  endtask
  
  task automatic copy;
    begin
      case(i)
        0: begin
          out = in_bottom;
          packet_size = packet_size_bottom;
          dist = dist_bottom;
        end
        1: begin
          out = in_left;
          packet_size = packet_size_left;
          dist = dist_left;
        end
        2: begin
          out = in_right;
          packet_size = packet_size_right;
          dist = dist_right;
        end
        3: begin
          out = in_top;
          packet_size = packet_size_top;
          dist = dist_top;
        end
      endcase
    end
  endtask
  
  task automatic send_if_possible;
    begin
      
      /**
      left = 1
      bottom = 0
      top = 3
      right = 2
      **/
      
      if(dist%network_width > id%network_width) begin
        dir = 2;
      end else if(dist%network_width < id%network_width) begin
        dir = 1;
      end else if(dist%network_width == id%network_width) begin
        if(dist/network_width > id/network_width) begin
          dir = 0;
        end else if(dist/network_width < id/network_width) begin
          dir = 3;
        end
      end
      
      copy_empty_room();
      
      /** if buffer is not empty and there is enough room for packet **/
      if(packet_size != 0 && packet_size <= empty_room) begin
        case(dir)
          0: begin
            out_bottom = out;
            /** push on clock posedge **/
            push_bottom = 0;
            push_bottom = 1;
            push_bottom = 0;
          end
          1: begin
            out_left = out;
            push_left = 0;
            push_left = 1;
            push_left = 0;            
          end
          2: begin
            out_right = out;
            push_right = 0;
            push_right = 1;
            push_right = 0;
          end
          3: begin
            out_top = out;
            push_top = 0;
            push_top = 1;
            push_top = 0;
          end
        endcase
        case(i)
          0: begin
            pop_bottom = 0;
            pop_bottom = 1;
            pop_bottom = 0;
          end
          1: begin
            pop_bottom = 0;
            pop_bottom = 1;
            pop_bottom = 0;
          end
          2: begin
            pop_bottom = 0;
            pop_bottom = 1;
            pop_bottom = 0;
          end
          3: begin
            pop_bottom = 0;
            pop_bottom = 1;
            pop_bottom = 0;
          end
        endcase
        is_sending = 1;
      end
      
    end
  endtask
  
endmodule

