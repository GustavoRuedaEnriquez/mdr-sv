// =============================================================================
// Title        :   Multiplexer 2 to 1
// Project      :   MDR
// File         :   mux_2_1.sv
// Description  :   File that contains the 2 to 1 multiplexer.
// Date         :   October 20th 2021
// =============================================================================
// Authors      :   Gustavo Rueda
// =============================================================================

module mux_2_1 #(parameter DW = 4)
(
input  logic [DW-1:0] i_a,
input  logic [DW-1:0] i_b,
input  logic          i_sel,
output logic [DW-1:0] o_sltd
);

assign  o_sltd = (i_sel) ? (i_b): (i_a);

endmodule
