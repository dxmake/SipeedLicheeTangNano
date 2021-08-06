module ChangingLED (
    input clk_24M,

    output wire led_r,
    output wire led_g,
    output wire led_b,

    input wire btn_a_i,
    input wire btn_b_i
);

// clk_100K
wire clk_100K;
SlowClock #(
    .HALFPERIOD(24000000/100000)    // 100K
) clock_100K (
    .clk  (clk_24M),
    .clk_o(clk_100K)
);

// button filter
wire btn_a;
wire btn_b;
ButtonFilter buttonFilter_a (
    .clk_100K(clk_100K),
    .btn_i(btn_a_i),
    .btn_o(btn_a),
    .btnPress(),
    .btnRelease()
);
ButtonFilter buttonFilter_b (
    .clk_100K(clk_100K),
    .btn_i(btn_b_i),
    .btn_o(btn_b),
    .btnPress(),
    .btnRelease()
);


// reset
wire rst_n;
assign rst_n = btn_a;

// clk_ledGray
wire clk_ledGray;
SlowClock #(
    .HALFPERIOD(24000000/20)    // 20Hz
) clock_ledGray (
    .clk  (clk_24M),
    .clk_o(clk_ledGray)
);

// clk_ledPwm
wire clk_ledPwm;
SlowClock #(
    .HALFPERIOD(24000000/100000)    // 100K
) clock_ledPwm (
    .clk  (clk_24M),
    .clk_o(clk_ledPwm)
);

// led by grayCode
localparam LEDNUM = 3;
wire ledGrayEnable;
wire [LEDNUM-1:0] ledGray;
GrayCode #(
    .GRAYWIDTH(LEDNUM)
) grayCode_led (
    .clk(clk_ledGray),
    .enable(ledGrayEnable),
    .gray(ledGray)
);

// led pwm ratio counter
localparam PWM_DEGREE = 100;
localparam COUNTWIDTH = 10;
wire [LEDNUM-1:0] ledPwmRatioCountDone;
wire [LEDNUM-1:0] ledPwmRatioDirection;
assign ledPwmRatioDirection = btn_b ? (ledGray[LEDNUM-1:0]) : ({LEDNUM{1'b0}});
wire [COUNTWIDTH-1:0] ledPwmRatio [0:LEDNUM-1];
generate
    genvar i;
    for(i=0; i<LEDNUM; i=i+1) begin : ledPwmRatioCount
        CountInRange #(
            .COUNTWIDTH(COUNTWIDTH),
            .COUNTLIM_L(0),
            .COUNTLIM_H(PWM_DEGREE/2)   // max pwm ratio, also led lightness.
        ) ledPwmRatioCount (
            .clk(clk_ledGray),
            .enable(~ledPwmRatioCountDone[i]),
            .direction(ledPwmRatioDirection[i]),
            .counter(ledPwmRatio[i][COUNTWIDTH-1:0]),
            .done(ledPwmRatioCountDone[i])
        );
    end
endgenerate
assign ledGrayEnable = btn_b && (& ledPwmRatioCountDone);

// led pwm
wire [LEDNUM-1:0] ledPwmSig;
generate
    genvar j;
    for(j=0; j<LEDNUM; j=j+1) begin : ledPwm
        PWM #(
            .DEGREE(100),
            .COUNTWIDTH(COUNTWIDTH)
        ) ledPwm (
            .clk(clk_ledPwm),
            .dutyRatio(ledPwmRatio[j][COUNTWIDTH-1:0]),
            .pwmSig(ledPwmSig[j]),
            .pwmPeriodTail()
        );
    end
endgenerate
assign led_r = ~ledPwmSig[2];
assign led_g = ~ledPwmSig[1];
assign led_b = ~ledPwmSig[0];

endmodule