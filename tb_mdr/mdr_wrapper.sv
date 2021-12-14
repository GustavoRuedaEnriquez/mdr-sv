module mdr_wrapper 
//FIXME[DEV]: import your own package
import mdr_pkg::*;
import tb_mdr_pkg::*;
(
input          clk,
input          rst,
tb_mdr_if.mdr  itf
);

//FIXME[DEV]:define two variable using your RTL datatype
data_t result     ;
data_t remainder  ;


//Instance your own MDR and cast to the specific datatype to RTL
mdr_top dut(
    .clk        ( itf.clk                    ),
    .rst        ( rst                        ),
    .data       ( data_t'(itf.data)       ),
    .op         ( itf.op         ),
    .load       ( itf.load               ),
    .start      ( itf.start                  ),
    .result     ( result                     ),
    .remainder  ( remainder                  ),
    .ready      ( itf.ready                  ),
    .error      ( itf.error                  ),
    .load_x     ( itf.load_x                 ),
    .load_y     ( itf.load_y                 )
);

//Cast using this testbench data_t type
assign itf.result    = data_t'( result     );
assign itf.remainder = data_t'( remainder  );
 
          
endmodule
