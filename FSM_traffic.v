`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Dang Tuan Quang
// 
// Create Date: 03/29/2025 07:48:34 PM
// Design Name: 
// Module Name: FSM_traffic
// Project Name: FSM for traffic light
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module FSM_traffic(
    input clk,
    input reset,
    output reg red,
    output reg yellow,
    output reg green
);

// State encoding
parameter RED    = 2'b00;
parameter GREEN  = 2'b01;
parameter YELLOW = 2'b10;

// State registers
reg [1:0] state, next_state; 

// Timing for each light
parameter RED_TIME    = 5; // Red light duration
parameter GREEN_TIME  = 4; // Green light duration
parameter YELLOW_TIME = 2; // Yellow light duration

// 4-bit counter
reg [3:0] timer; 

// State transition logic (sequential)
always @(posedge clk or posedge reset) begin
    if (reset) begin
        state <= RED; // Start from red light
        timer <= RED_TIME; // Set timer to red light duration
    end else begin
        if (timer == 0) begin
            state <= next_state; // Move to next state
            case (next_state)
                RED: timer <= RED_TIME; // Set timer to red light duration
                GREEN: timer <= GREEN_TIME; // Set timer to green light duration
                YELLOW: timer <= YELLOW_TIME; // Set timer to yellow light duration
                default: timer <= RED_TIME;
            endcase
        end else begin
            timer <= timer - 1; // Decrement timer
        end
    end
end

// Next state logic (combinational)
always @(*) begin
    case (state)
        RED:    next_state = (timer == 0) ? GREEN  : RED; // If timer is 0, move to RED state
        GREEN:  next_state = (timer == 0) ? YELLOW : GREEN; // If timer is 0, move to GREEN state
        YELLOW: next_state = (timer == 0) ? RED    : YELLOW; // If timer is 0, move to YELLOW state
        default: next_state = RED;
    endcase
end

// Output logic (combinational)
always @(*) begin
    case (state)
        RED:    begin red = 1; yellow = 0; green = 0; end // Red light
        GREEN:  begin red = 0; yellow = 0; green = 1; end // Green light
        YELLOW: begin red = 0; yellow = 1; green = 0; end // Yellow light
        default: begin red = 1; yellow = 0; green = 0; end 
    endcase
end

endmodule
