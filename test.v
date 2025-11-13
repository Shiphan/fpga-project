module led (clk, reset, segout, scanout);

input clk, reset;
output reg [7:0] segout;
output reg [2:0] scanout;


reg [10:0] group_a [0:19];
reg [10:0] group_b [0:39];

reg [7:0] group;
reg [7:0] count;
integer i;

reg [25:0] cnt_scan = 0; 
reg [2:0] index;	 
reg clk1 = 0;		 

initial begin
	  
	  group_a[0]  = 11'b000_00000001;
	  group_a[1]  = 11'b001_00000001;
	  group_a[2]  = 11'b010_00000001;
	  group_a[3]  = 11'b011_00000001;
	  group_a[4]  = 11'b100_00000001;
	  group_a[5]  = 11'b101_00000001;
	  group_a[6]  = 11'b101_00100000;
	  group_a[7]  = 11'b101_00010000;
	  group_a[8]  = 11'b101_00001000;
	  group_a[9]  = 11'b100_00001000;
	  group_a[10] = 11'b011_00001000;
	  group_a[11] = 11'b010_00001000;
	  group_a[12] = 11'b001_00001000;
	  group_a[13] = 11'b000_00001000;

	  
	  group_b[0]  = 11'b000_00000001; 
	  group_b[1]  = 11'b000_00000010; 
	  group_b[2]  = 11'b000_01000000; 
	  group_b[3]  = 11'b000_00100000; 
	  group_b[4]  = 11'b000_00001000; 
	  group_b[5]  = 11'b001_00001000; 
	  group_b[6]  = 11'b001_00000100; 
	  group_b[7]  = 11'b001_01000000; 
	  group_b[8]  = 11'b001_10000000; 
	  group_b[9]  = 11'b001_00000001; 
	  group_b[10] = 11'b010_00000001; 
	  group_b[11] = 11'b010_00000010; 
	  group_b[12] = 11'b010_01000000; 
	  group_b[13] = 11'b010_00100000; 
	  group_b[14] = 11'b010_00001000; 
	  group_b[15] = 11'b011_00001000; 
	  group_b[16] = 11'b011_00000100; 
	  group_b[17] = 11'b011_01000000; 
	  group_b[18] = 11'b011_10000000; 
	  group_b[19] = 11'b011_00000001; 
	  group_b[20] = 11'b100_00000001; 
	  group_b[21] = 11'b100_00000010; 
	  group_b[22] = 11'b100_01000000; 
	  group_b[23] = 11'b100_00100000; 
	  group_b[24] = 11'b100_00001000; 
	  group_b[25] = 11'b101_00001000; 
	  group_b[26] = 11'b101_00000100; 
	  group_b[27] = 11'b101_01000000; 
	  group_b[28] = 11'b101_10000000; 
	  group_b[29] = 11'b101_00000001; 
end


always @(posedge clk) begin
	cnt_scan <= cnt_scan + 1;
	if (cnt_scan == 50_000) begin
		cnt_scan <= 0;
		clk1 <= ~clk1; 
	end
end

always @(posedge clk1 or posedge reset) begin
	if (reset) begin
		group <= 0;
		count <= 0;
	end else begin
		case (group)
			0: if (count >= 13) begin
				group <= 1;
				count <= 0;
			end else begin
				count = count + 1;
			end
			1: if (count >= 29) begin
				group <= 0;
				count <= 0;
			end else begin
				count = count + 1;
			end
			default: begin
				group <= 0;
				count <= 0;
			end
		endcase
	end
end

always @(*) begin
	scanout = cnt_scan[13:11];
	segout = 8'b00000000;

	 case (group)
		0: begin
			for (i = 0; i < 5; i = i + 1) begin
				if (count >= i && scanout == group_a[count - i][10:8]) begin
					segout = segout | group_a[count - i][7:0];
					
				end
			end
		end
		1: begin
			for (i = 0; i < 5; i = i + 1) begin
				if (count >= i && scanout == group_b[count - i][10:8]) begin
					segout = segout | group_b[count - i][7:0];
				end
			end
		end
		default: begin
			segout = 8'b00000000;
		end
	 endcase
end

endmodule
