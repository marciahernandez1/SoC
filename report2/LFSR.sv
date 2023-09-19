`timescale 1ns / 1ps

//TO BE CHANGED to more bits to grab the last 4 random bits. 
module LFSR(
    input logic clk,
    input logic rst,
    output logic rnd,
    output logic [3:0] count_rnd
    );
    
    //logic [3:0] count, ncount;
    logic [3:0] count, ncount;
    //1 bit confusing enough to be random 
    logic feedback;
    
    always_ff@(posedge clk, posedge rst)
       if(rst) //shouldnt be 0- cause everey bit 0 will get us tuck bc exclusive or
          count<= 4'b0001;//if it was xnor we would have to set it to 0 but xor is better
       else
          count <= ncount; //creating memory bits 
    
    always_comb
    begin 
       feedback = count[0]^count[1] ;  
       ncount = {feedback,count[3:1]}; //3 and 4  bits according to datasheet thing
       rnd = feedback;
       
       if(count < 4'b0010)
          count_rnd = 4'b0010;
       else
          count_rnd = count; 
    end
    
endmodule
