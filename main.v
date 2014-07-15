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
        assign w_Re[i-1] = (Im[i-1] + (14'sd1 <<< (i-1))) >>> (i);
        assign w_Im[i-1] = (Re[i-1] + (14'sd1 <<< (i-1))) >>> (i);
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
    
    for(k = 1; k < N; k = k + 1)
    begin
        r_input_arg[k] <= r_input_arg[k-1];
        r_quad[k] <= r_quad[k-1];
        if(r_output_arg[k-1] > r_input_arg[k-1])
        begin
            Re[k] <= Re[k-1] + w_Re[k-1][13:0];//((Im[0] + 14'sd2) >>> 2);
            Im[k] <= Im[k-1] - w_Im[k-1][13:0];//((Re[0] + 14'sd2) >>> 2);
            r_output_arg[k] <= r_output_arg[k-1] - angle[k-1];//16'sd2555;//angle[2];
        end
        else
        begin
            Re[k] <= Re[k-1] - w_Re[k-1][13:0];//((Im[0] + 14'sd2) >>> 2);
            Im[k] <= Im[k-1] + w_Im[k-1][13:0];//((Re[0] + 14'sd2) >>> 2);
            r_output_arg[k] <= r_output_arg[k-1] + angle[k-1];//16'sd2555;//angle[2];
        end
    end

    Re[14] <=   r_quad[13] == 2'b00 ? Re[13]  :
                r_quad[13] == 2'b01 ? -Im[13] :
                r_quad[13] == 2'b10 ? -Re[13] :
                Im[13];
    Im[14] <=   r_quad[13] == 2'b00 ? Im[13]  :
                r_quad[13] == 2'b01 ? Re[13] :
                r_quad[13] == 2'b10 ? -Im[13] :
                -Re[13];

/*
    r_input_arg[0] <= {2'b0,arg[(ARG_WIDTH-3):0]};
    r_quad[0] <= arg[(ARG_WIDTH-1)-:2];
    if({2'b0,arg[(ARG_WIDTH-3):0]} < 16'sd8192) //?
    begin
        Re[0] <= CORDIC_GAIN + ((CORDIC_GAIN + 14'd1) >>> 1);
        Im[0] <= CORDIC_GAIN - ((CORDIC_GAIN + 14'd1) >>> 1);
        r_output_arg[0] <= 16'sd8192 - 16'sd4836;//angle[1];
    end
    else
    begin
        Re[0] <= CORDIC_GAIN - ((CORDIC_GAIN + 14'sd1) >>> 1);
        Im[0] <= CORDIC_GAIN + ((CORDIC_GAIN + 14'sd1) >>> 1);
        r_output_arg[0] <= 16'sd8192 + 16'sd4836;//angle[1];
    end
*/
//stage 1
/*
    for(k = 1; k < 12; k = k + 1)
    begin
        r_input_arg[k] <= r_input_arg[k-1];
        r_quad[k] <= r_quad[k-1];
        if(r_output_arg[k-1] > r_input_arg[k-1])
        begin
            Re[k] <= Re[k-1] + w_Re[k-1][13:0];//((Im[0] + 14'sd2) >>> 2);
            Im[k] <= Im[k-1] - w_Im[k-1][13:0];//((Re[0] + 14'sd2) >>> 2);
            r_output_arg[k] <= r_output_arg[k-1] - angle[k-1];//16'sd2555;//angle[2];
        end
        else
        begin
            Re[k] <= Re[k-1] - w_Re[k-1][13:0];//((Im[0] + 14'sd2) >>> 2);
            Im[k] <= Im[k-1] + w_Im[k-1][13:0];//((Re[0] + 14'sd2) >>> 2);
            r_output_arg[k] <= r_output_arg[k-1] + angle[k-1];//16'sd2555;//angle[2];
        end
    end
*/







/*
    r_input_arg[1] <= r_input_arg[0];
    r_quad[1] <= r_quad[0];
    if(r_output_arg[0] > r_input_arg[0])
    begin
        Re[1] <= Re[0] + w_Re[0][13:0];//((Im[0] + 14'sd2) >>> 2);
        Im[1] <= Im[0] - w_Im[0][13:0];//((Re[0] + 14'sd2) >>> 2);
        r_output_arg[1] <= r_output_arg[0] - 16'sd2555;//angle[2];
    end
    else
    begin
        Re[1] <= Re[0] - w_Re[0][13:0];//((Im[0] + 14'sd2) >>> 2);
        Im[1] <= Im[0] + w_Im[0][13:0];//((Re[0] + 14'sd2) >>> 2);
        r_output_arg[1] <= r_output_arg[0] + 16'sd2555;//angle[2];
    end
//stage 2
    r_input_arg[2] <= r_input_arg[1];
    r_quad[2] <= r_quad[1];
    if(r_output_arg[1] > r_input_arg[1])
    begin
        Re[2] <= Re[1] + w_Re[1][13:0];//((Im[1] + 14'sd4) >>> 3);
        Im[2] <= Im[1] - w_Im[1][13:0];//((Re[1] + 14'sd4) >>> 3);
        r_output_arg[2] <= r_output_arg[1] - 16'sd1297;//angle[3];
    end
    else
    begin
        Re[2] <= Re[1] - w_Re[1][13:0];//((Im[1] + 14'sd4) >>> 3);
        Im[2] <= Im[1] + w_Im[1][13:0];//((Re[1] + 14'sd4) >>> 3);
        r_output_arg[2] <= r_output_arg[1] + 16'sd1297;//angle[3];
    end
//stage 3
    r_input_arg[3] <= r_input_arg[2];
    r_quad[3] <= r_quad[2];
    if(r_output_arg[2] > r_input_arg[2])
    begin
        Re[3] <= Re[2] + w_Re[2][13:0];//((Im[2] + 14'sd8) >>> 4);
        Im[3] <= Im[2] - w_Im[2][13:0];//((Re[2] + 14'sd8) >>> 4);
        r_output_arg[3] <= r_output_arg[2] - 16'sd651;//angle[4];
    end
    else
    begin
        Re[3] <= Re[2] - w_Re[2][13:0];//((Im[2] + 14'sd8) >>> 4);
        Im[3] <= Im[2] + w_Im[2][13:0];//((Re[2] + 14'sd8) >>> 4);
        r_output_arg[3] <= r_output_arg[2] + 16'sd651;//angle[4];
    end
//stage 4
    r_input_arg[4] <= r_input_arg[3];
    r_quad[4] <= r_quad[3];
    if(r_output_arg[3] > r_input_arg[3])
    begin
        Re[4] <= Re[3] + w_Re[3][13:0];//((Im[3] + 14'sd16) >>> 5);
        Im[4] <= Im[3] - w_Im[3][13:0];//((Re[3] + 14'sd16) >>> 5);
        r_output_arg[4] <= r_output_arg[3] - 16'sd325;//angle[5];
    end
    else
    begin
        Re[4] <= Re[3] - w_Re[3][13:0];//((Im[3] + 14'sd16) >>> 5);
        Im[4] <= Im[3] + w_Im[3][13:0];//((Re[3] + 14'sd16) >>> 5);
        r_output_arg[4] <= r_output_arg[3] + 16'sd325;//angle[5];
    end
//stage 5
    r_input_arg[5] <= r_input_arg[4];
    r_quad[5] <= r_quad[4];
    if(r_output_arg[4] > r_input_arg[4])
    begin
        Re[5] <= Re[4] + w_Re[4][13:0];//((Im[4] + 14'sd32) >>> 6);
        Im[5] <= Im[4] - w_Im[4][13:0];//((Re[4] + 14'sd32) >>> 6);
        r_output_arg[5] <= r_output_arg[4] - 16'sd162;//angle[6];
    end
    else
    begin
        Re[5] <= Re[4] - w_Re[4][13:0];//((Im[4] + 14'sd32) >>> 6);
        Im[5] <= Im[4] + w_Im[4][13:0];//((Re[4] + 14'sd32) >>> 6);
        r_output_arg[5] <= r_output_arg[4] + 16'sd162;//angle[6];
    end
//stage 6
    r_input_arg[6] <= r_input_arg[5];
    r_quad[6] <= r_quad[5];
    if(r_output_arg[5] > r_input_arg[5])
    begin
        Re[6] <= Re[5] + w_Re[5][13:0];//((Im[5] + 14'sd64) >>> 7);
        Im[6] <= Im[5] - w_Im[5][13:0];//((Re[5] + 14'sd64) >>> 7);
        r_output_arg[6] <= r_output_arg[5] - 16'sd81;//angle[7];
    end
    else
    begin
        Re[6] <= Re[5] - w_Re[5][13:0];//((Im[5] + 14'sd64) >>> 7);
        Im[6] <= Im[5] + w_Im[5][13:0];//((Re[5] + 14'sd64) >>> 7);
        r_output_arg[6] <= r_output_arg[5] + 16'sd81;//angle[7];
    end
//stage 7
    r_input_arg[7] <= r_input_arg[6];
    r_quad[7] <= r_quad[6];
    if(r_output_arg[6] > r_input_arg[6])
    begin
        Re[7] <= Re[6] + w_Re[6][13:0];//((Im[6] + 14'sd128) >>> 8);
        Im[7] <= Im[6] - w_Im[6][13:0];//((Re[6] + 14'sd128) >>> 8);
        r_output_arg[7] <= r_output_arg[6] - 16'sd40;//angle[8];
    end
    else
    begin
        Re[7] <= Re[6] - w_Re[6][13:0];//((Im[6] + 14'sd128) >>> 8);
        Im[7] <= Im[6] + w_Im[6][13:0];//((Re[6] + 14'sd128) >>> 8);
        r_output_arg[7] <= r_output_arg[6] + 16'sd40;//angle[8];
    end
//stage 8
    r_input_arg[8] <= r_input_arg[7];
    r_quad[8] <= r_quad[7];
    if(r_output_arg[7] > r_input_arg[7])
    begin
        Re[8] <= Re[7] + w_Re[7][13:0];//((Im[7] + 14'sd256) >>> 9);
        Im[8] <= Im[7] - w_Im[7][13:0];//((Re[7] + 14'sd256) >>> 9);
        r_output_arg[8] <= r_output_arg[7] - 16'sd20;//angle[9];
    end
    else
    begin
        Re[8] <= Re[7] - w_Re[7][13:0];//((Im[7] + 14'sd256) >>> 9);
        Im[8] <= Im[7] + w_Im[7][13:0];//((Re[7] + 14'sd256) >>> 9);
        r_output_arg[8] <= r_output_arg[7] + 16'sd20;//angle[9];
    end
//stage 9
    r_input_arg[9] <= r_input_arg[8];
    r_quad[9] <= r_quad[8];
    if(r_output_arg[8] > r_input_arg[8])
    begin
        Re[9] <= Re[8] + w_Re[8][13:0];//((Im[8] + 14'sd512) >>> 10);
        Im[9] <= Im[8] - w_Im[8][13:0];//((Re[8] + 14'sd512) >>> 10);
        r_output_arg[9] <= r_output_arg[8] - 16'sd10;//angle[10];
    end
    else
    begin
        Re[9] <= Re[8] - w_Re[8][13:0];//((Im[8] + 14'sd512) >>> 10);
        Im[9] <= Im[8] + w_Im[9][13:0];//((Re[8] + 14'sd512) >>> 10);
        r_output_arg[9] <= r_output_arg[8] + 16'sd10;//angle[10];
    end
//stage 10
    r_input_arg[10] <= r_input_arg[9];
    r_quad[10] <= r_quad[9];
    if(r_output_arg[9] > r_input_arg[9])
    begin
        Re[10] <= Re[9] + w_Re[9][13:0];//((Im[9] + 14'sd1024) >>> 11);
        Im[10] <= Im[9] - w_Im[9][13:0];//((Re[9] + 14'sd1024) >>> 11);
        r_output_arg[10] <= r_output_arg[9] - 16'sd5;//angle[11];
    end
    else
    begin
        Re[10] <= Re[9] - w_Re[9][13:0];//((Im[9] + 14'sd1024) >>> 11);
        Im[10] <= Im[9] + w_Im[9][13:0];//((Re[9] + 14'sd1024) >>> 11);
        r_output_arg[10] <= r_output_arg[9] + 16'sd5;//angle[11];
    end    
//stage 11
    r_input_arg[11] <= r_input_arg[10];
    r_quad[11] <= r_quad[10];
    if(r_output_arg[10] > r_input_arg[10])
    begin
        Re[11] <= Re[10] + w_Re[10][13:0];//((Im[10] + 14'sd2048) >>> 12);
        Im[11] <= Im[10] - w_Im[10][13:0];//((Re[10] + 14'sd2048) >>> 12);
        r_output_arg[11] <= r_output_arg[10] - 16'sd2;//angle[12];
    end
    else
    begin
        Re[11] <= Re[10] - w_Re[10][13:0];//((Im[10] + 14'sd2048) >>> 12);
        Im[11] <= Im[10] + w_Im[10][13:0];//((Re[10] + 14'sd2048) >>> 12);
        r_output_arg[11] <= r_output_arg[10] + 16'sd2;//angle[12];
    end

//stage 12
    //r_input_arg[12] <= r_input_arg[11];
    r_quad[12] <= r_quad[11];
    if(r_output_arg[11] > r_input_arg[11])
    begin
        Re[12] <= Re[11] + w_Re[11][13:0];//((Im[11] + 14'sd4096) >>> 13);
        Im[12] <= Im[11] - w_Im[11][13:0];//((Re[11] + 14'sd4096) >>> 13);
    end
    else
    begin
        Re[12] <= Re[11] - w_Re[11][13:0];//((Im[11] + 14'sd4096) >>> 13);
        Im[12] <= Im[11] + w_Im[11][13:0];//((Re[11] + 14'sd4096) >>> 13);
    end 
*/
//stage 13

end

assign Re_out = Re[14];//[0+:DAT_WIDTH-1];
assign Im_out = Im[14];//[0+:DAT_WIDTH-1];

endmodule
