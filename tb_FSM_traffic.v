`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/30/2025 07:42:23 PM
// Design Name: 
// Module Name: tb_FSM_traffic
// Project Name: 
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


module tb_FSM_traffic;

    // Testbench signals
    reg clk;
    reg reset;
    wire red, yellow, green;

    // Instantiate the FSM module
    FSM_traffic uut (
        .clk(clk),
        .reset(reset),
        .red(red),
        .yellow(yellow),
        .green(green)
    );

    // Clock generation (10ns period -> 100MHz)
    always #5 clk = ~clk;

    // Simulation control
    initial begin
        // Initialize signals
        clk = 0;
        reset = 1;

        // Apply reset for 20ns
        #20 reset = 0;

        // Run simulation for enough time to see transitions
        #300;

        // End simulation
        $finish;
    end

    // Monitor FSM state changes
    initial begin
        $monitor("Time = %0t | Red = %b | Yellow = %b | Green = %b", $time, red, yellow, green);
    end

endmodule
   
