
// --------------------------------------------------------------------
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
//
//                     Lih-Feng Tsaur
//                     Bryan Chin
//                     UCSD CSE Department
//                     9500 Gilman Dr, La Jolla, CA 92093
//                     U.S.A
//
// --------------------------------------------------------------------
//
// bcd2segment
//
// convert binary coded decimal to seven segment display
//
//                        aaa
//                       f   b 
//                       f   b
//                       f   b				
//                        ggg
//                       e   c
//                       e   c
//                       e   c
//                        ddd 
//
// segment[0] - a     segment[3] - d    segment[6] - g
// segment[1] - b     segment[4] - e
// segment[2] - c     segment[5] - f
//
module bcd2segment (
		  output wire [6:0] segment,  // 7 drivers for segment
		  input  wire [3:0] num,       // number to convert
		  input wire enable          // if 1, drive display, else blank
      input wire [2:0] letter,
      input alarmTrig
		  );


   wire    zero = (~|num) && !alarmTrig;
   wire	   one = (~|(num[3:0]^4'b0001)) && !alarmTrig;
   wire	   two = (~|(num[3:0]^4'b0010)) && !alarmTrig; 
   wire	   three = (~|(num[3:0]^4'b0011)) && !alarmTrig;
   wire	   four = (~|(num[3:0]^4'b0100)) && !alarmTrig;
   wire	   five = (~|(num[3:0]^4'b0101)) && !alarmTrig;
   wire	   six = (~|(num[3:0]^4'b0110)) && !alarmTrig;
   wire	   seven = (~|(num[3:0]^4'b0111)) && !alarmTrig;
   wire    eight = (~|(num[3:0]^4'b1000)) && !alarmTrig;
   wire	   nine = (~|(num[3:0]^4'b1001)) && !alarmTrig;
   wire	   ten = (~|(num[3:0]^4'b1010)) && !alarmTrig;
   wire	   eleven = (~|(num[3:0]^4'b1011)) && !alarmTrig;
   wire    twelve = (~|(num[3:0]^4'b1100)) && !alarmTrig;
   wire	   thirteen = (~|(num[3:0]^4'b1101)) && !alarmTrig;
   wire    fourteen = (~|(num[3:0]^4'b1110)) && !alarmTrig;
   wire	   fifteen = (~|(num[3:0]^4'b1111)) && !alarmTrig;
   wire b = letter == 3'b001 && alarmTrig;
   wire p = letter == 3'b010 && alarmTrig;
   wire e = letter == 3'b011 && alarmTrig;
   


   wire [6:0] segmentUQ;
   
   // a
   assign segmentUQ[0] =  (
		       zero | two | three | five | six | seven | eight | nine | ten |
		       twelve | fourteen | fifteen | p);
   // b
   assign segmentUQ[1] = (
		       zero | one | two | three | four | seven |
		       eight | nine | ten | thirteen | p);
   // c
   assign segmentUQ[2] = (
		      zero | one | three | four | five | six | seven |
		      eight | nine | ten | eleven | thirteen) | b ;
   
   // d
   assign segmentUQ[3] = ( 
				zero | two | three | five | six | eight | twelve | thirteen |
				fifteen | b | e1 | e2);
   
   // e
   assign segmentUQ[4] = ( 
				zero | two | six | eight | twelve | b | p | e1 | e2);

   
   // f
   assign segmentUQ[5] = ( 
				zero | four | five | six | eight | nine |
				fourteen | fifteen | b | p | e1 | e2);

   // g
   assign segmentUQ[6] = ( 
				two | three | four | five | six | eight | nine |
				twelve | thirteen | fourteen | fifteen | b | p | e1 | e2);

   assign segment = {7{enable}} & segmentUQ;
   
endmodule

   
   

   
   
   
   
   
   

   
   

