module CountInRange #(
    parameter COUNTWIDTH = 7,
    parameter COUNTLIM_L = 0,
    parameter COUNTLIM_H = 99     // default for count in range 0..99
)(
    input wire clk,
    input wire enable,
    input wire direction,
    output reg [COUNTWIDTH-1:0] counter,
    output wire done
);

always @(posedge clk) begin
    if(enable) begin
        if(counter < COUNTLIM_L || counter > COUNTLIM_H) begin
            counter <= 0;
        end else if(direction==1) begin
            if(counter < COUNTLIM_H) begin
                counter <= counter + 1'b1;
            end else begin
                counter <= COUNTLIM_L;
            end
        end else if(direction==0) begin
            if(counter > COUNTLIM_L) begin
                counter <= counter - 1'b1;
            end else begin
                counter <= COUNTLIM_H;
            end
        end else begin
        end
    end
end

assign done = (direction==1 && counter == COUNTLIM_H) || (direction==0 && counter == COUNTLIM_L);

endmodule
    