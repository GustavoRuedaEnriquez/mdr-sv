// =============================================================================
// Title        :   Decoder for decimals on a seven segments display.
// Project      :   Decoder Binary 2s Complement
// File         :   decoder_decimal_seven_segments.sv
// Description  :   Module that implements the decimal representation on a seven
//                  segments display.
// Date         :   September 30th 2021
// =============================================================================
// Authors      :   Gustavo Rueda
// =============================================================================

module decoder_decimal_seven_segments#(parameter DW = 4, parameter SEGMENTS = 7)
(
input  [DW-1:0]       decimal_number,
input                 error,
output [SEGMENTS-1:0] segments_configuration
);

assign segments_configuration =                       //  6543210
	       (decimal_number == 4'd0 && error == 1'b0) ? (7'b1000000):
	       (decimal_number == 4'd1 && error == 1'b0) ? (7'b1111001):
	       (decimal_number == 4'd2 && error == 1'b0) ? (7'b0100100):
	       (decimal_number == 4'd3 && error == 1'b0) ? (7'b0110000):
	       (decimal_number == 4'd4 && error == 1'b0) ? (7'b0011001):
	       (decimal_number == 4'd5 && error == 1'b0) ? (7'b0010010):
	       (decimal_number == 4'd6 && error == 1'b0) ? (7'b0000010):
	       (decimal_number == 4'd7 && error == 1'b0) ? (7'b1111000):
	       (decimal_number == 4'd8 && error == 1'b0) ? (7'b0000000):
	       (decimal_number == 4'd9 && error == 1'b0) ? (7'b0010000):
			 (error == 1'b1) ?                           (7'b0001110):
	       (7'b1111111);



endmodule
