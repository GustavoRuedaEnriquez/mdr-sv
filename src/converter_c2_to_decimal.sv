// =============================================================================
// Title        :   Complement2-to-decimal converter.
// Project      :   Decoder Binary 2s Complement
// File         :   c2_to_decimal.sv
// Description  :   Module that converts complement 2 format to decimal.
// Date         :   September 30th 2021
// =============================================================================
// Authors      :   Gustavo Rueda
// =============================================================================

module converter_c2_to_decimal #(parameter DW = 8)
(
input  [DW-1:0] complement2,
output 		sign,
output [3:0] hundreds,
output [3:0] tens,
output [3:0] units
);

logic [DW-1:0] binary;
logic [31:0] wr_hundreds;
logic [31:0] wr_tens;
logic [31:0] wr_units;

// First, convert the number to binary.
assign sign   = complement2[DW - 1];
assign binary = sign ? ~complement2 + {{DW-1{1'b0}},1'b1} : complement2;

// Obtain the hundreds, since the division is not synthesable we must find another way:
/* 
         1       2^n        x
  x  * ----- *  -----  =  -----
        2^n      100       100

        1      2^12      x
  x  * ---- *  ----  =  ---
       2^12     100     100
		 
        1      4096      x
  x  * ---- *  ----  =  ---
       4096     100     100
		 
        1                x
  x  * ---- *  40.96 =  ---
       4096             100
		 
        1                x
  x  * ---- *  41    ≈  ---
       4096             100
		 
*/
assign wr_hundreds = (binary * 'd41) >> 'd12;
assign hundreds = wr_hundreds[3:0];

// Obtain the tens, since the division is not synthesable we must find another way:
/*
  number - hundreds = x
  
         1      2^n       x
  x  * ----- *  ----  =  ---
        2^n      10       10

        1      2^11     x
  x  * ---- *  ----  = ---
       2^11     10      10
		 
        1      2048     x
  x  * ---- *  ----  = ---
       2048     10      10
		 
        1                x
  x  * ---- *  204.8 =  ---
       2048              10
		 
        1                x
  x  * ---- *  205   ≈  ---
       2048              10

*/
assign wr_tens = ((binary - hundreds * 'd100) * 'd205) >> 'd11;
assign tens = wr_tens[3:0];

//Obtain the units
assign wr_units = binary - (hundreds * 'd100) - (tens * 'd10);
assign units = wr_units[3:0];

endmodule
