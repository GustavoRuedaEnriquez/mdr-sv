// =============================================================================
// Title        : Substracter
// Project      : MDR
// File         : subtracter.sv
// Description  : File that contains the substracter module.
// Date         : October 23th 2021
// =============================================================================
// Authors      : Gustavo Rueda
// =============================================================================

module subtracter
import mdr_pkg::*;
(
    input  data_bus_n a, 
    input  data_bus_n b,
    output data_bus_n out
);

assign out = a - b;

endmodule