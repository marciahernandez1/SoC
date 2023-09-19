`timescale 1ns / 1ps

module debounce(
    input logic clk,
    input logic rst,
    input logic sw,
    output logic db_level,
    output logic db_tick
    );
    
    
    localparam N = 21; //20 ms  CHANGE TO 20 OR 22 FOR BOARD ~module should work. 
    
    typedef enum {zero, wait1, one, wait0} state_type;
    
    state_type state_reg, state_next;
    logic [N-1:0] q_reg, q_next;
    
    always_ff @(posedge clk, posedge rst)
       if(rst)
          begin
             state_reg <= zero;
             q_reg <= 0;
          end
       else
          begin
             state_reg <= state_next;
             q_reg <= q_next;
          end
          
//    //next state logic 
//    assign q_next = (q_load) ? {N{1'b1}} : 
//                    (q_dec)  ? q_reg - 1 : 
//                               q_reg;
    
//    assign q_zero = (q_next == 0);
    
    always_comb
    begin 
       state_next = state_reg; //default state - the same
       //q_reg = {N{1'b0}}; //for simulation
       q_next = q_reg; //default
       db_tick = 1'b0;
       db_level = 1'b0;
       case(state_reg)
          zero: begin
             if(sw) begin
                state_next = wait1; 
                q_next = {N{1'b1}};
             end 
          end
          wait1: begin
             if (sw) begin
                q_next = q_reg -1;
                if(q_next == 0) begin   
                   state_next = one;
                   db_tick = 1'b1;  
                end
             end
             else
                state_next = zero;
          end
          one: begin
             db_level = 1'b1;
             if (~sw) begin 
                state_next = wait0;
                q_next = {N{1'b1}};
             end
          end
          wait0: begin
             db_level = 1'b1;  
             if (~sw) begin 
                q_next = q_reg - 1;
                if(q_next == 0) 
                   state_next = zero;
             end     
             else
                state_next = one;
          end 
          default: state_next = zero;
       endcase
    end                
           
endmodule
