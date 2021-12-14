// =============================================================================
// Title        : FSM Debouncer Package
// Project      : Sequential Multiplier
// File         : fsm_debouncer_pkg.sv
// Description  : File that contains the basic definitions for debouncers State
//                Machine.
// Date         : September 14th 2021  
// =============================================================================
// Authors      : Abisai Ramirez Perez
// =============================================================================

`ifndef DEBOUNCER_PKG_SV
    `define DEBOUNCER_PKG_SV
package fsm_debouncer_pkg;

localparam bit TRUE_DEBOUNCER  = 1'b1;
localparam bit FALSE_DEBOUNCER = 1'b0;

typedef enum logic [1:0]{
    LOW     = 2'b00, 
    DELAY_1 = 2'b01, 
    HIGH    = 2'b10, 
    DELAY_2 = 2'b11
} fsm_debouncer_state_e;

endpackage
`endif 

