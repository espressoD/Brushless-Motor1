module bldc_controller (
    input wire clk,
    input wire reset,
    input wire [7:0] speed_set,    // Desired speed (fixed speed)
    input wire [2:0] hall_signal,  // Hall sensor signals
    input wire current_overload,   // Current overload detection
    input wire no_feedback,        // No feedback detection
    output wire pwm_a, pwm_b, pwm_c,  // PWM signals for each phase
    output wire fault               // Fault detection output
);
    wire [7:0] pwm_a_out, pwm_b_out, pwm_c_out;
    wire [2:0] commutation_signal;

    // Instantiate the PWM generator
    pwm_generator pwm_a_gen (
        .clk(clk),
        .reset(reset),
        .duty_cycle(speed_set),
        .pwm_out(pwm_a_out)
    );
    pwm_generator pwm_b_gen (
        .clk(clk),
        .reset(reset),
        .duty_cycle(speed_set),
        .pwm_out(pwm_b_out)
    );
    pwm_generator pwm_c_gen (
        .clk(clk),
        .reset(reset),
        .duty_cycle(speed_set),
        .pwm_out(pwm_c_out)
    );

    // Instantiate commutation logic
    commutation comm (
        .hall_signal(hall_signal),
        .commutation_signal(commutation_signal)
    );

    // Instantiate open loop controller
    open_loop_controller open_loop (
        .hall_signal(hall_signal),
        .speed_set(speed_set),
        .pwm_a(pwm_a),
        .pwm_b(pwm_b),
        .pwm_c(pwm_c)
    );

    // Instantiate fault detection
    fault_detection fault_det (
        .current_overload(current_overload),
        .no_feedback(no_feedback),
        .fault(fault)
    );

endmodule
