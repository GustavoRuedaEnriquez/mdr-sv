// =============================================================================
// Title        :   Binary-to-complement2 converter.
// Project      :   Sequential Multiplier
// File         :   converter_bin_to_c2.sv
// Description  :   Module that converts binary format to complement 2.
// Date         :   September 9th 2021
// =============================================================================
// Authors      :   Gustavo Rueda
// =============================================================================

module converter_bin_to_c2
import mdr_pkg::*;
(
input  logic	  sign,
input  data_bus_n binary,
output data_bus_n complement2
);
	
assign complement2  = sign ? ~binary + {{DW_MDR-1{1'b0}},1'b1} : binary;

endmodule
