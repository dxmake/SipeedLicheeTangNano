module SquareWave (
    input wire clk_24M,
    input wire btn_a_i,     // raise frequency
    input wire btn_b_i,     // drop  frequency

    output wire io_b3a
);

// clk_100K
wire clk_100K;
SlowClock #(
    .HALFPERIOD(24000000/100000)
) clock_100K (
    .clk(clk_24M),
    .clk_o(clk_100K)
);

// clk_100M
wire clk_100M;
Gowin_rPLL clock_100M(
    .clkout(clk_100M), //output clkout
    .clkin(clk_24M) //input clkin
);

// button filter
wire btnPress_a;
wire btnPress_b;
ButtonFilter buttonFilter_a (
    .clk_100K(clk_100K),
    .btn_i(btn_a_i),
    .btn_o(),
    .btnPress(btnPress_a),
    .btnRelease()
);
ButtonFilter buttonFilter_b (
    .clk_100K(clk_100K),
    .btn_i(btn_b_i),
    .btn_o(),
    .btnPress(btnPress_b),
    .btnRelease()
);

// frequency control with button
localparam COUNTWIDTH = 32;
localparam INITIALDIVIDE = 50000000;    // 1Hz from 100MHz
localparam MAXFREQDIVIDE = 5;           // 10MHz
localparam MINFREQDIVIDE = 500000000;   // 0.1Hz
reg [COUNTWIDTH-1:0] divider = INITIALDIVIDE;
localparam ST_1 = 0;
localparam ST_2 = 1;
localparam ST_5 = 2;
reg [2:0] state = ST_1;
always @(posedge clk_100K) begin
    if(btnPress_a && divider > MAXFREQDIVIDE) begin
        case(state)
        ST_1: begin
            state <= ST_2;
            divider <= divider / 2;
        end
        ST_2: begin
            state <= ST_5;
            divider <= divider * 2 / 5;
        end
        ST_5: begin
            state <= ST_1;
            divider <= divider / 2;
        end
        endcase
    end else if(btnPress_b && divider < MINFREQDIVIDE) begin
        case(state)
        ST_1: begin
            state <= ST_5;
            divider <= divider * 2;
        end
        ST_2: begin
            state <= ST_1;
            divider <= divider * 2;
        end
        ST_5: begin
            state <= ST_2;
            divider <= divider / 2 * 5;
        end
        endcase
    end else begin
    end
end
reg [COUNTWIDTH-1:0] divider_r;
always @(posedge clk_100K) begin
    divider_r <= divider - 1;
end

// square wave generation
reg wave;
reg [COUNTWIDTH-1:0] counter;
always @(posedge clk_100M) begin
    if(btnPress_b | btnPress_a) begin
        counter <= 0;
    end else if(counter > divider_r) begin
        counter <= 0;
    end else if(counter == divider_r) begin
        counter <= 0;
        wave <= ~wave;
    end else begin
        counter <= counter + 1'b1;
    end
end
assign io_b3a = wave;

endmodule