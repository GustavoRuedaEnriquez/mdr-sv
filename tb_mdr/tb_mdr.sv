`timescale 1ns / 1ps
include "tester_mdr.svh";
module tb_mdr ();

import tb_mdr_pkg::*;
integer text_id;
logic clk;
logic rst;

// Definition of tester
tester_mdr  t     ;

// Instance of interface
tb_mdr_if   itf(
.clk(clk)
) ;

mdr_wrapper uut(
.clk(clk),
.rst(rst),
.itf (itf.mdr)
);

initial begin
                t   = new(itf);
               t.init();
                clk = 'd0; 
                rst = 'd1; 
  #(2*PERIOD)   
  		rst = 'd0; 
  #(2*PERIOD)   rst = 'd1; 
                fork
                    t.open_file();
                    t.inject_all_data_mdr();
                    t.review_output();
                join                
                t.close_file();
                $stop();
end

always begin
    #(PERIOD/2) clk =!clk; 
end

endmodule
