// Coder: DSc Abisai Ramirez Perez
// Date:  2020, 28th May
// Disclaimer: This code is not intended to be shared. It is 
// intended to be used for ITESO students at DVVSD Class 2020

class tester_mdr ;

localparam DW = 10;


`ifdef INVERTED_PULSES
   localparam FALSE  = 1'b1;
   localparam TRUE   = 1'b0;
`else
   localparam TRUE   = 1'b1;
   localparam FALSE  = 1'b0;
`endif

`protect
typedef logic signed [DW:0]       data_t;
typedef logic signed [2*DW-1:0]     results_t;
typedef  enum logic [1:0] {
    MULTI   = 2'd0,
    DIV     = 2'd1,
    SQRT    = 2'd2
    } op_e;

localparam LIMINF =-(2**(DW-1));
localparam LIMSUP = (2**(DW-1))-1;
localparam PERIOD = 4; // Minimum value 4
localparam DLY       = 2;
localparam INC       = 1;
localparam OP_INIT   = 0;
localparam OP_LAST   = 2;

`endprotect
longint BASE_MD   =  ((2**DW)/INC) * ((2**DW)/INC);
longint BASE_S    =  ((2**DW)/INC) ;
longint TESTED    =  2*BASE_MD + ((2**DW)/INC) ;
real calf_m;
real calf_d;
real calf_s;
integer text_id         ;
integer count_mult      ;
integer count_divi      ;
integer count_sqrt      ;
virtual tb_mdr_if itf   ;

data_t  x, y;
data_t  x_o_q, y_o_q;
data_t  x_r, y_r;
data_t  x_md, y_md;
logic [1:0] op_o ;
data_t  q_a[$];
data_t  q_b[$];

logic signed [DW-1:0] data_a_int, data_b_int;
results_t       result_exp_tb ;
results_t       result_hw ;
results_t       temp_result ;
results_t       remainer_exp_tb ;
results_t       remainer_hw ;
logic           ready;
logic           error_exp_tb;


`protect
function new(virtual tb_mdr_if.tstr t);
    itf = t;
endfunction



//***    Inject two data    ***//
task automatic inj_two_data(data_t x_in, data_t y_in );
    //$display("Inside inj_two_data. x: %0d y: %0d",x_in, y_in); 
    #(0.2) // Offset
    itf.load    = FALSE  ;
    itf.start   = TRUE  ;
    #(PERIOD)  itf.start   = FALSE  ;
   //$display("Load_x %0d ",itf.load_x );
   if (itf.load_x == 1'b1) begin
      //$display("load_x active %0d ",itf.load_x );
      itf.data    = x_in;
      q_a.push_front(x_in);
   end else begin
      @(posedge itf.load_x)
      //$display("Waiting for load_x %0d ",itf.load_x );
      itf.data    = x_in;
      q_a.push_front(x_in);
   end
   #(PERIOD)  itf.load    = TRUE;
   #(PERIOD)  itf.load    = FALSE;
   if (1'b1 == itf.load_y) begin
      //$display("load_y active %0d ",itf.load_y );
      itf.data = y_in;
      q_b.push_front(y_in);
   end else begin
      @(posedge itf.load_y)
      //$display("Waiting for load_y %0d ",itf.load_y );
      itf.data = y_in;
      q_b.push_front(y_in);
   end
   fork 
      #(PERIOD)   itf.load = TRUE;
      @(posedge itf.ready) ;
   join
   $display("Aca");
   #(PERIOD)   itf.load = FALSE;
    //$display("Inject int: x: %0d y: %0d",x_in, y_in);
endtask

//***    Inject one data   ***//
task automatic inj_one_data( data_t x_int_r );
   #(0.2)      itf.start =TRUE;
   #(PERIOD)   itf.start =FALSE;
   if (itf.load_x == 1'b1) begin
      //$display("load_x active %0d ",itf.load_x );
      itf.data    = x_int_r;
      q_a.push_front(x_int_r);
   end else begin
      @(posedge itf.load_x)
      //$display("Waiting for load_x %0d ",itf.load_x );
      itf.data    = x_int_r;
      q_a.push_front(x_int_r);
   end
//                itf.data = x_int_r;
//                q_a.push_front(x_int_r);
   fork
      #(PERIOD)   itf.load = TRUE;
      $display("Aca 2");
      @(posedge itf.ready);
   join
    #(PERIOD)   itf.load = FALSE;
    $display("Aca 3");
endtask

//***    Inject data for multiplication and division   ***//
task automatic inject_all_data_md();
    for (x_md =LIMINF; x_md<LIMSUP ; x_md=x_md+INC ) begin
        for (y_md =LIMINF; y_md<LIMSUP ; y_md= y_md+INC) begin
            //$display("Inside all data md. Time: %0d, x: %0d y: %0d", $time, x_md, y_md);
            if (x_md ==LIMINF && y_md==LIMINF)
                #(3*PERIOD) inj_two_data(x_md, y_md);
            else begin
                #(3*PERIOD) inj_two_data(x_md, y_md);
            end
            //if (1'b0 == itf.ready)begin
            //end
        end
    end
endtask

//***    Inject data for sqrt   ***//
task automatic inject_all_data_r();
    for (x_r =LIMINF; x_r<LIMSUP ; x_r=x_r + INC ) begin
        #(3*PERIOD) inj_one_data(x_r);
        //@(posedge itf.ready || itf.error );
        //if (1'b0== itf.ready) begin
        //end
    end
endtask

//***    Inject data for all operations   ***//
task automatic inject_all_data_mdr();

   $display("MULTIPLICATION OPERATION %0dns", $time);
   itf.op = MULTI;
   inject_all_data_md();
   
   $display("DIVISION  OPERATION %0dns", $time);
   #(PERIOD)   itf.op = DIV;
   inject_all_data_md();

   $display("SQRT %0dns", $time);
   #(PERIOD)   itf.op = SQRT;
   inject_all_data_r();
endtask 


task automatic init();
   itf.op      = FALSE ;
   itf.data    = FALSE ;
   itf.start   = FALSE ;
   itf.load    = FALSE ;
endtask

// ***      Calculate result based on operation     ***//
task op_calc (op_e op, data_t x, data_t y);
    if (op == MULTI) begin
        remainer_exp_tb     = 'd0;
        temp_result         = x*y;
        error_exp_tb        = (temp_result>(2**(DW-1)-1)) || (temp_result<(-2**(DW-1) )) ;
        //$display("%0d",temp_result);
        result_exp_tb       =(error_exp_tb)?(-1):(temp_result);
    end
    else if (op==DIV) begin
        error_exp_tb        = (x == 0) ;
        result_exp_tb       = (error_exp_tb)? (-1): (y / x);
        remainer_exp_tb     = (error_exp_tb)? (0) :y - result_exp_tb*x;
        //error_exp_tb        = (y == 0) ;
        //result_exp_tb       = (error_exp_tb)? (-1): (x/y);
        //remainer_exp_tb     = (error_exp_tb)? (-1) : ( x - result_exp_tb*y);
    end
    else if (op == SQRT) begin
        error_exp_tb        = (x < 0) ;
        result_exp_tb       = error_exp_tb?(-1):$floor($sqrt(x));
        remainer_exp_tb     = (error_exp_tb)?(0):(x - result_exp_tb*result_exp_tb);
    end
endtask 


task automatic open_file();
    text_id = $fopen("report.txt", "w");
    //$display("File open %0d", text_id);
endtask

task automatic close_file();
    $fclose(text_id);
endtask

task automatic review_output ();
   count_mult = 0;
   count_divi = 0;
   count_sqrt = 0;

   for (op_o =OP_INIT; op_o<=OP_LAST ; op_o++ ) begin
      for (int x_o =LIMINF; x_o<LIMSUP ; x_o=x_o+INC ) begin
         for (int y_o =LIMINF; y_o<LIMSUP ; y_o=y_o + INC) begin
            $display("[%0dns] op: %0d, x: %0d, y: %0d\n",$time, op_o, x_o, y_o);
            //@(posedge itf.ready || itf.error == 1)
            //if (1'b0== itf.ready)begin
            @(posedge itf.ready);
            //end
            #(DLY*PERIOD)
            //$display("File open %0d", text_id);
            if (itf.op == MULTI) begin
               x_o_q   = q_a.pop_front();
               y_o_q   = q_b.pop_front();
               op_calc(itf.op, x_o_q, y_o_q);

               if ( (itf.result != result_exp_tb)  || (error_exp_tb != itf.error)) begin
                  $fwrite(text_id, "[%0dns] ERROR: op: %0d, x: %0d, y: %0d, \
                     ExpError: %0d HwErr: %0d, Exp Result:%0d Hw Res:%0d, \
                     Exp Rem: %0d Hw Rem: %0d \n", $time, itf.op, x_o_q, y_o_q,
                     error_exp_tb, itf.error, result_exp_tb, itf.result, 
                     remainer_exp_tb, itf.remainder );
                  $display("[%0dns] ERROR:, op: %0d, x: %0d, y: %0d, Exp Result:%0d, Hw Res:%0d, Exp Rem: %0d Hw Rem: %0d \n", 
                     $time, itf.op, x_o_q, y_o_q, result_exp_tb, itf.result, 
                     remainer_exp_tb, itf.remainder );
                  count_mult =count_mult + 1;
               end
            end
            else if (itf.op==DIV) begin
               x_o_q   = q_a.pop_front();
               y_o_q   = q_b.pop_front();
               op_calc(itf.op, x_o_q, y_o_q);
               if ( (itf.result != result_exp_tb)  || (remainer_exp_tb != itf.remainder) || (error_exp_tb != itf.error)) begin
                  $fwrite(text_id, "[%0d], op: %0d, x: %0d, y: %0d,    ExpError: %0d HwErr: %0d,    Exp Result: %0d Hw Res:%0d,    Exp Rem: %0d Hw Rem: %0d \n",
                     $time, itf.op, x_o_q, y_o_q, error_exp_tb, itf.error, 
                     result_exp_tb, itf.result, remainer_exp_tb, itf.remainder);
                  $display("[%0dns] ERROR: op: %0d, x: %0d, y: %0d,   Exp Result:%0d Hw Res:%0d,   Exp Rem: %0d Hw Rem: %0d  Exp tb err: %0d  HW err: %0d\n", 
                     $time, itf.op, x_o_q, y_o_q, result_exp_tb, itf.result,
                     remainer_exp_tb, itf.remainder, error_exp_tb, itf.error );
                  count_divi =count_divi +1;
               end
            end
            else if (itf.op == SQRT) begin
               x_o_q   = q_a.pop_front();
               op_calc(itf.op, x_o_q, y_o_q);
               if ( (itf.result != result_exp_tb)  || (remainer_exp_tb != itf.remainder) || (error_exp_tb != itf.error)) begin
                  $fwrite(text_id, "Time:%0d, op: %0d, x: %0d, ExpError: %0d HwErr: %0d, Exp Result:%0d Hw Res:%0d, Exp Rem: %0d Hw Rem: %0d \n",
                     $time, itf.op, x_o_q, error_exp_tb, itf.error, 
                     result_exp_tb, itf.result, remainer_exp_tb, itf.remainder);
               $display("[%0dns] ERROR: op: %0d, x: %0d, Exp Result:%0d Hw Res:%0d, Exp Rem: %0d Hw Rem: %0d \n", 
                  $time, itf.op, x_o_q, result_exp_tb, itf.result, 
                  remainer_exp_tb, itf.remainder );
                  count_sqrt =count_sqrt +1;
               end
            end
         end
         if(SQRT ==itf.op && LIMINF == x_o)begin
            break;
         end
      end
   end
   calf_m = ( real'(count_mult)/real'(BASE_MD) ) *100;
   calf_d = ( real'(count_divi)/real'(BASE_MD) ) *100;
   calf_s = ( real'(count_sqrt)/real'(BASE_S) ) *100;
   $display("[%0d] Tested: %0d,\n Errors on Multiplication:%0d, Percent error:\
%3.2f\n Errors on Division: %0d, Percent error: %3.2f,\n Erros on Square root:\
   %0d, Percent error: %3.2f", 
   $time,  TESTED, count_mult, calf_m, count_divi, calf_d, count_sqrt, calf_s);
endtask 

`endprotect
endclass
