// output pwmSig has a period of DEGREE times clk_period.
// as counter and dutyRatio is 10-bits, DEGREE <= 1024.
// when DEGREE is 100, dutyRatio is in percent. and it has value range of 0 .. 100
module PWM #(
    parameter DEGREE = 100,
    parameter COUNTWIDTH = 10
)(
    input wire clk,
    input wire [9:0] dutyRatio,
    output reg pwmSig,
    output wire pwmPeriodTail
);

// pause width counter
wire [COUNTWIDTH-1:0] counter;
CountInRange #(
    .COUNTWIDTH(COUNTWIDTH),
    .COUNTLIM_L(0),
    .COUNTLIM_H(DEGREE-1)
) counter_pwm (
    .clk(clk),
    .enable(1'b1),
    .direction(1'b1),
    .counter(counter),
    .done(pwmPeriodTail)
);

// pwm signal
wire inWidth;
assign inWidth = (counter < dutyRatio);
always @(posedge clk) begin
    pwmSig <= inWidth;
end

endmodule