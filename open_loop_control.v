module open_loop_controller (
    input wire [2:0] hall_signal,     // Hall sensor signal
    input wire [7:0] speed_set,       // Set speed for motor
    output reg [7:0] pwm_a, pwm_b, pwm_c // PWM signals for the phases
);

    reg [7:0] duty_cycle;

    // Menggunakan always block dengan non-blocking assignment (`<=`)
    always @(hall_signal or speed_set) begin
        duty_cycle = speed_set;  // Mengatur duty cycle untuk setiap fase berdasarkan speed_set

        // Komutasi fase berdasarkan sinyal Hall
        case (hall_signal)
            3'b001: begin
                pwm_a = duty_cycle; pwm_b = 8'b0; pwm_c = 8'b0;  // Phase A ON
            end
            3'b011: begin
                pwm_a = 8'b0; pwm_b = duty_cycle; pwm_c = 8'b0;  // Phase B ON
            end
            3'b010: begin
                pwm_a = 8'b0; pwm_b = 8'b0; pwm_c = duty_cycle;  // Phase C ON
            end
            default: begin
                pwm_a = 8'b0; pwm_b = 8'b0; pwm_c = 8'b0;        // No phase active
            end
        endcase
    end

endmodule
