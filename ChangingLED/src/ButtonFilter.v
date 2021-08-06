module ButtonFilter (
    input wire clk_100K,
    input wire btn_i,
    output reg btn_o
);

reg [3:0] btn_i_r;
always @(posedge clk_100K) begin
    btn_i_r[3:0] <= {btn_i_r[2:0], btn_i};
end

wire riseStable;
wire fallStable;
assign riseStable =   (& btn_i_r);
assign fallStable = ~ (| btn_i_r);
wire stable;
assign stable = riseStable || fallStable;

localparam BTN_FILT_PRDS = 1000;    // 10ms
localparam COUNTWIDTH = 12;

wire countDone;
CountInRange #(
    .COUNTWIDTH(COUNTWIDTH),
    .COUNTLIM_L({COUNTWIDTH{1'b0}}),
    .COUNTLIM_H(BTN_FILT_PRDS-1)
) counter_btnFilt (
    .clk(clk_100K),
    .enable(~countDone),
    .direction(btn_i_r[0]),
    .counter(),
    .done(countDone)
);



always @(posedge clk_100K) begin
    if(countDone && stable) begin
        btn_o <= btn_i_r[0];
    end else begin
    end
end

endmodule