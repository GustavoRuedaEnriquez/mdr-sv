// =============================================================================
// Title        : Debouncer module.
// Project      :	Sequential Multiplier
// File         : debouncer.sv
// Description  : File that contains the debouncer's top.
// Date         : September 14th 2021  
// =============================================================================
// Authors      :	Abisai Ramirez Perez
// =============================================================================

module debouncer (
input  bit   clk,
input  bit   rst,
input  bit   d_in,
output logic one_shot
);

logic delay_30ms_ready; 
logic enable_counter;

fsm_debouncer
i_fsm_debouncer (
    .clk              ( clk              ),
    .rst              ( rst              ),
    .d_in             ( d_in             ),
    .delay_30ms_ready ( delay_30ms_ready ),
    .enable_counter   ( enable_counter   ),
    .one_shot         ( one_shot         )
);

counter_modn_overflow #(.FREQUENCY(10_000), .DELAY(0.03))
i_counter_mod_n (
    .clk      ( clk              ),
    .rst      ( rst              ),
    .enable   ( enable_counter   ),
    .overflow ( delay_30ms_ready )
);

endmodule
