module SlowClock #(
    parameter HALFPERIOD = 32'h05F5E100     // 200MHz to 1Hz
)(
    input wire clk,
    output reg clk_o
);

localparam COUNTWIDTH = 32;
wire countDone;
CountInRange #(
    .COUNTWIDTH(COUNTWIDTH),
    .COUNTLIM_L(0),
    .COUNTLIM_H(HALFPERIOD-1)
) clockDivider (
    .clk(clk),
    .enable(1'b1),
    .direction(1'b1),
    .counter(),
    .done(countDone)
);

always @(posedge clk) begin
    if(countDone) begin
        clk_o <= ~clk_o;
    end
end

endmodule