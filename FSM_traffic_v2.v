// Notes:
// 1. input/output naming convention:
//    a. input: add prefix "i_" to the original name
//    b. output: add prefix "o_" to the original name
//    c. ALWAYS provide a mechanism to RESET, TRIGGER, SAMPLE outputs. Hardware design requires GOD MODE CONTROL (testing chip requires controlling the chip in any circumstannces), not simulation or printing in software.
// 2. input/output type convention:
//    a. keep clean input/output type, no need to add "reg" or "wire" in the name
//    b. later we will use "reg" or "wire" to define the type of the signal
// 3. FSM state encoding convention:
//    a. always have IDLE state as the first state
//    b. keep the state transition always block clean


module FSM_traffic_v2(
    input i_clk, //1.a, 1.b, 2.a
    input i_reset,
    input i_start,
    output o_red,
    output o_yellow,
    output o_green
);

/*############## FIRST BLOCK FOR creating parameters + wires + registers ################*/

// State encoding
parameter IDLE = 3'b000; // 3.a  IDLE state 
parameter RED  = 3'b001; 
parameter GREEN = 3'b010; 
parameter YELLOW = 3'b011; 

// Timing for each light - determines the timer size
parameter RED_TIME    = 5;
parameter GREEN_TIME  = 4;
parameter YELLOW_TIME = 2;


reg r_red; //2.b
reg r_yellow; //prefix "r_" for registers, otherwise "w_" for wires
reg r_green;

// State registers
reg [2:0] state, next_state; //common names like state and next_state always used register (prefix "r_" can be omitted)

// 4-bit counter is only applied to this case, make this register adaptable to parameter changes
reg [4:0] r_timer;


/*############## SECOND BLOCK FOR always ################*/

//3.a, 3.b
always @(posedge i_clk) begin
    if(i_reset) begin
        state <= IDLE; // Start from IDLE state
    end
    else begin
        state <= next_state; // Move to next state
    end
end

// Next state logic (combinational)
always @(*) begin
    case (state)
        IDLE:   next_state = (i_start) ? RED  : IDLE; // IDLE state, all lights off
        RED:    next_state = (timer == 0) ? GREEN  : RED; // If timer is 0, move to RED state
        GREEN:  next_state = (timer == 0) ? YELLOW : GREEN; // If timer is 0, move to GREEN state
        YELLOW: next_state = (timer == 0) ? RED    : YELLOW; // If timer is 0, move to YELLOW state
        default: next_state = IDLE;
    endcase
end

// Output logic (combinational)
// This method uses state register + combinational logic to determine the output
// Therefore, r_red, r_yellow, and r_green are physical WIRE not REGISTERs (note that in estimating delay, hardware costs)
always @(*) begin
    case (state)
        IDLE:   begin r_red = 0; r_yellow = 0; r_green = 0; end // IDLE state, all lights off
        RED:    begin r_red = 1; r_yellow = 0; r_green = 0; end
        GREEN:  begin r_red = 0; r_yellow = 0; r_green = 1; end
        YELLOW: begin r_red = 0; r_yellow = 1; r_green = 0; end
        default: begin r_red = 0; r_yellow = 0; r_green = 0; end
    endcase
end


always @(posedge i_clk) begin
    if (i_reset) begin
        r_timer <= 0;
    end
    else begin
        if (r_timer == 0) begin
            case (next_state)
                RED: r_timer <= RED_TIME;
                GREEN: r_timer <= GREEN_TIME;
                YELLOW: r_timer <= YELLOW_TIME;
                default: r_timer <= 0;
            endcase
        end else begin
            r_timer <= r_timer - 1;
        end
    end
end


/*############## THIRD BLOCK FOR combinational assignment and output ################*/

assign o_red = r_red;
assign o_yellow = r_yellow;
assign o_green = r_green;


endmodule