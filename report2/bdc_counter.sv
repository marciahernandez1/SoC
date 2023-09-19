`timescale 1ns / 1ps

 module bdc_counter(
    input logic clk,
    input logic go,
    input logic clr,
    output logic [3:0] d3,
    output logic [3:0] d2,
    output logic [3:0] d1,
    output logic [3:0] d0
    );
    
//    localparam N = 22;
    localparam DVSR = 100000;  //1MHz
    logic [22:0] ms_reg;
    logic [22:0] ms_next;
    logic [3:0] d3_reg, d2_reg, d1_reg, d0_reg;
    logic [3:0] d3_next, d2_next, d1_next, d0_next;
    logic ms_tick;
    
    always_ff @(posedge clk)
    begin
       ms_reg <= ms_next;
       d3_reg <= d3_next;
       d2_reg <= d2_next;
       d1_reg <= d1_next;
       d0_reg <= d0_next;
    end
    
    //next state logic   
    assign ms_next = (clr || (ms_reg == DVSR & go)) ? 4'b0 : (go) ? ms_reg + 1 : ms_reg;
    
    assign ms_tick = (ms_reg==DVSR) ? 1'b1 : 1'b0;
    
    //3 digit bcd counter  
    always_comb
    begin
       d0_next = d0_reg; //start at 0? used to be d0_next = d0_reg
       d1_next = d1_reg;
       d2_next = d2_reg;
       d3_next = d3_reg;
       if(clr || ~go)
          begin
             d0_next = 4'b0;
             d1_next = 4'b0;
             d2_next = 4'b0;
             d3_next = 4'b0;
          end
       else if (ms_tick)
          if (d0_reg != 9)
              d0_next = d0_reg+1;
          else //XX9  
             begin
                d0_next = 4'b0;
                if (d1_reg != 9)
                   d1_next = d1_reg+1;
                else //X99 
                   begin
                      d1_next = 4'b0;
                      if (d2_reg != 9)
                         d2_next = d2_reg+1;
                      else
                         begin
                            d2_next = 4'b0;
                            if(d3_reg != 9)
                               d3_next = d3_reg+1;
                            else
                               d3_next = 4'b0; 
                         end 
                   end
             end      
    end
    
    //output logic 
    assign d0 = d0_reg;
    assign d1 = d1_reg; 
    assign d2 = d2_reg;   
    assign d3 = d3_reg;
    
endmodule
