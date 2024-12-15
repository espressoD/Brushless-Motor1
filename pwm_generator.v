module pwm_generator (
    input wire clk,               // Clock input
    input wire reset,             // Reset input
    input wire [7:0] duty_cycle,  // 8-bit duty cycle (0-255)
    output reg pwm_out            // PWM output
);
    reg [7:0] counter;            // 8-bit counter for PWM generation

    always @(posedge clk or posedge reset) begin
        if (reset)
            counter <= 8'd0;
        else
            counter <= counter + 1'b1;
    end

    always @(posedge clk) begin
        if (counter < duty_cycle)
            pwm_out <= 1'b1;
        else
            pwm_out <= 1'b0;
    end
endmodule
