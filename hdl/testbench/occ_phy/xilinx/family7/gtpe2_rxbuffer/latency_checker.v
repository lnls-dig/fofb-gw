module latency_checker #
(
  parameter g_IDLE                = 16'hbc95,
  parameter g_IDLE_K              = 2'b10,
  parameter g_IDLE_PERIOD         = 193,
  parameter g_BLIND_PERIOD        = 10,
  parameter g_NUM_SUCCESFUL_DATA  = 1000
)
(
  output wire       fail_o,
  input wire        usrclk_i,
  input wire        valid_i,
  input wire [15:0] rx_data_i,
  input wire [1:0]  rx_k_i,
  output reg [15:0] tx_data_o,
  output reg [1:0]  tx_k_o,
  output reg        rx_realign_o,
  input wire        rx_aligned_i,
  input wire [2:0]  rx_bufstatus_i,
  output reg [15:0] latency_min_o = 2**16-1,
  output reg [15:0] latency_max_o = 0
);

  reg     right_comma_byte = 0;
  integer cnt_blind = 0;
  integer cnt_succesful_data = 0;

  reg [15:0] latency;
  reg [15:0] current_time;
  reg [15:0] cnt_idle = 0;

  reg [31:0] cnt_clk_correction = 0;

  reg fail_comma = 0;
  reg fail_data = 1;
  reg fail_buffer_limit = 0;
  reg fail_clk_correction = 0;

  // Data generation
  always @(posedge usrclk_i) begin
    // Send timestamps on TX data in order to allow for latency calculation
    current_time <= $time % 2**16;

    // Interleave with IDLE words for comma alignment and clock correction
    cnt_idle <= cnt_idle + 1;
    if (!valid_i || cnt_idle % g_IDLE_PERIOD == 0) begin
      tx_k_o <= g_IDLE_K;
      tx_data_o <= g_IDLE;
    end
    else begin
      tx_k_o <= 2'b00;
      tx_data_o <= current_time;
    end
  end

  // Validation
  assign fail_o = fail_comma || fail_data || fail_buffer_limit || fail_clk_correction;

  always @(posedge usrclk_i) begin
    rx_realign_o <= valid_i && rx_aligned_i == 0;

    if (rx_aligned_i == 1) begin
      if (cnt_blind > g_BLIND_PERIOD) begin
        // The blind period is used to ignore the first cycles after the GT
        // signals comma alignment has been achieved. For instance, for GTP
        // UG482 is not clear about how many clock cycles it takes for data
        // coming out at the rxdata/rxcharisk ports are guaranteed to be
        // already effected by the perfomed alignment.
        if (rx_k_i == 2'b00) begin
          if (right_comma_byte == 1) begin
            // Data is byte-aligned - Receiveing payload
            // right_comma_byte == 1 assures the comma byte alignment have been
            // already performed
            latency = current_time - rx_data_i;
            cnt_succesful_data = cnt_succesful_data + 1;

            // Latency statistics
            if (latency > latency_max_o) latency_max_o = latency;
            if (latency < latency_min_o) latency_min_o = latency;        

            if (cnt_succesful_data > g_NUM_SUCCESFUL_DATA) begin
              fail_data <= 0;
            end
          end
        end
        else if (rx_k_i == g_IDLE_K && rx_data_i == g_IDLE) begin
          // Data is byte-aligned - Comma in the right byte of an IDLE word
          right_comma_byte = 1;
        end
        else begin
          // Data is not byte-aligned - Comma in the wrong byte of an IDLE word
          // or any non-expected K character in the data stream
          if (fail_comma == 0) $display("Wrong comma alignment. First detected at %d ns.", $time);
          fail_comma <= 1;
        end
      end
      cnt_blind = cnt_blind + 1;

      if (rx_bufstatus_i == 3'b110) begin
        $display("RX Elastic Buffer overflow at time %d ns.", $time);
        fail_buffer_limit <= 1; 
      end
      else if  (rx_bufstatus_i == 3'b101) begin
        $display("RX Elastic Buffer underflow at time %d ns.", $time);
        fail_buffer_limit <= 1;
      end

      // When RX buffer reaches a CLK_COR_MIN_LAT or CLK_COR_MAX_LAT limit,
      // the warning flag at rx_bufstatus_i must be cleared in at least
      // g_IDLE_PERIOD cycles of user clock
      if (cnt_clk_correction >= g_IDLE_PERIOD) begin
        if (rx_bufstatus_i == 3'b001 || rx_bufstatus_i == 3'b010) begin
          $display("Lack of clock correction around %d ns.", $time);
          fail_clk_correction <= 1;
        end
        cnt_clk_correction <= 0;
      end
      else if (cnt_clk_correction == 0) begin
        if (rx_bufstatus_i == 3'b001 || rx_bufstatus_i == 3'b010) begin
          cnt_clk_correction <= 1;
        end
      end
      else begin
        cnt_clk_correction <= cnt_clk_correction + 1;
        if (rx_bufstatus_i == 3'b000) begin
          cnt_clk_correction <= 0;
        end
      end
    end
    else begin
      fail_comma <= 0;
      fail_data <= 1;
      fail_buffer_limit <= 0;
      fail_clk_correction <= 0;
      cnt_blind = 0;
      right_comma_byte = 0;
    end
  end

endmodule
