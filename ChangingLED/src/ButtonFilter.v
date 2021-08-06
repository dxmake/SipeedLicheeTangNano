module ButtonFilter (
    input wire clk_100K,
    input wire btn_i,
    output wire btn_o,
    output wire btnPress,
    output wire btnRelease
);

// btn_i_r
reg [3:0] btn_i_r;
always @(posedge clk_100K) begin
    btn_i_r[3:0] <= {btn_i_r[2:0], btn_i};
end

// btn stable through btn_i_r
wire riseStable;
wire fallStable;
assign riseStable =   (& btn_i_r);
assign fallStable = ~ (| btn_i_r);
wire stable;
assign stable = riseStable || fallStable;

// button delay counter
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

// button output register
reg [1:0] btn_o_r;
always @(posedge clk_100K) begin
    btn_o_r[1] <= btn_o_r[0];
    if(countDone && stable) begin
        btn_o_r[0] <= btn_i_r[0];
    end else begin
    end
end
assign btn_o = btn_o_r[0];

// button press & release event
localparam BTN_PRESS_LEVEL = 0;     // button is pressed at low voltage.
wire btnUpEdge;
wire btnDownEdge;
assign btnUpEdge =   (~btn_o_r[1]) & ( btn_o_r[0]);
assign btnDownEdge = ( btn_o_r[1]) & (~btn_o_r[0]);
assign btnPress   = BTN_PRESS_LEVEL ? btnUpEdge : btnDownEdge;
assign btnRelease = BTN_PRESS_LEVEL ? btnDownEdge : btnUpEdge;

endmodule