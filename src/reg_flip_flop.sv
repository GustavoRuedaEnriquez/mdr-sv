// =============================================================================
// Title        : Flip flop
// Project      : MDR
// File         : reg_flip_flop.sv
// Description  : File that contains the definition of a simple flip flop.
//                register.
// Date         : October 23th 2021  
// =============================================================================
// Authors      : Gustavo Rueda
// =============================================================================

module reg_flip_flop #(parameter DW = 4) (
input               clk,
input  [DW-1:0]     in,
output [DW-1:0]     out
);

logic [DW-1:0]      rgstr_r;

always_ff@(posedge clk)
begin: register_label
        rgstr_r  <= in;
end:register_label

assign out = rgstr_r;

endmodule
