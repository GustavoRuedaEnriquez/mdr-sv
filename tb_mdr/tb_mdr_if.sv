interface tb_mdr_if(
input clk
);
import tb_mdr_pkg::*;

logic [1:0] op;
data_t      data;
data_t      result;
data_t      remainder;
logic       load;
logic       start;
logic       load_x;
logic       load_y;
logic       error;
logic       ready;

modport tstr (
   input clk,
   output data,
   output start,
   output load,
   output op,
   input load_x,
   input load_y,
   input error,
   input ready,
   input result,
   input remainder
);

modport  mdr(
   input clk,
   input data,
   input start,
   input load,
   input op,
   output load_x,
   output load_y,
   output error,
   output ready,
   output result,
   output remainder
);
endinterface
