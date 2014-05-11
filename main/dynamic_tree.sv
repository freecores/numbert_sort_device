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

module Dyna_Tree ( clk, glob_com, dataIn, dataOut );

parameter HBIT= 7;
parameter TREE_LEVEL= 4;

input clk;
input [1:0] glob_com;

input  [HBIT:0] dataIn;
output [HBIT:0] dataOut;

wire [HBIT:0] toLeft;
wire [HBIT:0] toRight;
wire [HBIT:0] fromLeft;
wire [HBIT:0] fromRight;

Cell_DT_Inner #( HBIT ) inner ( clk, glob_com, dataIn, fromLeft, fromRight, dataOut, toLeft, toRight );

generate
if ( TREE_LEVEL >0 )
begin
	Dyna_Tree #( HBIT, TREE_LEVEL-1 ) leftSubTree  ( clk, glob_com, toLeft, fromLeft );
	Dyna_Tree #( HBIT, TREE_LEVEL-1 ) rightSubTree ( clk, glob_com, toRight, fromRight );
end
else
begin
	assign fromLeft =1;
	assign fromRight=1;
end
endgenerate


endmodule


typedef enum { 	VMS_NOMESSAGE=0, 
						VMS_WRITE,
						VMS_READ
		} VMeta;

module Cell_DT_Inner ( clk, glob_com, fromParent, fromLeft, fromRight, toParent, toLeft, toRight );
parameter HBIT= 7;

input clk;
input [1:0] glob_com;

input  [HBIT:0] fromParent;
input  [HBIT:0] fromLeft;
input  [HBIT:0] fromRight;

output [HBIT:0] toParent;
output [HBIT:0] toLeft;
output [HBIT:0] toRight;

reg [HBIT:0] value;
reg [HBIT:0] message;
VMeta        state;

assign toParent= value + message;
assign toLeft= message;
assign toRight= value;

always@(posedge clk )
begin
	case( state )
	VMS_NOMESSAGE: ;	
	VMS_WRITE:	
		begin
			value    <= fromParent +1;
			message  <= fromParent;
		end
	VMS_READ:	
		begin
			value    <= fromLeft;
			message  <= fromRight;
		end
	2'h3:	;
	default:	;
	endcase
	state    <= VMeta'(glob_com);
end

endmodule



