// =============================================================================
// Title        :   Operands register
// Project      :   MDR
// File         :   operands.sv
// Description  :   File that contains the A, B and aux registers.
// Date         :   October 20th 2021
// =============================================================================
// Authors      :   Gustavo Rueda
// =============================================================================

module operands
import mdr_pkg::*;
(
	input              clk,
	input              rst,
	input              enable,
	input              ready,
	input  logic	   shift_enable,
	input  op_bus 	   op_sel,
	input  data_bus_n  op_a_in,
	input  data_bus_n  op_b_in,
	input  logic	   aux_in,
	input  data_bus_2n d_in,
	output data_bus_n  op_a_out,
	output data_bus_n  op_b_out,
	output logic	   aux_out,
	output data_bus_2n d_out
);

data_bus_n  r_op_a;
data_bus_n  r_op_b;
logic 	    r_aux;
data_bus_2n r_d_value;

always_ff@(posedge clk or negedge rst)
begin: rgstr_label
	if(!rst)
    begin
    	r_op_a    <= '0;
		r_op_b    <= '0;
		r_aux     <= '0;
		r_d_value <= '0;
	end
    else if (enable && !ready)
    begin
    	r_op_a    <= op_a_in;
		r_op_b    <= op_b_in;
		r_aux     <= aux_in;
		r_d_value <= d_in;
	end
	else
	begin
		r_op_a    <= '0;
		r_op_b    <= '0;
		r_aux     <= '0;
		r_d_value <= '0;
	end
end:rgstr_label

always_comb begin
	if(~ready)
	begin
		case(op_sel)

			MULT:
        	begin
				op_a_out = {r_op_a[DW_MDR-1], r_op_a[DW_MDR-1:1]};
				op_b_out = r_op_b;
				aux_out  = r_aux;
			end

			DIV:
         	begin
				if(shift_enable)
            	begin
					op_a_out = {r_op_a[DW_MDR-2:0], r_op_b[DW_MDR-1]};
					op_b_out = {r_op_b[DW_MDR-2:0],1'b0};
				end
				else 
            	begin
					op_a_out = r_op_a;
					op_b_out = r_op_b;
				end
				aux_out  = r_aux;
			end

			SQRT:
			begin
				op_a_out = r_op_a;
				op_b_out = r_op_b;
				aux_out  = r_aux;
			end
			
			default:
         	begin
				op_a_out = r_op_a;
				op_b_out = r_op_b;
				aux_out  = r_aux;
			end
		endcase
		d_out = r_d_value;
	end
	else
	begin
		op_a_out = '0;
		op_b_out = '0;
		aux_out  = '0;
		d_out    = '0;
	end
end

endmodule
