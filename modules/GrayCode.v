module GrayCode #(
    parameter GRAYWIDTH = 3
)(
    input wire clk,
    input wire enable,
    output wire [GRAYWIDTH-1:0] gray
);

// binary counter freerunning
wire [GRAYWIDTH-1:0] bin;
CountInRange #(
    .COUNTWIDTH(GRAYWIDTH),
    .COUNTLIM_L({GRAYWIDTH{1'b0}}),
    .COUNTLIM_H({GRAYWIDTH{1'b1}})
) counter_bin (
    .clk(clk),
    .enable(enable),
    .direction(1'b1),
    .counter(bin)
);

// gray from bin
assign gray[GRAYWIDTH-1:0] = {bin[GRAYWIDTH-1], bin[GRAYWIDTH-1:1] ^ bin[GRAYWIDTH-2:0]};

endmodule