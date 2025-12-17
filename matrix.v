module matrix (
	clk,
	reset,
	test,
	arrow_up,
	arrow_down,
	arrow_left,
	arrow_right,
	music_enable,
	led_segout,
	led_scanout,
	matrix_segout_r,
	matrix_segout_g,
	matrix_scanout,
	buzzer,
);

input clk, reset, test, music_enable;
input arrow_up, arrow_down, arrow_left, arrow_right;
output reg [7:0] led_segout;
output reg [2:0] led_scanout;
output reg [7:0] matrix_segout_r;
output reg [7:0] matrix_segout_g;
output reg [7:0] matrix_scanout;
output buzzer;

reg [11:0] timer;
reg [11:0] score;

reg [1:0] stage;

reg [1:0] arrow;
reg [1:0] dire;
reg [5:0] snake [63:0];
reg [7:0] snake_on_map [7:0];
reg [7:0] snake_length;

reg [7:0] random;
reg [7:0] seed;
reg [5:0] apple;

reg [25:0] cnt_scan;
reg [25:0] cnt_1s;
reg clk_500ms;
reg clk_1000ms;
reg [2:0] row;

reg [7:0] led_pattern [9:0];
reg [31:0] win_matrix_start_r [7:0];
reg [31:0] win_matrix_start_g [7:0];
reg [31:0] lose_matrix_start_r [7:0];
reg [31:0] lose_matrix_start_g [7:0];

reg [47:0] result_matrix_r [7:0];
reg [47:0] result_matrix_g [7:0];
reg [7:0] result_matrix_length;

reg [2:0] matrix_number_partten [9:0] [5:0];
reg [2:0] matrix_s_partten [5:0];
reg [4:0] matrix_apple_partten_r [5:0];
reg [4:0] matrix_apple_partten_g [5:0];

reg [7:0] roll;

// Music
// reg [15:0] feq;
// reg [31:0] cnt_buzzer;
// reg [31:0] cnt_beat;
// reg [15:0] beat;
//
// reg [15:0] sheet [31:0];

reg [7:0] i;

// Music 2
wire [5:0] note_index;
wire [14:0] tone;

initial begin
	cnt_scan = 26'd0;
	cnt_1s = 26'd0;
	timer = 12'd0;
	score = 12'd0;
	stage = 2'd0;
	arrow = 2'd0;
	dire = 2'd1;
	snake[0] = 6'b000_000;
	snake_length = 8'd1;
	apple = 6'b011_100;  // initial apple at row 3, column 4
	result_matrix_length = 8'd0;
	roll = 8'd8;

	// feq = 16'd200;

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

	// sheet[0] = 597;
	// sheet[1] = 563;
	// sheet[2] = 563;
	// sheet[3] = 532;
	// sheet[4] = 502;
	// sheet[5] = 502;
	// sheet[6] = 474;
	// sheet[7] = 447;
	// sheet[8] = 422;
	// sheet[9] = 422;

	win_matrix_start_r[0] = 32'b00000000_00000000_00000000_00000000;
	win_matrix_start_r[1] = 32'b00001001_00000000_00000000_00010100;
	win_matrix_start_r[2] = 32'b00010001_01101011_01110100_01010100;
	win_matrix_start_r[3] = 32'b00100010_00101010_00100110_01010100;
	win_matrix_start_r[4] = 32'b00110000_00101010_00100101_01010100;
	win_matrix_start_r[5] = 32'b01111000_00010100_00100100_11000000;
	win_matrix_start_r[6] = 32'b01100000_00010100_01110100_01010100;
	win_matrix_start_r[7] = 32'b10000000_00000000_00000000_00000000;

	win_matrix_start_g[0] = 32'b00010010_00000000_00000000_00000000;
	win_matrix_start_g[1] = 32'b00000000_00000000_00000000_00010100;
	win_matrix_start_g[2] = 32'b00000000_01101011_01110100_01010100;
	win_matrix_start_g[3] = 32'b00100100_00101010_00100110_01010100;
	win_matrix_start_g[4] = 32'b00110100_00101010_00100101_01010100;
	win_matrix_start_g[5] = 32'b01111000_00010100_00100100_11000000;
	win_matrix_start_g[6] = 32'b01100000_00010100_01110100_01010100;
	win_matrix_start_g[7] = 32'b10000000_00000000_00000000_00000000;

	lose_matrix_start_r[0] = 32'b00000000_00000000_00000000_00000000;
	lose_matrix_start_r[1] = 32'b00111100_00000000_00000000_00000000;
	lose_matrix_start_r[2] = 32'b01111110_01111101_00010111_10000000;
	lose_matrix_start_r[3] = 32'b01011010_00100001_10010100_01000000;
	lose_matrix_start_r[4] = 32'b01111110_00111001_01010100_01000000;
	lose_matrix_start_r[5] = 32'b00100100_00100001_00110100_01000000;
	lose_matrix_start_r[6] = 32'b00100100_01111101_00010111_10010100;
	lose_matrix_start_r[7] = 32'b00000000_00000000_00000000_00000000;

	lose_matrix_start_g[0] = 32'b00000000_00000000_00000000_00000000;
	lose_matrix_start_g[1] = 32'b00000000_00000000_00000000_00000000;
	lose_matrix_start_g[2] = 32'b00000000_01111101_00010111_10000000;
	lose_matrix_start_g[3] = 32'b00000000_00100001_10010100_01000000;
	lose_matrix_start_g[4] = 32'b00000000_00111001_01010100_01000000;
	lose_matrix_start_g[5] = 32'b00000000_00100001_00110100_01000000;
	lose_matrix_start_g[6] = 32'b00000000_01111101_00010111_10010100;
	lose_matrix_start_g[7] = 32'b00000000_00000000_00000000_00000000;

	matrix_number_partten[0][0] = 3'b111;
	matrix_number_partten[0][1] = 3'b101;
	matrix_number_partten[0][2] = 3'b101;
	matrix_number_partten[0][3] = 3'b101;
	matrix_number_partten[0][4] = 3'b101;
	matrix_number_partten[0][5] = 3'b111;

	matrix_number_partten[1][0] = 3'b110;
	matrix_number_partten[1][1] = 3'b010;
	matrix_number_partten[1][2] = 3'b010;
	matrix_number_partten[1][3] = 3'b010;
	matrix_number_partten[1][4] = 3'b010;
	matrix_number_partten[1][5] = 3'b111;

	matrix_number_partten[2][0] = 3'b111;
	matrix_number_partten[2][1] = 3'b101;
	matrix_number_partten[2][2] = 3'b001;
	matrix_number_partten[2][3] = 3'b111;
	matrix_number_partten[2][4] = 3'b100;
	matrix_number_partten[2][5] = 3'b111;

	matrix_number_partten[3][0] = 3'b111;
	matrix_number_partten[3][1] = 3'b001;
	matrix_number_partten[3][2] = 3'b001;
	matrix_number_partten[3][3] = 3'b111;
	matrix_number_partten[3][4] = 3'b001;
	matrix_number_partten[3][5] = 3'b111;

	matrix_number_partten[4][0] = 3'b101;
	matrix_number_partten[4][1] = 3'b101;
	matrix_number_partten[4][2] = 3'b101;
	matrix_number_partten[4][3] = 3'b111;
	matrix_number_partten[4][4] = 3'b001;
	matrix_number_partten[4][5] = 3'b001;

	matrix_number_partten[5][0] = 3'b111;
	matrix_number_partten[5][1] = 3'b100;
	matrix_number_partten[5][2] = 3'b111;
	matrix_number_partten[5][3] = 3'b001;
	matrix_number_partten[5][4] = 3'b101;
	matrix_number_partten[5][5] = 3'b111;

	matrix_number_partten[6][0] = 3'b111;
	matrix_number_partten[6][1] = 3'b100;
	matrix_number_partten[6][2] = 3'b111;
	matrix_number_partten[6][3] = 3'b101;
	matrix_number_partten[6][4] = 3'b101;
	matrix_number_partten[6][5] = 3'b111;

	matrix_number_partten[7][0] = 3'b111;
	matrix_number_partten[7][1] = 3'b101;
	matrix_number_partten[7][2] = 3'b101;
	matrix_number_partten[7][3] = 3'b001;
	matrix_number_partten[7][4] = 3'b001;
	matrix_number_partten[7][5] = 3'b001;

	matrix_number_partten[8][0] = 3'b111;
	matrix_number_partten[8][1] = 3'b101;
	matrix_number_partten[8][2] = 3'b111;
	matrix_number_partten[8][3] = 3'b101;
	matrix_number_partten[8][4] = 3'b101;
	matrix_number_partten[8][5] = 3'b111;

	matrix_number_partten[9][0] = 3'b111;
	matrix_number_partten[9][1] = 3'b101;
	matrix_number_partten[9][2] = 3'b111;
	matrix_number_partten[9][3] = 3'b001;
	matrix_number_partten[9][4] = 3'b101;
	matrix_number_partten[9][5] = 3'b111;

	matrix_s_partten[0] = 3'b000;
	matrix_s_partten[1] = 3'b111;
	matrix_s_partten[2] = 3'b100;
	matrix_s_partten[3] = 3'b010;
	matrix_s_partten[4] = 3'b001;
	matrix_s_partten[5] = 3'b111;

	matrix_apple_partten_r[0] = 5'b00000;
	matrix_apple_partten_r[1] = 5'b01010;
	matrix_apple_partten_r[2] = 5'b01110;
	matrix_apple_partten_r[3] = 5'b11111;
	matrix_apple_partten_r[4] = 5'b11111;
	matrix_apple_partten_r[5] = 5'b01110;

	matrix_apple_partten_g[0] = 5'b00011;
	matrix_apple_partten_g[1] = 5'b00100;
	matrix_apple_partten_g[2] = 5'b00000;
	matrix_apple_partten_g[3] = 5'b00000;
	matrix_apple_partten_g[4] = 5'b00000;
	matrix_apple_partten_g[5] = 5'b00000;
end

always @(posedge clk) begin
	if (cnt_scan >= 5_000_000) begin
		cnt_scan <= 0;
		clk_500ms <= ~clk_500ms;
	end else begin
		cnt_scan <= cnt_scan + 1;
	end

	if (cnt_1s >= 10_000_000) begin
		cnt_1s <= 0;
		clk_1000ms <= ~clk_1000ms;
	end else begin
		cnt_1s <= cnt_1s + 1;
	end

	// cnt_beat <= cnt_beat + 1;
	// if (cnt_scan == 2_500_000) begin
	// 	cnt_beat <= 0;
	// 	if (beat < 16'd9) begin
	// 		beat <= beat + 1;
	// 	end else begin
	// 		beat <= 0;
	// 	end
	// end
end

// always @(posedge clk) begin
// 	if (cnt_buzzer >= (10_000_000 / feq)) begin
// 		cnt_buzzer <= 0;
// 		buzzer <= ~buzzer;
// 	end else begin
// 		cnt_buzzer <= cnt_buzzer + 1;
// 	end
// end

// always @(beat) begin
// 	feq <= sheet[beat];
// end

always @(posedge clk_1000ms or negedge reset) begin
	if (!reset) begin
		timer <= 12'd0;
	end else if (stage == 2'd0) begin
		timer = timer + 1;
		// packed decimal
		if (timer[3:0] > 4'd9) begin
			timer = timer + 12'h6;
		end
		if (timer[7:4] > 4'd9) begin
			timer = timer + 12'h60;
		end
		if (timer[11:8] > 4'd9) begin
			timer = timer + 12'h600;
		end
	end
end

// reg[7:0] random_a;
reg apple_placed;
reg [5:0] position;
always @(posedge clk_500ms or negedge reset or negedge test) begin
	if (!reset) begin
		score = 12'd0;
		stage <= 2'd0;
		roll <= 8'd8;
		dire <= 2'd1;
		snake[0] = 6'b000_000;
		snake_length <= 8'd1;
		apple <= 6'b011_100;  // initial apple at row 3, column 4
	end else if (!test) begin
		stage <= 2'd2;
	end else if (stage != 2'd0) begin
		if (roll >= (8'd32 + result_matrix_length - 8'd1)) begin
			roll <= 8'd0;
		end else begin
			roll <= roll + 1;
		end
	end else begin
		// 500ms

		// move body
		for (i = 63; i > 0; i = i - 1) begin
			snake[i] = snake[i - 1];
		end

		// move head
		dire <= arrow;
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
				snake_on_map[snake[i][5:3]] = snake_on_map[snake[i][5:3]] | 8'b10000000 >> snake[i][2:0];
			end
		end
		// check if head is on the body
		if ((snake_on_map[snake[0][5:3]] & (8'b10000000 >> snake[0][2:0])) != 8'b0) begin
			// the snake's head hit body
			// TODO: i just reset everything for now, maybe we can
			// add some cool effect and then reset

			stage <= 2'd1;
		end else begin
			snake_on_map[snake[0][5:3]] = snake_on_map[snake[0][5:3]] | 8'b10000000 >> snake[0][2:0];

			if (snake[0][5:0] == apple[5:0]) begin
				score = score + 1;
				// packed decimal
				if (score[3:0] > 4'd9) begin
					score = score + 12'h6;
				end
				if (score[7:4] > 4'd9) begin
					score = score + 12'h60;
				end
				if (score[11:8] > 4'd9) begin
					score = score + 12'h600;
				end
				
				if (snake_length >= 8'd64) begin
					stage <= 2'd2;
				end else begin
					// grow the snake
					snake_on_map[snake[snake_length][5:3]] = snake_on_map[snake[snake_length][5:3]] | 8'b10000000 >> snake[snake_length][2:0];
					snake_length <= snake_length + 8'd1;

					// gen apple
					random = random ^ seed;
					if (random == 8'b0) begin
						random = 8'd234;
					end
					random = random ^ (random << 12) ^ (random >> 7) ^ (random << 3);
					
					apple_placed = 0;
					for (i = 0; i < 64; i = i + 1) begin
						position = random + i * 39;
						if (!apple_placed && (snake_on_map[position[5:3]] & (8'b01 << position[2:0])) == 8'b0) begin
							apple_placed = 1;
							apple[5:0] <= position;
						end
					end

					// TODO: i think this will be more randomized, but it seems to take too much hardware resources
					// random_a = random % (64 - snake_length - 1) + 1;
					// for (i = 0; i < 64; i = i + 1) begin
					// 	if (random_a != 8'b0 && (snake_on_map[i / 8] & (8'b01 << (i & 8'b0111 /* i % 8*/))) == 8'b0) begin
					// 		random_a = random_a - 1;
					// 		if (random_a == 8'b0) begin
					// 			apple[5:0] <= i[5:0];
					// 			// apple[5:3] = i / 8;  // random row (0-7)
					// 			// apple[2:0] = i % 8;  // random column (0-7)
					// 		end
					// 	end
					// end
				end
			end
		end
	end
end

always @(negedge reset or negedge arrow_up or negedge arrow_down or posedge arrow_left or posedge arrow_right) begin
	seed <= seed ^ cnt_scan[7:0];
	if (!reset) begin
		arrow <= 2'd1;
	end else if (!arrow_up) begin
		if (dire != 2'd1)
			arrow <= 2'd0;
	end else if (!arrow_down) begin
		if (dire != 2'd0)
			arrow <= 2'd1;
	end else if (arrow_left) begin
		if (dire != 2'd3)
			arrow <= 2'd2;
	end else if (arrow_right) begin
		if (dire != 2'd2)
			arrow <= 2'd3;
	end
end

always @(stage) begin
	if (stage != 2'd0) begin
		for (i = 0; i < 8; i = i + 1) begin
			result_matrix_r[i] = 48'b0;
			result_matrix_g[i] = 48'b0;
		end
		// result_matrix_r[0] = 48'hFFFF_FFFF_FFFF;
		result_matrix_length = 8'd0;

		result_matrix_length = result_matrix_length + 8'd2;
		if ((timer & 12'b1111_1110_0000) != 16'b0) begin
			result_matrix_length = result_matrix_length + 8'd4;
			for (i = 1; i < 7; i = i + 1) begin
				result_matrix_r[i] = result_matrix_r[i] | (matrix_number_partten[timer[11:8]][i - 1] << (48 - result_matrix_length));
			end
		end
		if ((timer & 12'b1111_1111_1000) != 16'b0) begin
			result_matrix_length = result_matrix_length + 8'd4;
			for (i = 1; i < 7; i = i + 1) begin
				result_matrix_r[i] = result_matrix_r[i] | (matrix_number_partten[timer[7:4]][i - 1] << (48 - result_matrix_length));
			end
		end
		result_matrix_length = result_matrix_length + 8'd4;
		for (i = 1; i < 7; i = i + 1) begin
			result_matrix_r[i] = result_matrix_r[i] | (matrix_number_partten[timer[3:0]][i - 1] << (48 - result_matrix_length));
		end
		result_matrix_length = result_matrix_length + 8'd5;
		for (i = 1; i < 7; i = i + 1) begin
			result_matrix_r[i] = result_matrix_r[i] | (matrix_s_partten[i - 1] << (48 - result_matrix_length));
		end

		result_matrix_length = result_matrix_length + 8'd4;
		if ((score & 12'b1111_1111_0000) != 16'b0) begin
			result_matrix_length = result_matrix_length + 8'd4;
			for (i = 1; i < 7; i = i + 1) begin
				result_matrix_r[i] = result_matrix_r[i] | (matrix_number_partten[score[11:8]][i - 1] << (48 - result_matrix_length));
			end
		end
		if ((score & 12'b1111_1111_1100) != 16'b0) begin
			result_matrix_length = result_matrix_length + 8'd4;
			for (i = 1; i < 7; i = i + 1) begin
				result_matrix_r[i] = result_matrix_r[i] | (matrix_number_partten[score[7:4]][i - 1] << (48 - result_matrix_length));
			end
		end
		result_matrix_length = result_matrix_length + 8'd4;
		for (i = 1; i < 7; i = i + 1) begin
			result_matrix_r[i] = result_matrix_r[i] | (matrix_number_partten[score[3:0]][i - 1] << (48 - result_matrix_length));
		end
		for (i = 1; i < 7; i = i + 1) begin
			result_matrix_g[i] = result_matrix_r[i];
		end

		result_matrix_length = result_matrix_length + 8'd7;
		for (i = 1; i < 7; i = i + 1) begin
			result_matrix_r[i] = result_matrix_r[i] | (matrix_apple_partten_r[i - 1] << (48 - result_matrix_length));
			result_matrix_g[i] = result_matrix_g[i] | (matrix_apple_partten_g[i - 1] << (48 - result_matrix_length));
		end

		result_matrix_length = result_matrix_length + 8'd2;
	end
end

always @(cnt_scan[15:13]) begin
	// led
	if (cnt_scan[15:13] < 3'd6) begin
		led_scanout <= cnt_scan[15:13];
	end else begin
		led_scanout <= 3'b0;
	end
	case (cnt_scan[15:13])
		3'd0: begin
			led_segout <= led_pattern[timer[11:8]];
		end
		3'd1: begin
			led_segout <= led_pattern[timer[7:4]];
		end
		3'd2: begin
			led_segout <= led_pattern[timer[3:0]];
		end
		3'd3: begin
			led_segout <= led_pattern[score[11:8]];
		end
		3'd4: begin
			led_segout <= led_pattern[score[7:4]];
		end
		3'd5: begin
			led_segout <= led_pattern[score[3:0]];
		end
		default: begin
			led_segout <= 8'b0;
		end
	endcase

	row = cnt_scan[15:13];
	matrix_scanout <= 8'b00000001 << row;

	case (stage)
		2'd0: begin
			// show snake
			if (snake[0][5:3] == row) begin
				matrix_segout_r = 8'b10000000 >> snake[0][2:0];
			end else begin
				matrix_segout_r = 8'b00000000;
			end
			matrix_segout_g = snake_on_map[row];

			// show apple
			if (row == apple[5:3]) begin
				matrix_segout_r = matrix_segout_r | 8'b10000000 >> apple[2:0];
			end
		end
		2'd1: begin
			if (roll <= 8'd32) begin
				matrix_segout_r = lose_matrix_start_r[row] >> (8'd32 - roll);
				matrix_segout_g = lose_matrix_start_g[row] >> (8'd32 - roll);
			end else begin
				matrix_segout_r = lose_matrix_start_r[row] << (roll - 8'd32);
				matrix_segout_g = lose_matrix_start_g[row] << (roll - 8'd32);
			end
			matrix_segout_r = matrix_segout_r | result_matrix_r[row] >> (8'd48 + 8'd32 - roll);
			matrix_segout_g = matrix_segout_g | result_matrix_g[row] >> (8'd48 + 8'd32 - roll);

			if (roll < 8'd8) begin
				matrix_segout_r = matrix_segout_r | (result_matrix_r[row] >> (8'd48 - result_matrix_length)) << roll;
				matrix_segout_g = matrix_segout_g | (result_matrix_g[row] >> (8'd48 - result_matrix_length)) << roll;
			end
		end
		2'd2: begin
			if (roll <= 8'd32) begin
				matrix_segout_r = win_matrix_start_r[row] >> (8'd32 - roll);
				matrix_segout_g = win_matrix_start_g[row] >> (8'd32 - roll);
			end else begin
				matrix_segout_r = win_matrix_start_r[row] << (roll - 8'd32);
				matrix_segout_g = win_matrix_start_g[row] << (roll - 8'd32);
			end
			matrix_segout_r = matrix_segout_r | result_matrix_r[row] >> (8'd48 + 8'd32 - roll);
			matrix_segout_g = matrix_segout_g | result_matrix_g[row] >> (8'd48 + 8'd32 - roll);

			if (roll < 8'd8) begin
				matrix_segout_r = matrix_segout_r | (result_matrix_r[row] >> (8'd48 - result_matrix_length)) << roll;
				matrix_segout_g = matrix_segout_g | (result_matrix_g[row] >> (8'd48 - result_matrix_length)) << roll;
			end
		end
	endcase
end

autoPlay play(reset, clk, note_index);
toneTable toneOut(note_index, tone);
toneOut speeker(clk, tone, buzzer, music_enable);

endmodule
