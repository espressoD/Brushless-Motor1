module commutation (
    input wire [2:0] hall_signal, // Hall sensor input (3-bit)
    output reg [2:0] commutation_signal // Commutation output for the phases
);
    always @(*) begin
        case (hall_signal)
            3'b001: commutation_signal = 3'b001;  // Phase A ON
            3'b011: commutation_signal = 3'b010;  // Phase B ON
            3'b010: commutation_signal = 3'b100;  // Phase C ON
            3'b110: commutation_signal = 3'b001;  // Phase A ON
            3'b100: commutation_signal = 3'b010;  // Phase B ON
            3'b101: commutation_signal = 3'b100;  // Phase C ON
            default: commutation_signal = 3'b000; // No phase
        endcase
    end
endmodule
