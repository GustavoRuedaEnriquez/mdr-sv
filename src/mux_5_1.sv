// =============================================================================
// Title        :   Multiplexer 5 to 1
// Project      :   MDR
// File         :   mux_5_1.sv
// Description  :   File that contains the 5 to 1 multiplexer.
// Date         :   October 20th 2021
// =============================================================================
// Authors      :   Gustavo Rueda
// =============================================================================

module mux_5_1 #(parameter DW = 4, parameter DW_SEL = 3)
(
input  logic [DW-1:0]     i_a,
input  logic [DW-1:0]     i_b,
input  logic [DW-1:0]     i_c,
input  logic [DW-1:0]     i_d,
input  logic [DW-1:0]     i_e,
input  logic [DW_SEL-1:0] i_sel,
output logic [DW-1:0]     o_sltd
);

assign  o_sltd = (i_sel == 3'b000) ? (i_a) :
                 (i_sel == 3'b001) ? (i_b) :
                 (i_sel == 3'b010) ? (i_c) :
                 (i_sel == 3'b011) ? (i_d) :
                 (i_e);

endmodule
