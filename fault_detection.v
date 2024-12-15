module fault_detection (
    input wire current_overload, // Input to detect overload
    input wire no_feedback,     // Input to detect loss of feedback
    output reg fault            // Output for fault detection
);
    always @(current_overload or no_feedback) begin
        if (current_overload || no_feedback)
            fault = 1'b1;  // Fault detected
        else
            fault = 1'b0;  // No fault
    end
endmodule
