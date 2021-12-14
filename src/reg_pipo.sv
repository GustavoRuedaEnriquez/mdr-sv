// =============================================================================
// Title        :   Simple PIPO register.
// Project      :   Sequential Multiplier
// File         :   reg_pipo.sv
// Description  :   Module that defines a parametric PIPO register.
// Date         :   September 9th 2021
// =============================================================================
// Authors      :   Abisai Ramirez Perez
// =============================================================================

module reg_pipo #(parameter DW = 4) (
input               clk,
input               rst,
input               enable,
input  [DW-1:0]     in,
output [DW-1:0]     out
);

logic [DW-1:0]      rgstr_r;

always_ff@(posedge clk or negedge rst)
begin: register_label
    if(!rst)
        rgstr_r  <= 1'b0;
    else if (enable)
        rgstr_r  <= in;
end:register_label

assign out = rgstr_r;

endmodule
