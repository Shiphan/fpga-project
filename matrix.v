module matrix (
	clk,
	reset,
	arrow_up,
	arrow_down,
	arrow_left,
	arrow_right,
	led_segout,
	led_scanout,
	matrix_segout_r,
	matrix_segout_g,
	matrix_scanout,
);

input clk, reset;
input arrow_up, arrow_down, arrow_left, arrow_right;
output reg [7:0] led_segout;
output reg [2:0] led_scanout;
output reg [7:0] matrix_segout_r;
output reg [7:0] matrix_segout_g;
output reg [7:0] matrix_scanout;

reg [15:0] timer;
reg [15:0] score;

reg [1:0] arrow;
reg [1:0] dire;
reg [5:0] snake [63:0];
reg [7:0] snake_on_map [7:0];
reg [7:0] snake_length;

reg [7:0] random;
reg [25:0] seed;
reg [5:0] apple;

reg [25:0] cnt_scan = 0;
reg clk_500ms;
reg [2:0] row;

reg [7:0] led_pattern [9:0];

reg [7:0] i;

initial begin
	timer = 16'd0;
	score = 16'd0;
	arrow = 2'd0;
	dire= 2'd0;
	snake[0] = 6'b000_000;
	snake_length = 8'd1;
	apple = 6'b011_100;  // initial apple at row 3, column 4

	led_pattern[0] = 8'b11111100;
	led_pattern[1] = 8'b01100000;
	led_pattern[2] = 8'b11011010;
	led_pattern[3] = 8'b11110010;
	led_pattern[4] = 8'b01100110;
	led_pattern[5] = 8'b10110110;
	led_pattern[6] = 8'b10111110;
	led_pattern[7] = 8'b11100000;
	led_pattern[8] = 8'b11111110;
	led_pattern[9] = 8'b11110110;
end

always @(posedge clk) begin
	cnt_scan <= cnt_scan + 1;
	if (cnt_scan == 5_000_000) begin
		cnt_scan <= 0;
		clk_500ms <= ~clk_500ms;
	end
end

reg[7:0] random_a;
always @(posedge clk_500ms or negedge reset) begin
	if (!reset) begin
		timer = 16'd0;
		score = 16'd0;
		dire= 2'd0;
		snake[0] = 6'b000_000;
		snake_length = 8'd1;
		apple = 6'b011_100;  // initial apple at row 3, column 4
	end else begin
		timer = timer + 16'd01;
		// 500ms

		// move body
		for (i = 63; i > 0; i = i - 1) begin
			snake[i] = snake[i - 1];
		end

		// move head
		dire = arrow;
		case (arrow)
			2'd0: begin
				if (snake[0][5:3] == 0) begin
					snake[0] = snake[0] | 6'b111_000;
				end else begin
					snake[0] = snake[0] - 6'b001_000; // up
				end
			end
			2'd1: begin
				if (snake[0][5:3] == 7) begin
					snake[0] = snake[0] & 6'b000_111;
				end else begin
					snake[0] = snake[0] + 6'b001_000; // down
				end
			end
			2'd2: begin
				if (snake[0][2:0] == 0) begin
					snake[0] = snake[0] | 6'b000_111;
				end else begin
					snake[0] = snake[0] - 6'b01; // left
				end
			end
			2'd3: begin
				if (snake[0][2:0] == 7) begin
					snake[0] = snake[0] & 6'b111_000;
				end else begin
					snake[0] = snake[0] + 6'b01; // right
				end
			end
		endcase

		// reset snake_on_map
		for (i = 0; i < 8; i = i + 1) begin
			snake_on_map[i] = 8'b0;
		end

		for (i = 1; i < 64; i = i + 1) begin
			if (i < snake_length) begin
				snake_on_map[snake[i][5:3]] = snake_on_map[snake[i][5:3]] | 8'b00000001 << snake[i][2:0];
			end
		end
		// check if head is on the body
		if (snake_on_map[snake[0][5:3]] & 8'b00000001 << snake[0][2:0] != 8'b0) begin
			// the snake's head hit body
			// TODO: i just reset everything for now, maybe we can
			// add some cool effect and then reset

			timer = 16'd0;
			score = 16'd0;
			dire= 2'd0;
			snake[0] = 6'b000_000;
			snake_length = 8'd1;
			apple = 6'b011_100;
		end else begin
			snake_on_map[snake[0][5:3]] = snake_on_map[snake[0][5:3]] | 8'b00000001 << snake[0][2:0];

			if (snake[0][5:0] == apple[5:0]) begin
				score = score + 1;

				// graw the snake
				snake_length = snake_length + 1;
				snake_on_map[snake[snake_length - 1][5:3]] = snake_on_map[snake[snake_length - 1][5:3]] | 8'b00000001 << snake[snake_length - 1][2:0];

				// gen apple
				random = seed;
				if (random == 8'b0) begin
					random = 8'd234;
				end
				random = random ^ (random << 12) ^ (random >> 7) ^ (random << 3);
				random_a = random % (64 - snake_length) + 1;

				for (i = 0; i < 64; i = i + 1) begin
					if (random_a != 8'b0 && (snake_on_map[i / 8] & 8'b01 << (i % 8)) == 8'b0) begin
						random_a = random_a - 1;
						if (random_a == 8'b0) begin
							apple[5:3] = i / 8;  // random row (0-7)
							apple[2:0] = i % 8;  // random column (0-7)
						end
					end
				end
			end
		end
	end
end

always @(negedge reset or negedge arrow_up or negedge arrow_down or posedge arrow_left or posedge arrow_right) begin
	seed = seed ^ cnt_scan;
	if (!reset) begin
		arrow = 2'd0;
	end else if (!arrow_up) begin
		if (dire != 2'd1)
			arrow = 2'd0;
	end else if (!arrow_down) begin
		if (dire != 2'd0)
			arrow = 2'd1;
	end else if (arrow_left) begin
		if (dire != 2'd3)
			arrow = 2'd2;
	end else if (arrow_right) begin
		if (dire != 2'd2)
			arrow = 2'd3;
	end
end

always @(cnt_scan[15:13]) begin
	// led
	if (cnt_scan[15:13] < 3'd6) begin
		led_scanout = cnt_scan[15:13];
		led_segout = led_pattern[
			led_scanout < 3
			? ((timer[15:1] / (15'd10 ** (2 - led_scanout))) % 10)
			: ((score / (15'd10 ** (5 - led_scanout))) % 10)
		];
	end else begin
		led_scanout = 3'b0;
		led_segout = 8'b0;
	end

	row = cnt_scan[15:13];
	matrix_scanout = 8'b00000001 << row;
	matrix_segout_r = 8'b00000000;
	matrix_segout_g = 8'b00000000;

	// show snake
	if (snake[0][5:3] == row) begin
		matrix_segout_r = matrix_segout_r | 8'b00000001 << snake[0][2:0];
	end
	matrix_segout_g = snake_on_map[row];

	// show apple
	if (row == apple[5:3]) begin
		matrix_segout_r = matrix_segout_r | 8'b00000001 << apple[2:0];
	end
end

endmodule
