module bldc_controller (
    input wire clk,
    input wire reset,
    input wire [7:0] speed_set,    // Desired speed (fixed speed)
    input wire [2:0] hall_signal,  // Hall sensor signals
    input wire current_overload,   // Current overload detection
    input wire no_feedback,        // No feedback detection
    output wire pwm_a, pwm_b, pwm_c,  // PWM signals for each phase
    output wire fault,              // Fault detection output
    output wire dummy_signal,
    output wire dummy_out
);

    wire [7:0] pwm_a_out, pwm_b_out, pwm_c_out;
    wire [7:0] fsm_pwm_a, fsm_pwm_b, fsm_pwm_c;
    wire [7:0] olc_pwm_a, olc_pwm_b, olc_pwm_c;
    wire [2:0] fsm_comm_signal, comm_comm_signal;
    wire motor_enable;
    wire gnd = 1'b0;

    // FSM Controller
    (* preserve = 1 *) bldc_fsm_controller fsm_inst (
        .clk(clk),
        .reset(reset),
        .fault(fault),
        .hall_signal(hall_signal),
        .speed_set(speed_set),
        .pwm_a(fsm_pwm_a),
        .pwm_b(fsm_pwm_b),
        .pwm_c(fsm_pwm_c),
        .commutation_signal(fsm_comm_signal),
        .motor_enable(motor_enable)
    );

    // PWM Generators
    (* preserve = 1 *) pwm_generator pwm_a_gen (
        .clk(clk),
        .reset(reset),
        .duty_cycle(speed_set),
        .pwm_out(pwm_a_out)
    );
    (* preserve = 1 *) pwm_generator pwm_b_gen (
        .clk(clk),
        .reset(reset),
        .duty_cycle(speed_set),
        .pwm_out(pwm_b_out)
    );
    (* preserve = 1 *) pwm_generator pwm_c_gen (
        .clk(clk),
        .reset(reset),
        .duty_cycle(speed_set),
        .pwm_out(pwm_c_out)
    );

    // Open Loop Controller
    (* preserve = 1 *) open_loop_controller open_loop (
        .hall_signal(hall_signal),
        .speed_set(speed_set),
        .pwm_a(olc_pwm_a),
        .pwm_b(olc_pwm_b),
        .pwm_c(olc_pwm_c)
    );
    assign dummy_signal = olc_pwm_a ^ olc_pwm_b ^ olc_pwm_c;


    // Fault Detection
    (* preserve = 1 *) fault_detection fault_det (
        .current_overload(current_overload),
        .no_feedback(no_feedback),
        .gnd(gnd),                // Connect to global ground
        .fault(fault)
    );

    // Multiplexer for PWM Outputs
    assign pwm_a = motor_enable ? fsm_pwm_a : (pwm_a_out | olc_pwm_a);
    assign pwm_b = motor_enable ? fsm_pwm_b : (pwm_b_out | olc_pwm_b);
    assign pwm_c = motor_enable ? fsm_pwm_c : (pwm_c_out | olc_pwm_c);

    // Dummy signals to prevent optimization
    wire dummy_signal_b, dummy_signal_c;
    assign dummy_signal_b = pwm_b_out ^ pwm_a_out ^ comm_comm_signal[0];
    assign dummy_signal_c = pwm_c_out ^ pwm_a_out ^ comm_comm_signal[1];

endmodule
