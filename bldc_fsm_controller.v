module bldc_fsm_controller (
    input wire clk,
    input wire reset,
    input wire fault,
    input wire [2:0] hall_signal,
    input wire [7:0] speed_set,
    output reg [7:0] pwm_a, pwm_b, pwm_c,
    output reg [2:0] commutation_signal,
    output reg motor_enable
);

    // State encoding
    parameter IDLE  = 2'b00;
    parameter RUN   = 2'b01;
    parameter FAULT_STATE = 2'b10;

    reg [1:0] current_state, next_state;

    // State transition
    always @(posedge clk or posedge reset) begin
        if (reset)
            current_state <= IDLE;
        else
            current_state <= next_state;
    end

    // Next state logic
    always @(*) begin
        case (current_state)
            IDLE: begin
                if (!fault)
                    next_state = RUN;
                else
                    next_state = FAULT_STATE;
            end
            RUN: begin
                if (fault)
                    next_state = FAULT_STATE;
                else
                    next_state = RUN;
            end
            FAULT_STATE: begin
                if (reset)
                    next_state = IDLE;
                else
                    next_state = FAULT_STATE;
            end
            default: next_state = IDLE;
        endcase
    end

    // Output logic
    always @(posedge clk) begin
        case (current_state)
            IDLE: begin
                pwm_a <= 8'b0;
                pwm_b <= 8'b0;
                pwm_c <= 8'b0;
                commutation_signal <= 3'b000;
                motor_enable <= 1'b0;
            end
            RUN: begin
                motor_enable <= 1'b1;
                case (hall_signal)
                    3'b001: begin pwm_a <= speed_set; pwm_b <= 8'b0; pwm_c <= 8'b0; end
                    3'b011: begin pwm_a <= 8'b0; pwm_b <= speed_set; pwm_c <= 8'b0; end
                    3'b010: begin pwm_a <= 8'b0; pwm_b <= 8'b0; pwm_c <= speed_set; end
                    default: begin pwm_a <= 8'b0; pwm_b <= 8'b0; pwm_c <= 8'b0; end
                endcase
                commutation_signal <= hall_signal;
            end
            FAULT_STATE: begin
                pwm_a <= 8'b0;
                pwm_b <= 8'b0;
                pwm_c <= 8'b0;
                commutation_signal <= 3'b000;
                motor_enable <= 1'b0;
            end
        endcase
    end

endmodule
