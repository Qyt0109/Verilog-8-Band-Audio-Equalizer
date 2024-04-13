// python compile.py filter filter.v counter.v delay_pipeline.v amplifier.v coeffs.v compute.v

`timescale 1 ns / 1 ns

module equalizer_tb;
  localparam MAX_ADDRESS_BITS = 20;

  //localparam MAX_ADDRESS = 300;
  //localparam INPUT_TXT = "./Test8Band/impulse.txt";

  localparam MAX_ADDRESS = 2000 - 1;
  // localparam INPUT_TXT = "./Test8Band/tft.txt";
  localparam INPUT_TXT = "./Test8Band/test.txt";

  task filter_in_data_log_task;
    input clk;
    input reset;
    input rdenb;
    inout [MAX_ADDRESS_BITS-1:0] addr;
    output done;
    begin

      // Counter to generate the address
      if (reset == 1) addr = 0;
      else begin
        if (rdenb == 1) begin
          if (addr == MAX_ADDRESS) addr = addr;
          else begin
            addr = addr + 1;
            if ((addr % 100) == 0) begin
              $display("%d/100\n", addr * 100 / MAX_ADDRESS);
            end
          end
        end
      end

      // Done Signal generation.
      if (reset == 1) done = 0;
      else if (addr == MAX_ADDRESS) done = 1;
      else done = 0;

    end
  endtask  // filter_in_data_log_task

  task filter_out_task;
    input clk;
    input reset;
    input rdenb;
    inout [MAX_ADDRESS_BITS-1:0] addr;
    output done;
    begin

      // Counter to generate the address
      if (reset == 1) addr = 0;
      else begin
        if (rdenb == 1) begin
          if (addr == MAX_ADDRESS) addr = addr;
          else addr = #1 addr + 1;
        end
      end

      // Done Signal generation.
      if (reset == 1) done = 0;
      else if (addr == MAX_ADDRESS) done = 1;
      else done = 0;

    end
  endtask  // filter_out_task

  // Constants
  parameter clk_high = 10;
  parameter clk_low = 10;
  parameter clk_period = 20;
  parameter clk_hold = 2;


  reg signed [15:0] filter_in_data_log_force[0:MAX_ADDRESS];
  reg signed [15:0] filter_out_expected[0:MAX_ADDRESS];

  initial  //Input & Output data
    begin
      $dumpfile("./Test8Band/test_8band.vcd");
      $dumpvars;
      // Input data for filter_in_data_log
      $readmemb(INPUT_TXT, filter_in_data_log_force);
    end

  integer infile_txt;  //file descriptors
  integer outfile_filter_out;
  integer outfile_lpf_1000hz;
  integer outfile_bpf_1000hz2000hz;
  integer outfile_bpf_2000hz3000hz;
  integer outfile_bpf_3000hz4000hz;
  integer outfile_bpf_4000hz5000hz;
  integer outfile_bpf_5000hz6000hz;
  integer outfile_bpf_6000hz7000hz;
  integer outfile_hpf_7000hz;

  initial begin
    outfile_filter_out = $fopen("./Test8Band/output_txt/o_filter_out.txt", "w");
    outfile_lpf_1000hz = $fopen("./Test8Band/output_txt/o_lpf_1000hz.txt", "w");
    outfile_bpf_1000hz2000hz = $fopen("./Test8Band/output_txt/o_bpf_1000hz2000hz.txt", "w");
    outfile_bpf_2000hz3000hz = $fopen("./Test8Band/output_txt/o_bpf_2000hz3000hz.txt", "w");
    outfile_bpf_3000hz4000hz = $fopen("./Test8Band/output_txt/o_bpf_3000hz4000hz.txt", "w");
    outfile_bpf_4000hz5000hz = $fopen("./Test8Band/output_txt/o_bpf_4000hz5000hz.txt", "w");
    outfile_bpf_5000hz6000hz = $fopen("./Test8Band/output_txt/o_bpf_5000hz6000hz.txt", "w");
    outfile_bpf_6000hz7000hz = $fopen("./Test8Band/output_txt/o_bpf_6000hz7000hz.txt", "w");
    outfile_hpf_7000hz = $fopen("./Test8Band/output_txt/o_hpf_7000hz.txt", "w");
  end

  // Signals

  reg tb_enb;  // boolean
  wire srcDone;  // boolean
  wire testFailure;  // boolean
  wire tbenb_dly;  // boolean
  reg int_delay_pipe[0:19];  // boolean
  reg [5:0] counter;  // ufix6
  wire phase_1;  // boolean
  wire rdEnb_phase_1;  // boolean
  wire filter_in_data_log_rdenb;  // boolean
  reg [MAX_ADDRESS_BITS-1:0] filter_in_data_log_addr;  // ufix7
  reg filter_in_data_log_done;  // boolean
  wire signed [15:0] rawData_filter_in;  // sfix16
  reg signed [15:0] holdData_filter_in;  // sfix16
  integer filter_out_errCnt;  // uint32
  wire delayLine_out;  // boolean
  wire expected_ce_out;  // boolean
  reg [MAX_ADDRESS_BITS-1:0] filter_out_addr;  // ufix7
  wire signed [15:0] filter_out_ref;  // sfix16
  wire signed [15:0] filter_out_dataTable;  // sfix16
  wire signed [15:0] filter_out_refTmp;  // sfix16
  reg signed [15:0] regout;  // sfix16


  parameter FILTER_IN_BITS = 16;
  parameter FILTER_OUT_BITS = 16;
  parameter NUMBER_OF_FILTERS = 8;
  parameter GAIN_BITS = 8;
  parameter GAIN_FRAC_BITS = 2;

  // Module Instances
  reg clk;  // boolean
  reg clk_enable;  // boolean
  reg rst;  // boolean
  reg amplifier_enable = 1;
  /* hpf_7000hz, bpf_6000hz7000hz,... , bpf_1000hz2000hz, lpf_1000hz */
  wire [NUMBER_OF_FILTERS*GAIN_BITS-1:0] amplifier_gains;

  wire [GAIN_BITS-1:0] amplifier_gain[0:NUMBER_OF_FILTERS];
  // gain 8.2 range [-32, 32 - 0.25]
  assign amplifier_gain[0] = (2 ** GAIN_FRAC_BITS) * 1;
  assign amplifier_gain[1] = (2 ** GAIN_FRAC_BITS) * 0;
  assign amplifier_gain[2] = (2 ** GAIN_FRAC_BITS) * 0;
  assign amplifier_gain[3] = (2 ** GAIN_FRAC_BITS) * 10.75;
  assign amplifier_gain[4] = (2 ** GAIN_FRAC_BITS) * 0;
  assign amplifier_gain[5] = (2 ** GAIN_FRAC_BITS) * 0;
  assign amplifier_gain[6] = (2 ** GAIN_FRAC_BITS) * 5;
  assign amplifier_gain[7] = (2 ** GAIN_FRAC_BITS) * 5;

  generate
    for (
        genvar amplifier_gain_index = 0;
        amplifier_gain_index < NUMBER_OF_FILTERS;
        amplifier_gain_index = amplifier_gain_index + 1
    ) begin
      assign amplifier_gains[(amplifier_gain_index+1)*GAIN_BITS-1:amplifier_gain_index*GAIN_BITS] = amplifier_gain[amplifier_gain_index];
    end
  endgenerate

  reg signed [15:0] filter_in;  // sfix16
  wire signed [15:0] filter_out;  // sfix16
  // TODO: Remove this region (TEST ONLY)
  wire signed [FILTER_OUT_BITS-1:0] filter_lpf_1000hz;
  wire signed [FILTER_OUT_BITS-1:0] filter_bpf_1000hz2000hz;
  wire signed [FILTER_OUT_BITS-1:0] filter_bpf_2000hz3000hz;
  wire signed [FILTER_OUT_BITS-1:0] filter_bpf_3000hz4000hz;
  wire signed [FILTER_OUT_BITS-1:0] filter_bpf_4000hz5000hz;
  wire signed [FILTER_OUT_BITS-1:0] filter_bpf_5000hz6000hz;
  wire signed [FILTER_OUT_BITS-1:0] filter_bpf_6000hz7000hz;
  wire signed [FILTER_OUT_BITS-1:0] filter_hpf_7000hz;
  // TODO: Remove this region (TEST ONLY)

  equalizer #(
      .FILTER_IN_BITS(FILTER_IN_BITS),
      .FILTER_OUT_BITS(FILTER_OUT_BITS),
      .NUMBER_OF_FILTERS(NUMBER_OF_FILTERS),
      .GAIN_BITS(GAIN_BITS),
      .GAIN_FRAC_BITS(GAIN_FRAC_BITS)
  ) uut (
      .clk(clk),
      .clk_enable(clk_enable),
      .rst(rst),
      .amplifier_enable(amplifier_enable),
      .amplifier_gains(amplifier_gains),
      .filter_in(filter_in),
      .filter_out(filter_out),
      // TODO: Remove this region (TEST ONLY)
      .filter_lpf_1000hz(filter_lpf_1000hz),
      .filter_bpf_1000hz2000hz(filter_bpf_1000hz2000hz),
      .filter_bpf_2000hz3000hz(filter_bpf_2000hz3000hz),
      .filter_bpf_3000hz4000hz(filter_bpf_3000hz4000hz),
      .filter_bpf_4000hz5000hz(filter_bpf_4000hz5000hz),
      .filter_bpf_5000hz6000hz(filter_bpf_5000hz6000hz),
      .filter_bpf_6000hz7000hz(filter_bpf_6000hz7000hz),
      .filter_hpf_7000hz(filter_hpf_7000hz)
      // TODO: Remove this region (TEST ONLY)
  );

  always @(posedge phase_1) begin
    $fdisplay(outfile_filter_out, "%b", filter_out);  //write as binary
    $fdisplay(outfile_lpf_1000hz, "%b", filter_lpf_1000hz);  //write as binary
    $fdisplay(outfile_bpf_1000hz2000hz, "%b", filter_bpf_1000hz2000hz);  //write as binary
    $fdisplay(outfile_bpf_2000hz3000hz, "%b", filter_bpf_2000hz3000hz);  //write as binary
    $fdisplay(outfile_bpf_3000hz4000hz, "%b", filter_bpf_3000hz4000hz);  //write as binary
    $fdisplay(outfile_bpf_4000hz5000hz, "%b", filter_bpf_4000hz5000hz);  //write as binary
    $fdisplay(outfile_bpf_5000hz6000hz, "%b", filter_bpf_5000hz6000hz);  //write as binary
    $fdisplay(outfile_bpf_6000hz7000hz, "%b", filter_bpf_6000hz7000hz);  //write as binary
    $fdisplay(outfile_hpf_7000hz, "%b", filter_hpf_7000hz);  //write as binary
  end


  // Block Statements
  // Driving the test bench enable
  wire snkDone;  // boolean
  always @(rst, snkDone) begin
    if (rst == 1'b1) tb_enb <= 1'b0;
    else if (snkDone == 1'b0) tb_enb <= 1'b1;
    else begin
      #(clk_period * 2);
      tb_enb <= 1'b0;
    end
  end

  always @(posedge clk or posedge rst) // completed_msg
  begin
    if (rst) begin
      // Nothing to reset.
    end else begin
      if (snkDone == 1) begin
        $display("TEST COMPLETED");
        $finish;
      end
    end
  end  // completed_msg;

  // System Clock (fast clock) and reset
  always  // clock generation
  begin // clk_gen
    clk <= 1'b1;
    #clk_high;
    clk <= 1'b0;
    #clk_low;
    if (snkDone == 1) begin
      clk <= 1'b1;
      #clk_high;
      clk <= 1'b0;
      #clk_low;
      $stop;
    end
  end  // clk_gen

  initial  // reset block
    begin  // rst_gen
      rst <= 1'b1;
      #(clk_period * 10);
      @(posedge clk);
      #(clk_hold);
      rst <= 1'b0;
    end  // rst_gen

  // Testbench clock enable
  localparam MAX_ADDRESS_int_delay_pipe = 19;
  integer int_delay_pipe_address;
  always @(posedge clk or posedge rst) begin : tb_enb_delay
    if (rst == 1) begin
      for (
          int_delay_pipe_address = 0;
          int_delay_pipe_address <= MAX_ADDRESS_int_delay_pipe;
          int_delay_pipe_address = int_delay_pipe_address + 1
      ) begin
        int_delay_pipe[int_delay_pipe_address] <= 0;
      end
    end else begin
      if (tb_enb == 1) begin
        int_delay_pipe[0] <= tb_enb;
        for (
            int_delay_pipe_address = 1;
            int_delay_pipe_address <= MAX_ADDRESS_int_delay_pipe;
            int_delay_pipe_address = int_delay_pipe_address + 1
        ) begin
          int_delay_pipe[int_delay_pipe_address] <= int_delay_pipe[int_delay_pipe_address-1];
        end
      end
    end
  end  // tb_enb_delay

  assign tbenb_dly = int_delay_pipe[19];

  // Slow Clock (clkenb)
  always @(posedge clk or posedge rst) begin : slow_clock_enable
    if (rst == 1'b1) begin
      counter <= 6'b000001;
    end else begin
      if (tbenb_dly == 1'b1) begin
        if (counter >= 6'b111111) begin
          counter <= 6'b000000;
        end else begin
          counter <= counter + 6'b000001;
        end
      end
    end
  end  // slow_clock_enable

  assign phase_1 = (counter == 6'b000001 && tbenb_dly == 1'b1) ? 1'b1 : 1'b0;

  assign rdEnb_phase_1 = phase_1;

  // Read the data and transmit it to the DUT
  always @(posedge clk or posedge rst) begin
    filter_in_data_log_task(clk, rst, filter_in_data_log_rdenb, filter_in_data_log_addr,
                            filter_in_data_log_done);
  end

  assign filter_in_data_log_rdenb = rdEnb_phase_1;

  assign rawData_filter_in = filter_in_data_log_force[filter_in_data_log_addr];

  always @(posedge clk or posedge rst) begin  // stimuli_filter_in_data_log_filter_in_reg
    if (rst) begin
      holdData_filter_in <= 16'bx;
    end else begin
      holdData_filter_in <= rawData_filter_in;
    end
  end

  always @ (filter_in_data_log_rdenb, filter_in_data_log_addr)
  begin // stimuli_filter_in_data_log_filter_in
    if (filter_in_data_log_rdenb == 1) begin
      filter_in <= #clk_hold rawData_filter_in;
    end else begin
      filter_in <= #clk_hold holdData_filter_in;
    end
  end  // stimuli_filter_in_data_log_filter_in

  // Create done signal for Input data

  assign srcDone = filter_in_data_log_done;

  localparam MAX_ADDRESS_int_delay_pipe_1 = 64;
  reg int_delay_pipe_1[0:MAX_ADDRESS_int_delay_pipe_1];  // boolean

  integer int_delay_pipe_1_address;

  always @(posedge clk or posedge rst) begin : ceout_delayLine
    if (rst == 1) begin
      for (
          int_delay_pipe_1_address = 0;
          int_delay_pipe_1_address <= MAX_ADDRESS_int_delay_pipe_1;
          int_delay_pipe_1_address = int_delay_pipe_1_address + 1
      ) begin
        int_delay_pipe_1[int_delay_pipe_1_address] <= 0;
      end
    end else begin
      if (clk_enable == 1'b1) begin
        int_delay_pipe_1[0] <= rdEnb_phase_1;
        for (
            int_delay_pipe_1_address = 1;
            int_delay_pipe_1_address <= MAX_ADDRESS_int_delay_pipe_1;
            int_delay_pipe_1_address = int_delay_pipe_1_address + 1
        ) begin
          int_delay_pipe_1[int_delay_pipe_1_address] <= int_delay_pipe_1[int_delay_pipe_1_address-1];
        end
      end
    end
  end  // ceout_delayLine

  assign delayLine_out   = int_delay_pipe_1[64];

  assign expected_ce_out = delayLine_out & clk_enable;

  //  Checker: Checking the data received from the DUT.
  reg  filter_out_done;  // boolean

  wire filter_out_rdenb;  // boolean

  always @(posedge clk or posedge rst) begin
    filter_out_task(clk, rst, filter_out_rdenb, filter_out_addr, filter_out_done);
  end

  assign filter_out_rdenb = expected_ce_out;

  assign #clk_hold filter_out_dataTable = filter_out_expected[filter_out_addr];

  // ---- Bypass Register ----
  always @(posedge clk or posedge rst) begin : DataHoldRegister_temp_process2
    if (rst == 1'b1) begin
      regout <= 0;
    end else begin
      if (expected_ce_out == 1'b1) begin
        regout <= filter_out_dataTable;
      end
    end
  end  // DataHoldRegister_temp_process2

  assign filter_out_refTmp = (expected_ce_out == 1'b1) ? filter_out_dataTable : regout;


  assign filter_out_ref = filter_out_refTmp;

  reg check1_Done;  // boolean

  always @ (posedge clk or posedge rst) // checkDone_1
  begin
    if (rst == 1) check1_Done <= 0;
    else if ((check1_Done == 0) && (filter_out_done == 1) && (filter_out_rdenb == 1))
      check1_Done <= 1;
  end

  // Create done and test failure signal for output data
  assign snkDone = check1_Done;

  // Global clock enable
  always @(snkDone, tbenb_dly) begin
    if (snkDone == 0) #clk_hold clk_enable <= tbenb_dly;
    else #clk_hold clk_enable <= 0;
  end

  // Assignment Statements



endmodule  // equalizer_tb
