// =============================================================================
// Title        :   Binary counter with overflow signal.
// Project      :   Sequential Multiplier
// File         :   counter_binary_overflow.sv
// Description  :   Module that defines the logic of a binary counter with a 
//                  overflow signal.
// Date         :   September 11th 2021
// =============================================================================
// Authors      :   Abisai Ramirez Perez
// =============================================================================

module counter_binary_overflow #(parameter DW = 3, MAX_COUNT = 5)
(
input  bit           clk,
input  bit           rst,
input  logic         enable,
output logic         overflow,
output logic         first,
output logic[DW-1:0]   count
);

logic [DW-1:0] count_r, count_nxt;

always_ff@(posedge clk, negedge rst)
begin: counter
	if (!rst)
		count_r <=  1'b0;
	else if (enable)
	begin
		if(overflow)
			count_r <= 1'b0;
		else
			count_r <= count_nxt;
	end
end:counter


always_comb
begin: comparator
	if (count_r == 1'b0)
		first = 1'b1 & enable;
	else
		first = 1'b0;
   if (count_r >= MAX_COUNT)
		overflow = 1'b1;
   else
      overflow = 1'b0;
	count_nxt = count_r + 1'b1;
end: comparator

assign count = count_r;

endmodule
