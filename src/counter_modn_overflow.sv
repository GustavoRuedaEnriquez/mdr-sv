// =============================================================================
// Title        :   Mod-n counter with overflow signal.
// Project      :   Sequential Multiplier
// File         :   counter_modn_overflow.sv
// Description  :   Module that defines the logic of a mo counter with a 
//                  overflow signal.
// Date         :   September 14th 2021
// =============================================================================
// Authors      :   Abisai Ramirez Perez
// =============================================================================

//Parameters:
// - FREQUENCY -> clk frequency.
// - DELAY -> Desired delay, usally 20-30ms.
// - MAX_COUNT -> Calculated parameter.
// - DW -> Calculated parameter.
module counter_modn_overflow #(parameter real FREQUENCY = 50_000_000, parameter real DELAY = 0.03, parameter int MAX_COUNT = (DELAY * FREQUENCY), parameter DW = $clog2(MAX_COUNT))
(
input        clk,
input        rst,
input        enable,
output logic overflow
);


typedef logic [DW-1:0] count_t;
typedef logic overflow_t;

typedef struct {
count_t      count;
overflow_t   overflow;
} counter_t;

counter_t  counter;
count_t    counter_next;

always_ff@(posedge clk, negedge rst)
begin: counter_seq
	if (!rst)
		counter.count <=  1'b0;
   else if (enable)
		counter.count <= counter_next;
end:counter_seq

always_comb
begin: comparator
	counter.overflow = (counter.count >= (MAX_COUNT - 1'b1)); 
	if (counter.count >= (MAX_COUNT - 1'b1))
		counter_next <= 1'b0;
	else
		counter_next <= counter.count + 1'b1;
end:comparator

assign overflow  =   counter.overflow;

endmodule


