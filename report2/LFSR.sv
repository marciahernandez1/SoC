`timescale 1ns / 1ps

module LFSR(
    input logic clk,
    input logic rst,
    output logic rnd,
    output logic [3:0] count_rnd
    );
    
    logic [3:0] count, ncount;
    logic feedback;
    
    always_ff@(posedge clk, posedge rst)
       if(rst) 
          count<= 4'b0001;
       else
          count <= ncount; 
    
    always_comb
    begin 
       feedback = count[0]^count[1] ;  
       ncount = {feedback,count[3:1]}; 
       rnd = feedback;
       
       if(count < 4'b0010)
          count_rnd = 4'b0010;
       else
          count_rnd = count; 
    end
    
endmodule
