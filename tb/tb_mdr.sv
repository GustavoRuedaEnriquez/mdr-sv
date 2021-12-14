// =============================================================================
// Title        :   Testbench MDR.
// Project      :   MDR
// File         :   tb_mdr.sv
// Description  :   Testbench for the MDR.
// Date         :   October 25th 2021
// =============================================================================
// Authors      :   Gustavo Rueda
// =============================================================================

module tb_mdr;

localparam IN_DW = 10;

//Inputs
logic			      start = 0;
logic			      clk = 1;
logic		         rst = 0;
logic             load = 0;
logic [IN_DW-1:0] data = 0;
logic [1:0]       op = 0;

//Outputs
logic [IN_DW-1:0] result;
logic [IN_DW-1:0]   remainder;
logic load_x;
logic load_y;
logic ready;
logic error;
logic         segments_sign;
logic [6:0] segments_hundreds;
logic [6:0] segments_tens;
logic [6:0] segments_units;

//Decoder module
mdr_top
mdr
(
 .clk       (clk),
 .rst       (rst),
 .start     (start),
 .load      (load),
 .data      (data),
 .op        (op),
 .ready     (ready),
 .load_x    (load_x),
 .load_y    (load_y),
 .error     (error),
 .result    (result),
 .remainder (remainder),
 .segments_sign(segments_sign),
 .segments_hundreds(segments_hundreds),
 .segments_tens(segments_tens),
 .segments_units(segments_units)
);

always #1 clk <= ~clk;
initial
begin
   clk = 0;
   rst = 0;
   #2 rst = 1;
   
   // Select op, then press start
   op = 0;
   #3 start = 0;
   start = 1; #2
   start = 0;
   // Select data, then press load (load x) //
   data   = 10'd115;
   #2 load = 1;
   #2 load = 0;
   

   // Select data, then press load (load y) //
   #2 data   = 10'd115;
   #2 load = 1;
   #2 load = 0;
   

  #(2*IN_DW + 2)

  /*
   // Select op, then press start //
   op = 0;
   start = 0;
   start = 1; #2
   start = 0;
   // Select data, then press load (load x) //
   data   = 10'd13;
   #2 load = 1;
   #2 load = 0;
   // Select data, then press load (load y) //
   #2 data   = 10'd7;
   #2 load = 1;
   #2 load = 0;
   */
   #50
   $stop;
end

endmodule