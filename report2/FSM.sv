`timescale 1ns / 1ps

module FSM(
    input logic clk, rst,
    input logic start_in,
    input logic stop_in,
    input logic clear_in,
    output logic [7:0] sseg,
    output logic [7:0] an,
    output logic led
    );
    
    logic db_start, db_stop, db_clear;
    typedef enum {clear, stop, start, rand_timer, start_timer, stop_early} state_type;
    logic [3:0] hex3, hex2, hex1, hex0, dp_in;
    logic [3:0] hex3_in, hex2_in, hex1_in, hex0_in;
    logic [3:0] d3, d2, d1, d0;
    logic [3:0] d3_t, d2_t, d1_t, d0_t; //time elapsed
    logic [3:0] count_rnd;
    logic counter_en = 1'b0; //start at 0
    logic rand_go = 1'b0;
    logic [13:0] count_t; //time for random counter
    logic [13:0] count_rnd_max; //time goal for random number
   
    state_type state_reg, state_next;
    
    debounce start_but(
    .clk(clk),
    .rst(rst),
    .sw(start_in),
    .db_level(db_start),
    .db_tick()
    );
    
    debounce stop_but(
    .clk(clk),
    .rst(rst),
    .sw(stop_in),
    .db_level(db_stop),
    .db_tick()
    );
    
    debounce clear_but(
    .clk(clk),
    .rst(rst),
    .sw(clear_in),
    .db_level(db_clear),
    .db_tick()
    );
    
    disp_hex_mux disp(
    .clk(clk),
    .rst(rst),
    .hex3(hex3),
    .hex2(hex2),
    .hex1(hex1),
    .hex0(hex0),
    .dp_in(dp_in),
    .an(an[3:0]),
    .sseg(sseg)
    );
      
    bdc_counter counter_time
    (.clk(clk), .go(counter_en), .clr(rst), 
     .d3(d3), .d2(d2), .d1(d1), .d0(d0));
    
    an_mux h3(
    .an1(d3), .an2(hex3_in), .sel(counter_en), .an(hex3));
    an_mux h2(
    .an1(d2), .an2(hex2_in), .sel(counter_en), .an(hex2));
    an_mux h1(
    .an1(d1), .an2(hex1_in), .sel(counter_en), .an(hex1));
    an_mux h0(
    .an1(d0), .an2(hex0_in), .sel(counter_en), .an(hex0));
    
    LFSR random_num(
    .clk(clk),
    .rst(rst),
    .rnd(),
    .count_rnd(count_rnd)
    );
    
    rand_count my_rand(
    .clk(clk),
    .go(rand_go),
    .clr(rst),
    .count_t(count_t)
    );

    always_ff @(posedge clk, posedge rst)
       if(rst)
          begin
             state_reg <= clear;
          end
       else
          begin
             state_reg <= state_next;
          end
          
    always_comb
    begin
       state_next = state_reg;
       case(state_reg)
          clear: begin
             counter_en = 1'b0;
             led = 1'b0;
             rand_go = 1'b0;
             hex3_in = 4'hc; //off 
             hex2_in = 4'hc; //off
             hex1_in = 4'ha; //H
             hex0_in = 4'hb; //I 
             dp_in = 4'b1111;
             
             if(db_start)
                state_next = start; //add a stop check here?
                
          end
          start: begin
             counter_en = 1'b0;
             rand_go = 1'b0;
             
             if(db_clear)
                state_next = clear;
             else if(db_stop)
                state_next = stop;
             else 
                begin
                   state_next = rand_timer;
                   count_rnd_max = count_rnd*1000;
                end
          end
          
          rand_timer: begin
              counter_en = 1'b0; 
              rand_go = 1'b1;  
              hex0_in = 4'hc;
              hex1_in = 4'hc;
              hex2_in = 4'hc;
              hex3_in=4'hc;
              if(count_t == (count_rnd_max))
                 state_next = start_timer;
              else if(db_stop)
                 state_next = stop_early;
              
          end
          
          start_timer: begin
             
             led = 1'b1;
             counter_en = 1'b1;
             rand_go = 1'b0;
             d3_t = d3; 
             d2_t = d2;
             d1_t = d1;
             d0_t = d0;
             
             if(db_stop || (d3 == 1))
                state_next = stop;
             else if(db_clear)
                state_next = clear;
             
          end
          
          stop: begin
             rand_go = 1'b0;
             counter_en = 1'b0;
             led = 1'b0;
             hex3_in = d3_t;
             hex2_in = d2_t;
             hex1_in = d1_t;
             hex0_in = d0_t;
             
             if(db_clear)
                state_next = clear;
             else if(db_start)
                state_next = start;
          end
          
          stop_early: begin
             counter_en = 1'b0;
             led = 1'b0;
             hex3_in = 4'h9;
             hex2_in = 4'h9;
             hex1_in = 4'h9;
             hex0_in = 4'h9;
             
             if(db_clear)
                state_next = clear;
          end
          default: state_next = clear;
       endcase
    end
   
   assign an[7:4] = 4'b1111; //all off; 
endmodule