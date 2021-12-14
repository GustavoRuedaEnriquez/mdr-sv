// =============================================================================
// Title        : ALU
// Project      : MDR
// File         : alu.sv
// Description  : File that contains the definition of the ALU unit, this unit
//                will perform the additions, subtractions and shiftings.
// Date         : October 19th 2021  
// =============================================================================
// Authors      : Gustavo Rueda
// =============================================================================

module alu
import mdr_pkg::*;
(
	input  data_bus_n   in_value_x,
	input  data_bus_2n  in_value_d,
	input  data_bus_n   in_operator_a,
	input  data_bus_n   in_operator_b,
	input  op_bus       in_alu_select,
	output data_bus_n   add,
	output data_bus_n   sub,
	output data_bus_n   shift
);

data_bus_2n wr_value_d_shifted;
data_bus_n wr_a_add;
data_bus_n wr_b_add;
data_bus_n wr_a_sub;
data_bus_n wr_b_sub;

assign wr_value_d_shifted = (in_value_d >> D_SHIFT_VALUE);

always_comb
begin: alu_comb_block
	case(in_alu_select)
	MULT:
	begin
	wr_a_add = in_operator_a;
	wr_b_add = in_value_x;
   wr_a_sub = in_operator_a;
   wr_b_sub = in_value_x;
	shift = in_operator_a;
  end
  
  DIV:
  begin
	  wr_a_add = in_operator_a;
	  wr_b_add = in_value_x;
     wr_a_sub = in_operator_a;
     wr_b_sub = in_value_x;
	  shift = '0;
  end
  
	SQRT:
	begin
		//in_operator_a << 2 | ( wr_value_d_shifted[DW_MDR-1:0] & 2'd3 )
		wr_a_add = {in_operator_a[DW_MDR-3:0],( wr_value_d_shifted[1:0] & 2'd3 )};
		wr_a_sub = {in_operator_a[DW_MDR-3:0],( wr_value_d_shifted[1:0] & 2'd3 )};
		//in_operator_b << 2 | {{DW_MDR-2{1'b0}},2'd3};
		wr_b_add = {in_operator_b[DW_MDR-3:0], 2'd3};
		wr_b_sub = {in_operator_b[DW_MDR-3:0], 2'd1};
		shift = '0;
	end
  
	SQRT_FINAL:
	begin
		wr_a_add = in_operator_a;
		wr_b_add = {in_operator_b[DW_MDR-2:0], 1'b1};
		wr_a_sub = '0;
		wr_b_sub = '0;
		shift = '0;
	end
	
	default:
	begin
		wr_a_add = '0;
		wr_b_add = '0;
		wr_a_sub = '0;
		wr_b_sub = '0;
		shift    = '0;
	end
  endcase
end: alu_comb_block

adder
adder_module
(
  .a(wr_a_add), 
  .b(wr_b_add),
  .out(add)
);

subtracter
subtracter_module
(
  .a(wr_a_sub), 
  .b(wr_b_sub),
  .out(sub)
);

endmodule
