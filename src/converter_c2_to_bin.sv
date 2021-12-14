// =============================================================================
// Title        :   Complement2-to-binary converter.
// Project      :   Sequential Multiplier
// File         :   converter_c2_to_bin.sv
// Description  :   Module that converts complement 2 format to binary.
// Date         :   September 9th 2021
// =============================================================================
// Authors      :   Gustavo Rueda
// =============================================================================

module converter_c2_to_bin
import mdr_pkg::*;
(
input  data_bus_n complement2,
output logic      sign,
output data_bus_n binary
);

assign sign    = complement2[DW_MDR - 1];
assign binary  = sign ? ~complement2 + {{DW_MDR-1{1'b0}},1'b1} : complement2;

endmodule
