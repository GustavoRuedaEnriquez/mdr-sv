// =============================================================================
// Title        : Adder
// Project      : MDR
// File         : adder.sv
// Description  : File that contains the adder module.
// Date         : October 23th 2021
// =============================================================================
// Authors      : Gustavo Rueda
// =============================================================================

module adder
import mdr_pkg::*;
(
    input  data_bus_n a, 
    input  data_bus_n b,
    output data_bus_n out
);

assign out = a + b;

endmodule
