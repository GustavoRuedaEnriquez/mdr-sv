`timescale 1ns / 1ps
// =============================================================================
// Title        : FSM Debouncer.
// Project      : Sequential Multiplier
// File         : fsm_debouncer.sv
// Description  : File that contains the debouncers State Machine.
// Date         : September 14th 2021  
// =============================================================================
// Authors      : Abisai Ramirez Perez
// =============================================================================

module fsm_debouncer 
import fsm_debouncer_pkg::*;
(
input        clk,
input        rst,
input        d_in,
input        delay_30ms_ready,
output logic one_shot,
output logic enable_counter
);

// States declaration
fsm_debouncer_state_e  current_state;
fsm_debouncer_state_e  next_state;

// Definition of next state using always_comb
always_comb
begin:entry_comb_circuit
	case(current_state)
	LOW:
	begin
		if (d_in ==  TRUE_DEBOUNCER)
			next_state = DELAY_1; // Defining the next state
		else
         		next_state = LOW;
	end
	DELAY_1:
	begin
		if (delay_30ms_ready)
			next_state = HIGH; // Defining the next state
         	else
            		next_state = DELAY_1;
	end
	HIGH:
	begin
		if (d_in == FALSE_DEBOUNCER)
			next_state = DELAY_2; // Defining the next state
		else
			next_state = HIGH;
	end
	DELAY_2:
	begin
		if (delay_30ms_ready)
			next_state = LOW; // Defining the next state
         	else
            		next_state = DELAY_2;		
	end
	endcase	
end:entry_comb_circuit

// Definition of the next state
always_ff@(posedge clk, negedge rst)
begin
	if(!rst)
		current_state <= LOW;
	else
		current_state <= next_state;
end


// Definition of the output (Combinational Output)
always_comb
begin:comb_circuit
	case (current_state)
	LOW:
	begin
		enable_counter = FALSE_DEBOUNCER;
        	one_shot = FALSE_DEBOUNCER;
	end
      	DELAY_1:
	begin
		enable_counter = TRUE_DEBOUNCER;
        	one_shot = delay_30ms_ready;  // This is a enable of a single tick clock
	end
      	HIGH:
	begin
		enable_counter = FALSE_DEBOUNCER;
		one_shot = FALSE_DEBOUNCER;
	end
	DELAY_2:
	begin
		enable_counter = TRUE_DEBOUNCER;
        	one_shot = FALSE_DEBOUNCER;
      	end
	endcase
end:comb_circuit

endmodule
