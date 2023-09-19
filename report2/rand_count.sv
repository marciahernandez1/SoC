`timescale 1ns / 1ps

module rand_count(
    input logic clk,
    input logic go,
    input logic clr,
    output logic [13:0] count_t //2^14
    );
    
    localparam DVSR = 100000;  //1MHz
    logic [22:0] ms_reg;
    logic [22:0] ms_next;
    logic ms_tick;
    logic [13:0] count_reg = 14'b0;
    logic [13:0] count_next;
    
    always_ff @(posedge clk)
    begin
       ms_reg <= ms_next;
       count_reg <= count_next;
    end
    
    //next state logic   
    assign ms_next = (clr || (ms_reg == DVSR & go)) ? 4'b0 : (go) ? ms_reg + 1 : ms_reg;
    
    assign ms_tick = (ms_reg==DVSR) ? 1'b1 : 1'b0;
    
    //3 digit bcd counter  
    always_comb
    begin
      count_next = count_reg;
      if(clr || ~go)
          begin
             count_next = 13'b0;
          end
      else if (ms_tick)
         count_next = count_reg +1;
      
    end
    
    assign count_t = count_reg;

    
endmodule