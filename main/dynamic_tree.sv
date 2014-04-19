//
//
//module Dynamic_Tree ( clk, glob_com, data_in, data_out );
//
//parameter HBIT= 15;
//
//parameter X_SZ= 8;
//parameter Y_SZ= 8;
//
//input clk;
//input [1:0]glob_com;
//
//input [HBIT:0] data_in;
//output [HBIT:0] data_out;
//
//wire [HBIT:0] in_prev;
//wire [HBIT:0] in_next;
//wire [HBIT:0] out;
//
//
//
//endmodule
//
//
//
//typedef struct {
//bit [1] com;
//bit [15:0] dat;
//} CDT_port;
//
//module Cell_Dyna_Tree ( clk, glob_com, stageGlb, is_input, in_prev, in_next, out );
//
//parameter HBIT= 15;
//
//
//input clk;
//input glob_com;
//
//input  stageGlb[3:0];
//input  candidateActive[3:0];
//
//input  parentPtr[3:0];
//input  [HBIT:0] pntInQuestMsg [3:0];
//input  [HBIT:0] cldInQuestMsg [3:0];
//output active =  |parentPtr;
//output  [HBIT:0] message;
//
//output bit  leftPtr [3:0];
//output bit  rightPtr[3:0];
//
//wire leftRq;	//	have left subtree
//wire rightRq;	//	have right subtree
//
////wire parentMsg= pntInQuestMsg[];
//
//Cell_DT_Inner #( HBIT ) inner ( clk, glob_com, parentMsg, leftMsg, rightMsg, message );
//
//always@(posedge clk )
//begin
//	if ( leftRq )
//	begin
//		if ( leftPtr==0 )	//	new child required
//		begin
//			if ( stageGlb & ~candidateActive )
//			begin
//				leftPtr<= stageGlb;
//			end
//		end
//	end
//	else
//	begin
//		leftPtr<= 0;
//	end
//	if (~hold)
//	begin
//		higher <= ( cand_h > cand_l ) ? cand_h : cand_l;
//		lower  <= ( cand_h > cand_l ) ? cand_l : cand_h;
//	end
//end
//endmodule
//
//
//module Cell_DT_Inner ( clk, glob_com, parentMsg, leftMsg, rightMsg, message );
//parameter HBIT= 15;
//
//input clk;
//input [1:0]glob_com;
//
//input  [HBIT:0] parentMsg;
//input  [HBIT:0] leftMsg;
//input  [HBIT:0] rightMsg;
//output  [HBIT:0] message;
//
//reg [HBIT:0] store;
//reg [HBIT:0] tmp;
//
//always@(posedge clk )
//begin
//	case( glob_com )
//	2'h0: ;	
//	2'h1: ;
//	2'h2:	
//		begin
//			higher <= ( cand_h > cand_l ) ? cand_h : cand_l;
//			lower  <= ( cand_h > cand_l ) ? cand_l : cand_h;
//		end
//	2'h3:	;
//	endcase
//end
//
//endmodule
//
//
//
