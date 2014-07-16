module test_cordic();

reg         clk;
reg [15:0]  arg;

wire    signed [13:0]  Re_out;
wire    signed [13:0]  Im_out;

main uut(
    .clk(clk),
    .arg(arg),
    //.arg(20004),
    .Re_out(Re_out),
    .Im_out(Im_out)
);

reg [15:0] delay_arg[0:13];

    always@(posedge clk)
    begin
        delay_arg[0] <= arg;
        delay_arg[1] <= delay_arg[0];
        delay_arg[2] <= delay_arg[1];
        delay_arg[3] <= delay_arg[2];
        delay_arg[4] <= delay_arg[3];
        delay_arg[5] <= delay_arg[4];
        delay_arg[6] <= delay_arg[5];
        delay_arg[7] <= delay_arg[6];
        delay_arg[8] <= delay_arg[7];
        delay_arg[9] <= delay_arg[8];
        delay_arg[10] <= delay_arg[9];
        delay_arg[11] <= delay_arg[10];
        delay_arg[12] <= delay_arg[11];
        delay_arg[13] <= delay_arg[12];
//        delay_arg[13:1] <= delay_arg[12:0];
    end

reg [16:0]  targ = 17'b0;
    always@(posedge clk)
    begin
        arg <= arg + 1'b1;
        targ <= targ + 1'b1;
    end

initial begin
    clk = 0;
    arg = 0;
    #100;
    forever #(100/2) clk = ~clk;

end

integer Re;
integer Im;
integer Arg;
initial begin
    Re = $fopen("Re.txt", "w");
    Im = $fopen("Im.txt", "w");
    Arg= $fopen("Arg.txt", "w");
    while(delay_arg[13] != 65536)
    begin

        $fwrite(Re, "%d\n", Re_out);
        $fwrite(Im, "%d\n", Im_out);
        $fwrite(Arg, "%d\n", delay_arg[13]);
        @(posedge clk);
    end
    $finish;
    $fclose(Re);
    $fclose(Im);
    $fclose(Arg);
    
end

endmodule

