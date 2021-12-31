// =============================================================================
// Title        : Control Unit, that contais the FSM and the MUX's configurations
//                The FSM has 5 states:
//                -> IDLE
//                -> LOAD_X
//                -> LOAD_Y
//    			  -> ERROR
//				  -> PROCCESSING
// Project      : MDR
// File         : control_mdr.sv
// Description  : File that contains the definition of the control unit.
// Date         : October 19th 2021  
// =============================================================================
// Authors      : Gustavo Rueda
// =============================================================================

module control_mdr
import mdr_pkg::*;
(
input bit        clk,
input bit        rst,
input op_bus     op,
input logic      in_start,
input logic      in_load,
input data_bus_n in_data_x,
input data_bus_n in_data_y,

/*-------Transition input signals-------*/
input logic counter_first,
input logic counter_overflow,
/*--------------------------------------*/
/*-------Operation input signals--------*/
input  data_bus_n op_a,
input  data_bus_n op_b,
input  logic      aux,
/*--------------------------------------*/

output logic out_load_x,
output logic out_load_y,
output logic out_ready,
output logic out_error,
/*-------Transition output signals-------*/
output logic load_x_enable,
output logic load_y_enable,
output logic error_enable,
output logic counter_enable,
/*--------------------------------------*/
/*-------Operation output signals--------*/
output op_bus alu_sel,
output logic  operator_enable,
output logic  shift,
output logic  is_division,
/*---------------------------------------*/
/*-------Muxes output signals------*/
output mux_2_to_1_sel_t mux_x_sel,
output mux_2_to_1_sel_t mux_y_sel,
output mux_2_to_1_sel_t mux_d_sel,
output mux_4_to_1_sel_t mux_0_sel,
output mux_5_to_1_sel_t mux_1_sel,
output mux_3_to_1_sel_t mux_2_sel,
output mux_2_to_1_sel_t mux_3_sel,
output mux_2_to_1_sel_t mux_4_sel,
output mux_2_to_1_sel_t mux_5_sel,
output mux_3_to_1_sel_t mux_6_sel,
output mux_2_to_1_sel_t mux_ready_sel
/*---------------------------------------*/
);

logic multiplication_overflow;
state_fsm_e current_state;	
state_fsm_e next_state;

/*-------------------------------------------------*/
/*                       FSM                       */
/*-------------------------------------------------*/
always_comb begin	
	case(current_state)
		STATE_IDLE:
		begin
			/* Initial state */
			if(in_start)
				next_state 	= STATE_LOAD_X;
			else 
				next_state 	= current_state;
		end
		STATE_LOAD_X:
		begin
			/* Validate if the operation is not square root, if not square root, 
			   we proceed to load y.*/
			if(in_start == '0 && in_load == 1'b1 && op != SQRT && counter_first == 0 && counter_overflow == 0)
				next_state 	= STATE_LOAD_Y;
			/* Validate if the operation is square root, if square root, 
			we proceed to process the data.*/
			else if(in_start == '0 && in_load == 1'b1 && op == SQRT && counter_first == 0 && counter_overflow == 0)	
			   next_state 	= STATE_PROCESSING;
			/* Do not move from state if none of above happen */
			else
				next_state 	= current_state;
		end	
		STATE_LOAD_Y:
		begin
		   /* Validate if division by 0 error */
			if(in_start == '0 && in_load == 1'b0 && (op == DIV && in_data_x == '0))
				next_state 	= STATE_ERROR;
			/* If y is loaded, proceed to process the information */
			else if(in_start == '0 && in_load == 1'b1 && counter_first == '0 && counter_overflow == '0)
				next_state 	= STATE_PROCESSING;
			/* Do not move from state if none of above happen */
			else
				next_state 	= current_state;
		end
		STATE_PROCESSING:
		begin
		   /* If N cycles have passed, the algorithm should be finished */
		   if(in_start == '0 && counter_first == '0 && counter_overflow == 1'b1)
				next_state 	= STATE_IDLE;
			else if (op == SQRT && in_data_x[DW_MDR-1] == 1'b1)
				next_state = STATE_ERROR;
			else 
				next_state 	= current_state;
		end
		STATE_ERROR:  
		begin
		/* If N cycles have passed, the algorithm should be finised */
		   if(in_start == '0 && counter_first == '0 && counter_overflow == 1'b1)
				next_state 	= STATE_IDLE;
			else 
				next_state 	= current_state;
		end		
	endcase	
end


always_ff@(posedge clk or negedge rst)
begin:entry_seq_circuit
	if (!rst)
		current_state  <= STATE_IDLE;
   	else
	    current_state  <= next_state;
end:entry_seq_circuit


// Always_comb which defines the output
always_comb begin
	case(current_state)
		STATE_IDLE:
		begin
			counter_enable  = 1'b0;
			operator_enable = 1'b0;
			out_error       = 1'b0;
			error_enable    = 1'b1;
			out_ready       = 1'b1;
			out_load_x      = 1'b0;
			out_load_y      = 1'b0;
			load_x_enable   = 1'b0;
			load_y_enable   = 1'b0;		
		end
		STATE_LOAD_X:
		begin
			counter_enable  = 1'b0;
			operator_enable = 1'b0;
			out_error       = 1'b0;
			error_enable    = 1'b0;
			out_ready       = 1'b0;
			out_load_x      = 1'b1;
			out_load_y      = 1'b0;
			load_x_enable   = 1'b1;
			load_y_enable   = 1'b0;
		end	
		STATE_LOAD_Y:
		begin
			counter_enable  = 1'b0;
			operator_enable = 1'b0;
			out_error       = 1'b0;
			error_enable    = 1'b0;
			out_load_x      = 1'b0;
			out_load_y      = 1'b1;
			out_ready       = 1'b0;
			load_x_enable   = 1'b0;
			load_y_enable   = 1'b1;
		end	
		STATE_PROCESSING:
		begin
			counter_enable  = 1'b1;
			operator_enable = 1'b1;
			out_error       = 1'b0;
			error_enable    = counter_overflow;
			out_load_x      = 1'b0;
			out_load_y      = 1'b0;
			out_ready       = counter_overflow;
			load_x_enable   = 1'b0;
			load_y_enable   = 1'b0;
		end
		STATE_ERROR:
		begin
			counter_enable  = 1'b1;
			operator_enable = 1'b0;
			out_error       = 1'b1;
			error_enable    = 1'b0;
			out_load_x      = 1'b0;
			out_load_y      = 1'b0;
			out_ready       = 1'b0;
			load_x_enable   = 1'b0;
			load_y_enable   = 1'b0;
		end
	endcase
	
end 
/*-------------------------------------------------*/

/*
**************
* ALU SELECT *
**************
Selector for the ALU.
*/
always_comb
begin:alu_select_comb_block
	/*
	* If operation is division, we need to convert from two's complement to binary.
	*/
	if(SQRT == op && counter_overflow && op_a[DW_MDR-1])
	begin
		alu_sel = SQRT_FINAL;
	end
	else
	begin
		alu_sel = op;
	end
end:alu_select_comb_block


/*
*********
* MUX X *
*********
Mux X for the X selection.
*/
always_comb
begin:mux_x_comb_block
	/*
	* If operation is division, we need to convert from two's complement to binary.
	*/
	if(DIV != op)
	begin
		mux_x_sel = 1'b0;
	end
	else
	begin
		mux_x_sel = 1'b1;
	end
end:mux_x_comb_block

/*
*********
* MUX Y *
*********
Mux Y for the Y selection.
*/
always_comb
begin:mux_y_comb_block
	/*
	* If operation is division, we need to convert from two's complement to binary.
	*/
	if(DIV != op)
	begin
		mux_y_sel = 1'b0;
	end
	else
	begin
		mux_y_sel = 1'b1;
	end
end:mux_y_comb_block

/*
*********
* MUX D *
*********
Mux D for the D value selection.
*/
always_comb
begin:mux_d_comb_block
	if(counter_first)
	begin
		mux_d_sel = 1'b0;
	end
	else
	begin
		mux_d_sel = 1'b1;
	end
end:mux_d_comb_block


/*
*********
* MUX 0 *
*********
Mux 0 for the ALU result assigment.
*/
always_comb
begin:mux_0_comb_block
	/*
	*	0 -> Multiplication (OP_B[0] = AUX)                                          ->  Shift
	*	1 -> Multiplication (OP_B[0] = 0, AUX = 1) | Square Root (R < 0)             -> Add
	*	2 -> Multiplication (OP_B[0] = 1, AUX = 0) | Division | Square Root (R >= 0) -> Substraction
	*	3 -> Multiplication (First) | Division (First) | Root (First)                -> 0
	*/
	if(STATE_PROCESSING == current_state)
	begin
		if ((MULT == op) && (op_b[0] == aux))
			mux_0_sel = 2'b00;
		else if ( ( MULT == op && 2'b01 == {op_b[0],aux} ) || ( SQRT == op && op_a[DW_MDR-1]) )
			mux_0_sel = 2'b01;
		else if ( ( MULT == op && 2'b10 == {op_b[0],aux} && counter_first == '0 ) || ( DIV  == op && counter_first == 1'b0) || ( SQRT == op && ~op_a[DW_MDR-1]) )
			mux_0_sel = 2'b10;
		else if (counter_first)
			mux_0_sel = 2'b11;
		else 
			mux_0_sel = 2'b11;
	end
	else
	begin
		mux_0_sel = 2'b11;
	end
end:mux_0_comb_block


/*
*********
* MUX 1 *
*********
Mux 1 for the Operator B assigment.
*/
always_comb
begin:mux_1_comb_block
	/*
	 *	0 -> Mutliplication (First) | Division (First).
	 *	1 -> Multiplication case.
	 *	2 -> Division case.
	 *	3 -> Square root case.
	 *	4 -> Ready | First square root iteration.
	*/
	if (SQRT != op && counter_first)
		mux_1_sel = 3'b000;
	else if (MULT == op  && counter_first == '0)
		mux_1_sel = 3'b001;
	else if (DIV == op && counter_first == '0)
		mux_1_sel = 3'b010;
	else if (SQRT == op  && counter_first == '0)
		mux_1_sel = 3'b011;
	else if (counter_overflow || (SQRT && counter_first))
		mux_1_sel = 3'b100;
	else
		mux_1_sel = 3'b100;
end:mux_1_comb_block

/*
*********
* MUX 2 *
*********
Mux 2 for the auxiliary register assigment.
*/
always_comb
begin:mux_2_comb_block
	/*
	*	0 -> Multiplication
	*	1 -> Division
	*	2 -> Multiplication first iteration
	*/
	if ((MULT == op) && (STATE_LOAD_Y != current_state))
		mux_2_sel = 2'b00;
	else if (DIV == op)
		mux_2_sel = 2'b01;
	else if ((MULT == op) && (STATE_LOAD_Y == current_state))
		mux_2_sel = 2'b10;
	else 
		mux_2_sel = 2'b10;
end:mux_2_comb_block

/*
*********
* MUX 3 *
*********
Mux 3 to check if a result conversion bin-2-c2 is required.
*/
always_comb
begin:mux_3_comb_block
	/*
	* If operation is division, we need to convert from binary to two's complement.
	*/
	if(DIV != op)
	begin
		mux_3_sel = 1'b0;
	end
	else
	begin
		mux_3_sel = 1'b1;
	end
end:mux_3_comb_block

/*
*********
* MUX 4 *
*********
Mux 4 for the internal remainder assigment.
*/
always_comb
begin:mux_4_comb_block
	/*
	*	0 -> Multiplication case (remainder must be 0).
	*	1 -> Division and Square root case (remainder must be A).
	*/
	if ((MULT == op))
		mux_4_sel = 1'b0;
	else 
		mux_4_sel = 1'b1;
end:mux_4_comb_block


/*
*********
* MUX 5 *
*********
Mux 5 to check if there was an error on the operation, modifies the result if so.
The statements here apply for the multiplication algorithm, division and square
errors are handled on the FSM.
*/
always_comb
begin:mux_5_comb_block
	if(counter_overflow && op == MULT)
	begin
		if (in_data_x[DW_MDR-1] == 1'b1 && in_data_x[DW_MDR-2:0] == '0 && in_data_y == ONES)
			multiplication_overflow = 1'b1;
		else if(in_data_x[DW_MDR-1] == 1'b1 && in_data_y == 1)
			multiplication_overflow = 1'b0;
		else if(op_a == ZEROS && op_b[DW_MDR-1] == 1'b0)
			multiplication_overflow = 1'b0;
		else if (op_a == ONES && op_b[DW_MDR-1] == 1'b1)
			multiplication_overflow = 1'b0;
		else
			multiplication_overflow = 1'b1;
	end
	else
	begin
		multiplication_overflow = 1'b0;
	end
	mux_5_sel = multiplication_overflow | out_error;
end:mux_5_comb_block


/*
*********
* MUX 6 *
*********
Mux 6 to check if a remainder conversion bin-2-c2 is required or if R requires an
extra operation (Only used on square root).
*/
always_comb
begin:mux_6_comb_block
	/*
	*	0 -> Multiplication case and Square Root without extra step.
	*	1 -> Division case.
	*	2 -> Square root with extra step.
	*/
	if(DIV != op && alu_sel != SQRT_FINAL)
	begin
		mux_6_sel = 2'b00;
	end
	else if(DIV == op)
	begin
		mux_6_sel = 2'b01;
	end
	else if(SQRT == op && alu_sel == SQRT_FINAL)
	begin
		mux_6_sel = 2'b10;
	end
	else
	begin
		mux_6_sel = 2'b00;
	end
end:mux_6_comb_block


/*
****************
* Shift enable *
****************
This combinational block determines if a shifting must be done, used only for
division (Shift left A,Q)
*/
always_comb begin
	if(STATE_PROCESSING == current_state)
		if ((DIV == op) && (counter_overflow == 0))
			shift = 1'b1;
		else 
			shift = 1'b0;		
	else
		shift = 1'b0;
end

assign mux_ready_sel = (current_state != STATE_PROCESSING) ? 1'b0 : 1'b1;
assign is_division   = (op == DIV & counter_overflow != 1'b1) ? 1'b1 : 1'b0;

endmodule


