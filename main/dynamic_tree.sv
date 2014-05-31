




module Dyna_Tree ( clk, glob_com, dataIn, dataOut );

parameter HBIT= 3;
parameter TREE_LEVEL= 4;
parameter IMRIGHT= 0;

input clk;
input [1:0] glob_com;

output TPort dataOut;
input  TPort dataIn;


TPort fromLeft;
TPort fromRight;

Cell_DT_Inner #( HBIT, IMRIGHT ) inner ( clk, glob_com, dataIn, fromLeft, fromRight, dataOut );

generate
if ( TREE_LEVEL >0 )
begin
	Dyna_Tree #( HBIT, TREE_LEVEL-1, 0 ) leftSubTree  ( clk, glob_com, dataOut, fromLeft );
	Dyna_Tree #( HBIT, TREE_LEVEL-1, 1 ) rightSubTree ( clk, glob_com, dataOut, fromRight );
end
else
begin
	assign fromLeft.msg =VMS_STOP;
	assign fromRight.msg=VMS_STOP;
end
endgenerate


endmodule






typedef enum bit[3:0] { 	VK_EMPTY=4'h0, 
						VK_EOF,
						VK_DUMMY1,
						VK_DUMMY2,
						VK_DUMMY3,
						VK_DUMMY4,
						VK_DUMMY5,
						VK_APPLY,
						VK_K,
						VK_DUMMY6,
						VK_DUMMY7,
						VK_DUMMY8,
						VK_DUMMY9
		} VKind;

typedef enum bit[3:0] { 	VMS_EMPTY=4'h0, 
						VMS_EOF,
						VMS_READY,
						VMS_WRITE,
						VMS_READ,
						VMS_STOP		//	end of tree
		} VMeta;

typedef enum bit[1:0]{ 	TO_PARENT=2'h0, 
						TO_CHILDREN,
						TO_LEFT,
						TO_RIGHT
		} VTarget;

typedef struct{
bit	[3:0] msg;
bit	[1:0] tgt;
		} TPort;

		
		
		
		
		
		
module Cell_DT_Inner ( clk, glob_com, i_fromParent, i_fromLeft, i_fromRight, message );
parameter HBIT= 7;
parameter IMRIGHT= 0;

input clk;
input [1:0] glob_com;

input  TPort i_fromParent;
input  TPort i_fromLeft;
input  TPort i_fromRight;

wire [HBIT:0] fromParent= ((IMRIGHT==0) && ( i_fromParent.tgt == TO_CHILDREN || i_fromParent.tgt == TO_LEFT )) ||
							  ((IMRIGHT==1) && ( i_fromParent.tgt == TO_CHILDREN || i_fromParent.tgt == TO_RIGHT ))
							  ? i_fromParent.msg : 4'h0;

wire [HBIT:0] fromLeft=   ( i_fromLeft.tgt == TO_PARENT  ) ? i_fromLeft.msg  : 4'h0;
wire [HBIT:0] fromRight=  ( i_fromRight.tgt == TO_PARENT ) ? i_fromRight.msg : 4'h0;

reg [HBIT:0] value;
output TPort message;
VMeta        state;
reg [3:0] step;

always@(posedge clk )
begin
	case( glob_com )
	0:								//	working mode
	begin
		case( state )
		VMS_EMPTY:					//	sleeping
		begin
			value <=  fromParent==VK_APPLY || fromParent==VK_K ? fromParent : VK_DUMMY9;		//	write self
			case( fromParent )
			VK_EMPTY:;					//	still sleeping
			VK_APPLY:					//	write subtrees	
				state <= VMS_WRITE;
			default:						//	i'm a leaf
			begin
				message.msg <= VMS_READY;
				message.tgt <= TO_PARENT;
				state       <= VMS_READY;
			end
			endcase
		end
		
		VMS_WRITE:	
		begin
			case( step )
			0:									//	writing left
				if ( fromLeft == VMS_EMPTY )
				begin								//	write left
					message.msg <= fromParent;
					message.tgt <= TO_LEFT;
				end
				else
				begin								//	begin writing right
					message.msg <= fromParent;
					message.tgt <= TO_RIGHT;
					step        <= step+4'h1;
				end
			1:									//	writing right
				if ( fromRight == VMS_EMPTY )
				begin								//	write right
					message.msg <= fromParent;
					message.tgt <= TO_RIGHT;
				end
				else
				begin								//	job well done, notify parent
					message.msg <= VMS_READY;
					message.tgt <= TO_PARENT;
					state       <= VMS_READY;
					step        <= 0;
				end
			endcase
		end
		
		VMS_READ:	
		begin
			case( step )
			0:									
			if ( value != VK_APPLY )
			begin
				message.msg <= VK_EOF;		//	leaf's report
				message.tgt <= TO_PARENT;
				state       <= VMS_READY;
			end
			else if ( fromLeft==VMS_READY )
			begin
				message.msg <= VMS_READ;	//	begin read left
				message.tgt <= TO_LEFT;
				step        <= 4'h1;
			end
			else 
				message.msg <= VK_EMPTY;	//	wait for left
			1:
				case( fromLeft )
				VK_EMPTY:;
				VK_EOF:
				begin
					step        <= 4'h2;
					message.msg <= VK_EMPTY;
				end
				default:							//	transfer left
				begin
					message.msg <= fromLeft;	
					message.tgt <= TO_PARENT;
				end
				endcase
			2:									//	begin read right
			if ( fromRight==VMS_READY )
			begin
				message.msg <= VMS_READ;	
				message.tgt <= TO_RIGHT;
				step        <= 4'h3;
			end
			else 
				message.msg <= VK_EMPTY;	//	wait for right
			3:
				case( fromRight )
				VK_EMPTY:;
				VK_EOF:
				begin
					message.msg <= fromRight;	
					state       <= VMS_READY;
					step        <= 0;
				end
				default:							//	transfer right
				begin
					message.msg <= fromRight;	
					message.tgt <= TO_PARENT;
				end
				endcase
			endcase
		end
		
		VMS_READY:	
		begin
			case( fromParent )
			VMS_READ:						//	read self
			begin
				message.msg <= value;	
				message.tgt <= TO_PARENT;
				state       <= VMS_READ;
			end
			default:
			begin
				message.msg <= VMS_READY;	
				message.tgt <= TO_PARENT;
			end
			endcase
		end
		endcase
	end
	default:								//	reset mode	
	begin
		state    <= VMS_EMPTY;
		message.msg  <= VMS_EMPTY;
		step 		<= 0;
	end
	endcase
end

endmodule



