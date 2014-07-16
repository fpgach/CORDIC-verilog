`timescale 1ns / 1ps
module main
#(parameter N = 14, DAT_WIDTH = 14, ARG_WIDTH = 16)
    (
    input   wire                                    clk,
    input   wire    signed  [ ARG_WIDTH-1 :  0 ]    arg,
    output  wire    signed  [ DAT_WIDTH-1 :  0 ]    Re_out,
    output  wire    signed  [ DAT_WIDTH-1 :  0 ]    Im_out
    );

localparam  CORDIC_GAIN = 14'd4974;

reg signed  [ DAT_WIDTH-1 :  0 ]    Re[0:N];
reg signed  [ DAT_WIDTH-1 :  0 ]    Im[0:N];
reg signed  [ ARG_WIDTH-1 :  0 ]    r_input_arg[0:N];
reg signed  [ ARG_WIDTH-1 :  0 ]    r_output_arg[0:N-1];
reg         [  1 :  0 ]             r_quad[0:N-1];


wire    signed [ DAT_WIDTH :  0 ]   w_Re[0:N-1];
wire    signed [ DAT_WIDTH :  0 ]   w_Im[0:N-1];
genvar i;
generate
    for(i = 1; i < N; i = i + 1)
    begin: shift
        assign w_Re[i-1] = i > 8 ? (Im[i-1] + (14'sd1 <<< (i-1))) >>> (i) : Im[i-1] >>> (i);
        assign w_Im[i-1] = i > 8 ? (Re[i-1] + (14'sd1 <<< (i-1))) >>> (i) : Re[i-1] >>> (i);
    end
endgenerate

integer k;
wire signed  [ 15 :  0 ] angle[0:N-1];
assign angle[0 ] = 16'sd4836;
assign angle[1 ] = 16'sd2555;
assign angle[2 ] = 16'sd1297;
assign angle[3 ] = 16'sd651;
assign angle[4 ] = 16'sd325;
assign angle[5 ] = 16'sd162;
assign angle[6 ] = 16'sd81;
assign angle[7 ] = 16'sd40;
assign angle[8 ] = 16'sd20;
assign angle[9 ] = 16'sd10;
assign angle[10] = 16'sd5;
assign angle[11] = 16'sd2;
assign angle[12] = 16'sd1;
    
always@(posedge clk)
begin

//stage 0
    r_input_arg[0] <= {2'b0,arg[(ARG_WIDTH-3):0]};
    r_quad[0] <= arg[(ARG_WIDTH-1)-:2];
    Re[0] <= CORDIC_GAIN;
    Im[0] <= CORDIC_GAIN;
    r_output_arg[0] <= 16'sd8192;
    
//stage 1..13
    for(k = 1; k < N; k = k + 1)
    begin
        r_input_arg[k] <= r_input_arg[k-1];
        r_quad[k] <= r_quad[k-1];
        if(r_output_arg[k-1] > r_input_arg[k-1])
        begin
            Re[k] <= Re[k-1] + w_Re[k-1][13:0];
            Im[k] <= Im[k-1] - w_Im[k-1][13:0];
            r_output_arg[k] <= r_output_arg[k-1] - angle[k-1];
        end
        else
        begin
            Re[k] <= Re[k-1] - w_Re[k-1][13:0];
            Im[k] <= Im[k-1] + w_Im[k-1][13:0];
            r_output_arg[k] <= r_output_arg[k-1] + angle[k-1];
        end
    end

    Re[14] <=   r_quad[13] == 2'b00 ? Re[13]  :
                r_quad[13] == 2'b01 ? -Im[13] :
                r_quad[13] == 2'b10 ? -Re[13] :
                Im[13];
    Im[14] <=   r_quad[13] == 2'b00 ? Im[13]  :
                r_quad[13] == 2'b01 ? Re[13]  :
                r_quad[13] == 2'b10 ? -Im[13] :
                -Re[13];

end

assign Re_out = Re[14];
assign Im_out = Im[14];

endmodule
