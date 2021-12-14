// =============================================================================
// Title        :   MDR Package
// Project      :   MDR
// File         :   mdr_pkg.sv
// Description  :   File that contains the basic definitions for the MDR´s
//                  project.
// Date         :   October 19th 2021
// =============================================================================
// Authors      :   Gustavo Rueda
// =============================================================================


`ifndef MDR_PKG_SV
    `define MDR_PKG_SV
package mdr_pkg;

localparam FALSE         = 1'b0;
localparam TRUE          = 1'b1;
localparam DW_MDR        = 10;
localparam W_STATES      = 3;
localparam W_OPS         = 2;
localparam D_SHIFT_VALUE = (2 * DW_MDR) - 2;
localparam SEGMENT_WIDTH = 7;

typedef logic [DW_MDR-1:0]         data_bus_n;
typedef logic [2*DW_MDR-1:0]       data_bus_2n;
typedef logic [W_OPS-1:0]          op_bus;
typedef logic [SEGMENT_WIDTH- 1:0] segments_conf;

localparam data_bus_n  ZEROS = {DW_MDR{1'b0}};	
localparam data_bus_2n ONES  = {DW_MDR{1'b1}};

typedef logic       mux_2_to_1_sel_t;
typedef logic [1:0] mux_3_to_1_sel_t;
typedef logic [1:0] mux_4_to_1_sel_t;
typedef logic [2:0] mux_5_to_1_sel_t;


typedef enum logic [W_STATES-1:0]{
	STATE_IDLE,
	STATE_LOAD_X,
	STATE_LOAD_Y,
	STATE_PROCESSING,
	STATE_ERROR
} state_fsm_e;

typedef enum logic [W_OPS-1:0]{
	MULT,
	DIV,
	SQRT,
	SQRT_FINAL
} operation_e;

endpackage
`endif
	