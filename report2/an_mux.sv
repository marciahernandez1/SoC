`timescale 1ns / 1ps

module an_mux(
input logic [3:0] an1,
input logic [3:0] an2, 
input logic sel,
output logic [3:0] an
);
    
assign an = (sel)? an1: an2;
		
endmodule
