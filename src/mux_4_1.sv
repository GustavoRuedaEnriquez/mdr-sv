// =============================================================================
// Title        :   Multiplexer 4 to 1
// Project      :   MDR
// File         :   mux_4_1.sv
// Description  :   File that contains the 4 to 1 multiplexer.
// Date         :   October 20th 2021
// =============================================================================
// Authors      :   Gustavo Rueda
// =============================================================================

module mux_4_1 #(parameter DW = 4, parameter DW_SEL = 2)
(
input  logic [DW-1:0]     i_a,
input  logic [DW-1:0]     i_b,
input  logic [DW-1:0]     i_c,
input  logic [DW-1:0]     i_d,
input  logic [DW_SEL-1:0] i_sel,
output logic [DW-1:0]     o_sltd
);

assign  o_sltd = (i_sel == 2'b00) ? (i_a) :
                 (i_sel == 2'b01) ? (i_b) :
                 (i_sel == 2'b10) ? (i_c) :
                 i_d;

endmodule
