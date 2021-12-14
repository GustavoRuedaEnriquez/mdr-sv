// =============================================================================
// Title        :   MDR Top
// Project      :   MDR
// File         :   mdr_top.sv
// Description  :   File that contains the MDR's top module.
// Date         :   October 20th 2021
// =============================================================================
// Authors      :   Gustavo Rueda
// =============================================================================

module mdr_top
import mdr_pkg::*;
(
input  bit           clk,
input  bit           rst,
input  bit           start,
input  bit           load,
input  data_bus_n    data,
input  op_bus        op,
output logic         ready,
output logic         load_x,
output logic         load_y,
output logic         error,
output data_bus_n    result,
output data_bus_n    remainder,
output logic         segments_sign,
output segments_conf segments_hundreds,
output segments_conf segments_tens,
output segments_conf segments_units
);

localparam MAXBITCOUNT = $clog2(DW_MDR + 1);

logic wr_clk;
logic wr_start;
logic wr_reset;
logic wr_load;
data_bus_n wr_data;
op_bus    wr_op;

/* Count wire */
logic [MAXBITCOUNT-1:0] wr_count;

/* Load X/Y wires */
data_bus_n  wr_data_x;
data_bus_n  wr_data_y;
logic       wr_load_x_enable;
logic       wr_load_y_enable;
data_bus_n  wr_data_x_internal;
data_bus_n  wr_data_y_internal;
logic       wr_sign_x;
logic       wr_sign_y;
data_bus_n  wr_data_x_bin;
data_bus_n  wr_data_y_bin;

/* PIPE wires */
logic wr_ready_pipe_out;

/* Mux wires */
mux_2_to_1_sel_t wr_mux_x_sel;
mux_2_to_1_sel_t wr_mux_y_sel;
mux_2_to_1_sel_t wr_mux_d_sel;
mux_4_to_1_sel_t wr_mux_0_sel;
mux_5_to_1_sel_t wr_mux_1_sel;
mux_3_to_1_sel_t wr_mux_2_sel;
mux_2_to_1_sel_t wr_mux_3_sel;
mux_2_to_1_sel_t wr_mux_4_sel;
mux_2_to_1_sel_t wr_mux_5_sel;
mux_3_to_1_sel_t wr_mux_6_sel;
data_bus_n wr_mux_0_out;
data_bus_n wr_mux_3_out;
data_bus_n wr_mux_4_out;
data_bus_n wr_mux_5_out;
data_bus_n wr_mux_6_out;
logic      wr_mux_ready_out;

/* FSM wires */
logic wr_aux;
logic wr_ready;
logic wr_error;
logic wr_error_enable;
logic wr_counter_enable;
logic wr_counter_first;
logic wr_counter_overflow;
logic wr_is_division;
op_bus wr_alu_sel;

/* ALU wires */
data_bus_2n wr_d;
data_bus_n wr_op_a;
data_bus_n wr_op_b;
data_bus_n wr_add_out_alu;
data_bus_n wr_sub_out_alu;
data_bus_n wr_shift_out_alu;

/* Operand wires */
data_bus_2n wr_d_in;
data_bus_n  wr_op_a_in;
data_bus_n  wr_op_b_in;
logic       wr_aux_in;
logic       wr_op_enable;
logic       wr_shift_enable;

/* Results wires */
logic      wr_remainder_final_sign;
data_bus_n wr_internal_result_c2;
data_bus_n wr_internal_remainder_c2;

/* Decoder wires */
logic wr_decoder_sign;
logic [3:0] wr_hundreds;
logic [3:0] wr_tens;
logic [3:0] wr_units;

/********************************************/
assign wr_reset = rst;

/*----------------------------------------------------*/
/*                      DEBOUNCERS                    */
/*----------------------------------------------------*/

`ifndef SIMULATION
pll_50MHz pll(
	.areset(~wr_reset),
	.inclk0(clk),
	.c0(wr_clk),
	.locked()
);
`else
assign wr_clk = clk;
`endif

`ifndef SIMULATION
debouncer
debouncer_start
(
    .clk(wr_clk),
    .rst(wr_reset),
    .d_in(~start),
    .one_shot(wr_start)
);
`else
assign wr_start = start;
`endif


`ifndef SIMULATION
debouncer
debouncer_load
(
    .clk(wr_clk),
    .rst(wr_reset),
    .d_in(~load),
    .one_shot(wr_load)
);
`else
assign wr_load = load;
`endif

/*----------------------------------------------------*/
/*                      INPUT PIPOS                   */
/*----------------------------------------------------*/

reg_pipo#(.DW(W_OPS))
pipo_op
(
    .clk(wr_clk),
    .rst(wr_reset),
    .enable(wr_start),
    .in(op),
    .out(wr_op)
);

/*----------------------------------------------------*/
/*                      LOAD X/Y                      */
/*----------------------------------------------------*/

/* PIPO LX */ 
reg_pipo#(.DW(DW_MDR))
pipo_load_x
(
    .clk(wr_clk),
    .rst(wr_reset),
    .enable(wr_load_x_enable & wr_load),
    .in(data),
    .out(wr_data_x)
);

/* PIPO LY */
reg_pipo#(.DW(DW_MDR))
pipo_load_y
(
    .clk(wr_clk),
    .rst(wr_reset),
    .enable(wr_load_y_enable & wr_load),
    .in(data),
    .out(wr_data_y)
);

/* CONVERTER X */
converter_c2_to_bin
c2_bin_x
(
    .complement2(wr_data_x),
    .sign(wr_sign_x),
    .binary(wr_data_x_bin)
);

/* CONVERTER Y */
converter_c2_to_bin
c2_bin_y
(
    .complement2(wr_data_y),
    .sign(wr_sign_y),
    .binary(wr_data_y_bin)
);


/* MUX X */
mux_2_1#(.DW(DW_MDR))
mux_x
(
    .i_a(wr_data_x),
    .i_b(wr_data_x_bin),
    .i_sel(wr_mux_x_sel),
    .o_sltd(wr_data_x_internal)
);

/* MUX Y */
mux_2_1#(.DW(DW_MDR))
mux_y
(
    .i_a(wr_data_y),
    .i_b(wr_data_y_bin),
    .i_sel(wr_mux_y_sel),
    .o_sltd(wr_data_y_internal)
);


/*----------------------------------------------------*/
/*                      CONTROL                       */
/*----------------------------------------------------*/

control_mdr
control_unit
(
    .clk(wr_clk),
    .rst(wr_reset),
	.op(wr_op),
    .in_start(wr_start),
    .in_load(wr_load),
	.in_data_x(wr_data_x),
	.in_data_y(wr_data_y),
	.op_a(wr_op_a),
	.op_b(wr_op_b),
    .out_load_x(load_x),
    .out_load_y(load_y),
    .out_ready(wr_ready),
    .out_error(wr_error),
	.error_enable(wr_error_enable),
    .counter_first(wr_counter_first),
    .counter_overflow(wr_counter_overflow),
    .aux(wr_aux),
    .load_x_enable(wr_load_x_enable),
    .load_y_enable(wr_load_y_enable),
	.alu_sel(wr_alu_sel),
    .counter_enable(wr_counter_enable),
    .operator_enable(wr_op_enable),
    .shift(wr_shift_enable),
	.is_division(wr_is_division),
    .mux_x_sel(wr_mux_x_sel),
    .mux_y_sel(wr_mux_y_sel),
	.mux_d_sel(wr_mux_d_sel),
    .mux_0_sel(wr_mux_0_sel),
    .mux_1_sel(wr_mux_1_sel),
    .mux_2_sel(wr_mux_2_sel),
    .mux_3_sel(wr_mux_3_sel),
    .mux_4_sel(wr_mux_4_sel),
	.mux_5_sel(wr_mux_5_sel),
    .mux_6_sel(wr_mux_6_sel),
	.mux_ready_sel(wr_mux_ready_out)
);

/* COUNTER */
counter_binary_overflow#(.DW(MAXBITCOUNT),.MAX_COUNT(DW_MDR + 1))
counter
(
    .clk(wr_clk),
    .rst(wr_reset),
    .enable(wr_counter_enable),
    .overflow(wr_counter_overflow),
	 .first(wr_counter_first),
	 .count(wr_count)
);

/* ALU */
alu
alu_module(
    .in_value_x(wr_data_x_internal),
	.in_value_d(wr_d),
    .in_operator_a(wr_op_a),
    .in_operator_b(wr_op_b),
    .in_alu_select(wr_alu_sel),
    .add(wr_add_out_alu),
    .sub(wr_sub_out_alu),
    .shift(wr_shift_out_alu)
);

/* MUX 0 */
mux_4_1#(.DW(DW_MDR))
mux_0(
    .i_a(wr_shift_out_alu),
    .i_b(wr_add_out_alu),
    .i_c(wr_sub_out_alu),
    .i_d({DW_MDR{1'b0}}),
    .i_sel(wr_mux_0_sel),
    .o_sltd(wr_mux_0_out)
);

/* MUX OP_A */
mux_2_1#(.DW(DW_MDR))
mux_op_a(
    .i_a(wr_mux_0_out),
    .i_b(wr_op_a),
    .i_sel(wr_mux_0_out[DW_MDR-1] & wr_is_division),
    .o_sltd(wr_op_a_in)
);

/* MUX 1 */
mux_5_1#(.DW(DW_MDR))
mux_1(
    .i_a(  wr_data_y_internal ),
    .i_b({ wr_mux_0_out[0], wr_op_b[DW_MDR-1:1] }),
    .i_c({ wr_op_b[DW_MDR-1:1], ~wr_mux_0_out[DW_MDR-1] }),
	.i_d({ wr_op_b[DW_MDR-2:0], ~wr_mux_0_out[DW_MDR-1] }),
    .i_e({DW_MDR{1'b0}}),
    .i_sel(wr_mux_1_sel),
    .o_sltd(wr_op_b_in)
);
	
/* MUX 2 */
mux_3_1#(.DW(1'b1))
mux_2(
    .i_a(wr_op_b[0]),
    .i_b(wr_mux_0_out[DW_MDR-1]),
    .i_c(1'b0),
    .i_sel(wr_mux_2_sel),
    .o_sltd(wr_aux_in)
);

/* MUX D */
mux_2_1#(.DW(2*DW_MDR))
mux_D(
    .i_a({{DW_MDR{1'b0}}, wr_data_x_internal}),
    .i_b({wr_d[2*DW_MDR-3:0],2'b0}),
    .i_sel(wr_mux_d_sel),
    .o_sltd(wr_d_in)
);

/* Operands Register */
operands
operands_reg(
    .clk(wr_clk),
    .rst(wr_reset),
	.enable(wr_op_enable),
	.ready(ready),
	.shift_enable(wr_shift_enable),
	.op_sel(wr_op),
	.op_a_in(wr_op_a_in),
	.op_b_in(wr_op_b_in),
	.aux_in(wr_aux_in),
	.d_in(wr_d_in),
	.op_a_out(wr_op_a),
	.op_b_out(wr_op_b),
	.aux_out(wr_aux),
	.d_out(wr_d)
);

/*----------------------------------------------------*/
/*                PREPARING THE RESULT                */
/*----------------------------------------------------*/
/* CONVERTER RESULT */
converter_bin_to_c2
bin_c2_result
(
    .sign(wr_sign_x ^ wr_sign_y),
    .binary(wr_op_b),
    .complement2(wr_internal_result_c2)
);


/* MUX 3 */
mux_2_1#(.DW(DW_MDR))
mux_3(
    .i_a( wr_op_b ),
    .i_b({wr_internal_result_c2}),
    .i_sel(wr_mux_3_sel),
    .o_sltd(wr_mux_3_out)
);

/* MUX 5 */
mux_2_1#(.DW(DW_MDR))
mux_5(
    .i_a(wr_mux_3_out),
    .i_b({DW_MDR{1'b1}}),
    .i_sel(wr_mux_5_sel),
    .o_sltd(wr_mux_5_out)
);

/* MUX 4 */
mux_2_1#(.DW(DW_MDR))
mux_4(
    .i_a({DW_MDR{1'b0}}),
    .i_b({wr_op_a}),
    .i_sel(wr_mux_4_sel),
    .o_sltd(wr_mux_4_out)
);

assign wr_remainder_final_sign = (~wr_sign_x & wr_sign_y) | (wr_sign_x & wr_sign_y);

/* CONVERTER REMAINDER */
converter_bin_to_c2
bin_c2_remainder
(
    .sign(wr_remainder_final_sign),
    .binary(wr_mux_4_out),
    .complement2(wr_internal_remainder_c2)
);

/* MUX 6 */
mux_3_1#(.DW(DW_MDR))
mux_6(
    .i_a(wr_mux_4_out),
    .i_b({wr_internal_remainder_c2}),
	.i_c(wr_mux_0_out),
    .i_sel(wr_mux_6_sel),
    .o_sltd(wr_mux_6_out)
);


/*----------------------------------------------------*/
/*                   OUTPUT PIPOS                     */
/*----------------------------------------------------*/
/* PIPO RESULT */ 
reg_pipo#(.DW(DW_MDR))
pipo_result
(
    .clk(wr_clk),
    .rst(wr_reset),
    .enable(wr_counter_overflow | wr_start),
    .in(wr_mux_5_out),
    .out(result)
);

/* PIPO REMAIDER */
reg_pipo#(.DW(DW_MDR))
pipo_remainder
(
    .clk(wr_clk),
    .rst(wr_reset),
    .enable(wr_counter_overflow | wr_start),
    .in(wr_mux_6_out),
    .out(remainder)
);

/* FF READY */
reg_flip_flop#(.DW(1'b1))
ff_ready
(
    .clk(wr_clk),
    .in(wr_ready),
    .out(wr_ready_pipe_out)
);

/* MUX READY */
mux_2_1#(.DW(1'b1))
mux_ready(
    .i_a(wr_ready),
    .i_b(wr_ready_pipe_out),
    .i_sel(wr_mux_ready_out),
    .o_sltd(ready)
);

/* PIPO ERROR */ 
reg_pipo#(.DW(1'b1))
pipo_error
(
    .clk(wr_clk),
    .rst(wr_reset),
    .enable(wr_counter_overflow | wr_start),
    .in(wr_error | wr_mux_5_sel),
    .out(error)
);

/* SEGMENTS DECODER */

// Converter
converter_c2_to_decimal#(.DW(DW_MDR))
c2_to_decimal(
	.complement2(result),
	.sign(wr_decoder_sign),
	.hundreds(wr_hundreds),
	.tens(wr_tens),
	.units(wr_units)
);

assign segments_sign = (error == 1'b1) ? 1'b1 : ~wr_decoder_sign;

decoder_decimal_seven_segments
hundreds_decoder(
	.decimal_number(wr_hundreds[3:0]),
	.error(error),
	.segments_configuration(segments_hundreds)
);

decoder_decimal_seven_segments
tens_decoder(
	.decimal_number(wr_tens[3:0]),
	.error(error),
	.segments_configuration(segments_tens)
);

decoder_decimal_seven_segments
units_decoder(
	.decimal_number(wr_units[3:0]),
	.error(error),
	.segments_configuration(segments_units)
);


endmodule

