`timescale 1ns / 1ps

module FSM_wrapper(
    input logic clk,
    input logic rst,
    input logic BTNU, BTNC, BTND, BTNL,
    output logic DP, CG, CF, CE, CD, CC, CB, CA, 
    output logic [7:0] AN,
    output logic LED0
    );
    
    FSM reaction_timer(
    .clk(clk),
    .rst(BTNL),
    .start_in(BTNC),
    .stop_in(BTND),
    .clear_in(BTNU),
    .sseg({DP, CG, CF, CE, CD, CC, CB, CA}),
    .an(AN),
    .led(LED0)
    );
    
endmodule
