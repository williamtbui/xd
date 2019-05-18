// >>>>>>>>>>>>>>>>>>>>>>>>> COPYRIGHT NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<
// --------------------------------------------------------------------
// Copyright (c) 2019 by UCSD CSE 140L
// --------------------------------------------------------------------
//
// Permission:
//
//   This code for use in UCSD CSE 140L.
//   It is synthesisable for Lattice iCEstick 40HX.  
//
// Disclaimer:
//
//   This Verilog source code is intended as a design reference
//   which illustrates how these types of functions can be implemented.
//   It is the user's responsibility to verify their design for
//   consistency and functionality through the use of formal
//   verification methods.  
//
// -------------------------------------------------------------------- //           
//                     UCSD CSE Department
//                     9500 Gilman Dr, La Jolla, CA 92093
//                     U.S.A
//
// --------------------------------------------------------------------

module Lab3_140L (
		  input wire 	    rst, // reset signal (active high)
		  input wire 	    clk, // global clock
		  input wire oneSecStrb,  	    
		  input 	    bu_rx_data_rdy, // data from the uart ready
		  input [7:0] 	    bu_rx_data, // data from the uart
		  output wire 	    L3_tx_data_rdy, // data to the alarm display
		  output wire [7:0] L3_tx_data,     // data to the alarm display
		  output [4:0] 	    L3_led,
		  output reg [6:0] 	    L3_segment1, // 1's seconds
		  output reg [6:0] 	    L3_segment2, // 10's seconds
		  output reg [6:0] 	    L3_segment3, // 1's minutes
		  output reg [6:0] 	    L3_segment4, // 10's minutes

		  output [3:0] 	    di_Mtens,
		  output [3:0] 	    di_Mones,
		  output [3:0] 	    di_Stens,
		  output wire [3:0] di_Sones,
		  output [3:0] 	    di_AMtens,
		  output [3:0] 	    di_AMones,
		  output [3:0] 	    di_AStens,
		  output [3:0] 	    di_ASones
		  );
		  
		

    wire alarm_Match; //tracks if alarm time matches current time
    wire dicRun; //tells clock to run
    wire dicLdMtens; // load the 10's minutes
    wire dicLdMones; // load the 1's minutes
    wire dicLdStens; // load the 10's seconds
    wire dicLdSones; // load the 1's seconds
    wire dicLdAMtens; // load the alarm 10's minutes
    wire dicLdAMones; // load the alarm 1's minutes
    wire dicLdAStens; // load the alarm 10's seconds
    wire dicLdASones; // load the alarm 1's seconds
    wire dicAlarmIdle; // alarm is off
    wire dicAlarmArmed; // alarm is armed
    wire dicAlarmTrig; // alarm is triggered

    //set alarm digits to be alarm times or 0 
		wire[7:0] AMtens = di_AMtens | 8'b00110000;
		wire[7:0] AMones = di_AMones | 8'b00110000;
		wire[7:0] AStens = di_AStens | 8'b00110000;
		wire[7:0] ASones = di_ASones | 8'b00110000;

    //set alarm signal based on state of the alarm
		wire[7:0] alarm_signal = dicAlarmArmed ? 8'b00101110 :
					 dicAlarmIdle ? 8'b01100001 :
					 dicAlarmTrig ? 8'b01010100 : 8'b00100000;
		
		dictrl control(dicLdMtens, dicLdMones, dicLdStens, dicLdSones, dicLdAMtens, dicLdAMones, dicLdAStens, 
							dicLdASones, dicRun, dicAlarmIdle, dicAlarmArmed, dicAlarmTrig, alarm_Match,
							bu_rx_data_rdy, bu_rx_data, rst, clk);
	
		didp dataPath(di_Mtens, di_Mones, di_Stens, di_Sones, di_AMtens, di_AMones, di_AStens, di_ASones, 
						alarm_Match, L3_led, bu_rx_data,    dicLdMtens, dicLdMones, dicLdStens, dicLdSones, 
						dicLdAMtens, dicLdAMones, dicLdAStens, dicLdASones, dicRun, oneSecStrb, rst, clk);
						
		dispString display(L3_tx_data_rdy, L3_tx_data, AMtens, AMones, 8'b00111010, AStens, ASones, 
								8'b00100000, alarm_signal, 8'b00001101, oneSecStrb, rst, clk);
										
    //store segment data
		wire [6:0]seg1; 
		wire [6:0]seg2;
		wire [6:0]seg3;
		wire [6:0]seg4;
		
    //create display segments
		bcd2segment bcd4(seg4, di_Mtens, 1);
		bcd2segment bcd3(seg3, di_Mones, 1);
		bcd2segment bcd2(seg2, di_Stens, 1);
		bcd2segment bcd1(seg1, di_Sones, 1);
		
    //update segments
		always @(posedge clk) begin
			L3_segment1 = seg1;
			L3_segment2 = seg2;
			L3_segment3 = seg3;
			L3_segment4 = seg4;
		end

endmodule // Lab3_140L



//
//
// sample interface for clock datpath
//
module didp (
	     output [3:0] di_Mtens, // current 10's minutes
	     output [3:0] di_Mones, // current 1's minutes
	     output [3:0] di_Stens, // current 10's second
	     output [3:0] di_Sones, // current 1's second

	     output [3:0] di_AMtens, // current alarm 10's minutes
	     output [3:0] di_AMones, // current alarm 1's minutes
	     output [3:0] di_AStens, // current alarm 10's second
	     output [3:0] di_ASones, // current alarm 1's second

	     output wire  did_alarmMatch, // one cydie alarm match (raw signal, unqualified)

	     output [4:0] L3_led,

	     input [7:0]  bu_rx_data,
	     input 	  dicLdMtens, // load 10's minute
	     input 	  dicLdMones, // load 1's minute
	     input 	  dicLdStens, // load 10's second
	     input 	  dicLdSones, // load 1's second
	     
	     input 	  dicLdAMtens, // load alarm 10's minute
	     input 	  dicLdAMones, // load alarm 1's minute
	     input 	  dicLdAStens, // load alarm 10's second
	     input 	  dicLdASones, // load alarm 1's second
	     input 	  dicRun, //clock should run 	  
	     input 	  oneSecStrb, // one cycle strobe
	     input 	  rst,
	     input 	  clk 	  
	     );
		  
			//wires determine if loading value into outputs
			wire ld_Mtens; 
			wire ld_Mones;
			wire ld_Stens; 
			wire ld_Sones;

			//set load to be if need to load clock value or digits roll over
			assign ld_Mtens =  dicLdMtens || (di_Mtens == 4'b0101);
			assign ld_Mones =  dicLdMones || (di_Mones == 4'b1001);
			assign ld_Stens =  dicLdStens || (di_Stens == 4'b0101);
			assign ld_Sones =  dicLdSones || (di_Sones == 4'b1001);
			
			reg posStrb; //synchronizes oneSecStrb to rising clock

      //wires determine if change q value in incrementers
			wire ce_Mtens;
			wire ce_Mones;
			wire ce_Stens;
			wire ce_Sones;

      //set ce if loading digit or if rolling over from previous digits 
			assign ce_Sones = dicLdSones || dicRun && posStrb;
			assign ce_Stens = dicLdStens || dicRun && ld_Sones && posStrb;
			assign ce_Mones = dicLdMones || dicRun && ld_Stens && ld_Sones && posStrb;
			assign ce_Mtens = dicLdMtens || dicRun && ld_Mones && ld_Stens && ld_Sones && posStrb;
			
			//check if oneSecStrb is on during rising edge
			always @(posedge clk) begin
				//if one sec strobe is on, increment seconds
				posStrb = oneSecStrb;
			end
			
			
			//d inputs for clock
			wire[3:0] d_Mtens;
			wire[3:0] d_Mones;
			wire[3:0] d_Stens;
			wire[3:0] d_Sones;
      
      //set data inputs to be data if loading or 0 if counting
			assign d_Mtens = dicLdMtens ? bu_rx_data[3:0] : 4'b0000;
			assign d_Mones = dicLdMones ? bu_rx_data[3:0] : 4'b0000;
			assign d_Stens = dicLdStens ? bu_rx_data[3:0] : 4'b0000;
			assign d_Sones = dicLdSones ? bu_rx_data[3:0] : 4'b0000;
			
			//d inputs for alarm
			wire[3:0] d_AMtens;
			wire[3:0] d_AMones;
			wire[3:0] d_AStens;
			wire[3:0] d_ASones;
			
      //set data inputs to be data if loading or 0 otherwise
			assign d_AMtens = dicLdAMtens ? bu_rx_data[3:0] : 4'b0000;
			assign d_AMones = dicLdAMones ? bu_rx_data[3:0] : 4'b0000;
			assign d_AStens = dicLdAStens ? bu_rx_data[3:0] : 4'b0000;
			assign d_ASones = dicLdASones ? bu_rx_data[3:0] : 4'b0000;
			
			

			//create incrementer for each digit
			countrce inc_Mtens ( di_Mtens, d_Mtens, ld_Mtens, ce_Mtens, rst, clk); 
			countrce inc_Mones ( di_Mones, d_Mones, ld_Mones, ce_Mones, rst, clk);
			countrce inc_Stens ( di_Stens, d_Stens, ld_Stens, ce_Stens, rst, clk);
			countrce inc_Sones ( di_Sones, d_Sones, ld_Sones, ce_Sones, rst, clk);
			
			//create alarm regrce
			regrce #(.WIDTH(4)) r_AMtens(di_AMtens, d_AMtens, dicLdAMtens, rst, clk);
			regrce #(.WIDTH(4)) r_AMones(di_AMones, d_AMones, dicLdAMones, rst, clk);
			regrce #(.WIDTH(4)) r_AStens(di_AStens, d_AStens, dicLdAStens, rst, clk);
			regrce #(.WIDTH(4)) r_ASones(di_ASones, d_ASones, dicLdASones, rst, clk);
				
			//detect when alarm time matches current time
			assign did_alarmMatch = (di_Mtens == di_AMtens &&
						di_Mones == di_AMones &&
						di_Stens == di_AStens &&
						di_Sones == di_ASones);
						
				
			//assign led
			assign L3_led = 4'b0000;
   
endmodule




//
//
// sample interface for clock control
//
module dictrl(
	      output reg dicLdMtens, // load the 10's minutes
	      output reg dicLdMones, // load the 1's minutes
	      output reg dicLdStens, // load the 10's seconds
	      output reg dicLdSones, // load the 1's seconds
	      output reg dicLdAMtens, // load the alarm 10's minutes
	      output reg dicLdAMones, // load the alarm 1's minutes
	      output reg dicLdAStens, // load the alarm 10's seconds
	      output reg dicLdASones, // load the alarm 1's seconds
	      output reg dicRun, // clock should run

	      output reg dicAlarmIdle, // alarm is off
	      output reg dicAlarmArmed, // alarm is armed
	      output reg dicAlarmTrig, // alarm is triggered

	      input       did_alarmMatch, // raw alarm match

              input 	  bu_rx_data_rdy, // new data from uart rdy
              input [7:0] bu_rx_data, // new data from uart
              input 	  rst,
	      input 	  clk
	      );
			
			
			//parameters for checking what state we are in
			parameter[3:0] start = 4'b0000; //start state
			parameter[3:0] a_Load = 4'b0001;  //5 states for loading alarm
			parameter[3:0] a_Mtens = 4'b0010;
			parameter[3:0] a_Mones = 4'b0011;
			parameter[3:0] a_Stens = 4'b0100;
			parameter[3:0] a_Sones = 4'b0101;
			parameter[3:0] t_Load = 4'b0110;  //5 states for loading time
			parameter[3:0] t_Mtens = 4'b0111;
			parameter[3:0] t_Mones = 4'b1000;
			parameter[3:0] t_Stens = 4'b1001;
			parameter[3:0] t_Sones = 4'b1010;
			
			//states for loading
			reg [3:0]state = start;
			reg [3:0]next_state = start;
			
			//output from decoder
			wire esc;
			wire num;
			wire num0to5;
			wire cr;
			wire atSign;
			wire littleA;
			wire littleL;
			wire littleN;
				
			//alarm control logic
			parameter[1:0] off = 2'b00;
			parameter[1:0] armed = 2'b01;
			parameter[1:0] triggered = 2'b10;
			
			//states for alarm control
			reg [1:0]alarm_state = off;
			reg [1:0]alarm_next_state = off;
			
			reg idle; //checks if state remained the same 
	
			// initially set clock to running and alarm to off
			initial begin
				dicRun = 1;
				dicAlarmIdle = 1;
				dicAlarmArmed = 0;
				dicAlarmTrig = 0;
			end
		
			//decoder for getting keys
			decodeKeys decoder( esc, num, num0to5, cr, atSign, littleA, littleL, littleN, bu_rx_data, bu_rx_data_rdy);
			
			//set state on rising clock edge
			always @(posedge clk)
				begin
					idle <= 0;
          //set to start on reset
					if (rst) begin
						state  <= start;
						alarm_state <= off;
					end
          //else set state to next state
					else begin
						if(state == next_state) //check if next_state is same as current state
							idle <= 1;
						else
							idle <= 0;
						state <= next_state;
						alarm_state <= alarm_next_state;
					end
				end
				
			//change next_state on input
			always @(state, bu_rx_data_rdy)
				
				//set next state based on current state and input
				begin
					case(state)
						//start
						start:
							begin
								if(littleA) begin
									next_state = a_Load;
									end
								else if(littleL)begin
									next_state = t_Load;
									end
								else
									next_state = state;
							end
							
						//set alarm sequence
						a_Load:
							begin
								
								if(num0to5) begin
									next_state = a_Mtens;
									end
								else
									next_state = state;
							end
						a_Mtens:
							begin
								if(num) begin
									next_state = a_Mones;
								end
								else
									next_state = state;
							end					
						a_Mones:
							begin
								if(num0to5) begin
									next_state = a_Stens;
									end
								else
									next_state = state;
							end
						a_Stens:
							begin
								if(num) begin
									next_state = a_Sones;
									end
								else
									next_state = state;

							end
						a_Sones:
							begin
								if(cr) begin
									next_state = start;
								end
								else
									next_state = state;


							end
						
						//set time sequence
						t_Load:
							begin
								if(num0to5) begin
									next_state = t_Mtens;
									end
								else
									next_state = state;


							end
						t_Mtens:
							begin
								if(num) begin
									next_state = t_Mones;
									end
								else
									next_state = state;


							end					
						t_Mones:
							begin
								
								if(num0to5) begin
									next_state = t_Stens;
									end
								else
									next_state = state;


							end
						t_Stens:
							begin
								
								if(num) begin
									next_state = t_Sones;
									end
								else
									next_state = state;


							end
						t_Sones:
							begin
								
								if(cr) begin
									next_state = start;
									end
								else
									next_state = state;


							end
							default: next_state = start;
						endcase //case(state)
					end //always @(state, bu_rx_data_rdy)
			
			//change Ld values when next_state is set
			always @(next_state)
				
				//set output and next state based on current state and input
				begin
					//set outputs to 0 then change based on state
					dicLdMtens <= 0;
					dicLdMones <= 0;
					dicLdStens <= 0;
					dicLdSones <= 0;
					dicLdAMtens <= 0;
					dicLdAMones <= 0;
					dicLdAStens <= 0;
					dicLdASones <= 0;
					dicRun <= 0;
					
					if(idle == 0) begin
						case(state)
							//start
							start:
								begin
									dicRun <= 1;	
								end
								
							//set alarm sequence
							a_Load:
								begin
									dicRun <= 1;
								end
							a_Mtens:
								begin
									dicRun <= 1;
									dicLdAMtens <= 1;
								end					
							a_Mones:
								begin
									dicLdAMones <= 1;
									dicRun <= 1;
								end
							a_Stens:
								begin
									dicLdAStens <= 1;
									dicRun <= 1;
								end
							a_Sones:
								begin
									dicRun <= 1;
									dicLdASones <= 1;
								end
							
							//set time sequence
							t_Load:

								begin
									dicRun <= 0;
								end
							t_Mtens:
								begin
									dicLdMtens <= 1;
									dicRun <= 0;
								end					
							t_Mones:
								begin
									
									dicLdMones <= 1;
									dicRun <= 0;
								end
							t_Stens:
								begin
									
									dicLdStens <= 1;
									dicRun <= 0;
								end
							t_Sones:
								begin
									dicLdSones <= 1;
									dicRun <= 0;
								end
							endcase //case(state)
						end //end if(idle == 0)
						else begin //set dicRun based on which sequence we are in
							if(state != t_Load && state != t_Mtens && state != t_Mones
								&& state != t_Stens && state != t_Sones)
								dicRun <= 1;
							else
								dicRun <= 0;
						end
					end //always @(state, bu_rx_data_rdy)

			
			//set output and next state based on current state and input
			always @(alarm_state, did_alarmMatch, bu_rx_data_rdy)
			begin
				case(alarm_state)
					off:
						begin
							if(atSign) begin // '@' go to armed
								alarm_next_state <= armed;
								dicAlarmArmed <= 1;
								dicAlarmTrig <= 0;
								dicAlarmIdle <= 0;
								end
							else
								alarm_next_state <= alarm_state;
						end
					armed:
						begin
							if(atSign) begin //'@' go to off
								alarm_next_state <= off;
								dicAlarmIdle <= 1;
								dicAlarmArmed <= 0;
								dicAlarmTrig <= 0;
								end
							else if(did_alarmMatch) begin //go to triggered on alarm match
								alarm_next_state <= triggered;
								dicAlarmTrig <= 1;
								dicAlarmIdle <= 0;
								dicAlarmArmed <= 0;
								end
							else
								alarm_next_state <= alarm_state;
						end
					triggered:
						begin
							if(atSign) begin // '@' go to off
								alarm_next_state <= off;
								dicAlarmIdle <= 1;
								dicAlarmTrig <= 0;
								dicAlarmArmed <= 0;
								end
							else
								alarm_next_state <= alarm_state;
						end

					default: begin // default state is off
						alarm_next_state <= off;
						dicAlarmIdle <= 1;
						dicAlarmTrig <= 0;
						dicAlarmArmed <= 0;
					end
					endcase //case(alarm_state)
			end //always @(alarm_state, bu_rx_data_rdy)
			
						
								
				
   
endmodule

