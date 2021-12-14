package tb_mdr_pkg;

localparam DW = 10;
localparam PERIOD = 4;
typedef logic signed [DW-1:0]       data_t;
typedef logic signed [2*DW-1:0]     results_t;
typedef  enum logic [1:0] {
    MULTI   = 2'd0,
    DIV     = 2'd1,
    SQRT    = 2'd2
    } op_e;

endpackage
