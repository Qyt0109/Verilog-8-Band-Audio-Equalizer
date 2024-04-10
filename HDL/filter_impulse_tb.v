// python compile.py filter filter.v counter.v delay_pipeline.v coeffs.v compute.v filter_impluse_tb.v 

`timescale 1 ns / 1 ns

module filter_impluse_tb;
  localparam MAX_ADDRESS_filter_in_data_log = 1270;
  localparam MAX_ADDRESS_BIT_filter_in_data_log = 14;

  task filter_in_data_log_task;
    input clk;
    input reset;
    input rdenb;
    inout [MAX_ADDRESS_BIT_filter_in_data_log-1:0] addr;
    output done;
    begin

      // Counter to generate the address
      if (reset == 1) addr = 0;
      else begin
        if (rdenb == 1) begin
          if (addr == MAX_ADDRESS_filter_in_data_log) addr = addr;
          else addr = addr + 1;
        end
      end

      // Done Signal generation.
      if (reset == 1) done = 0;
      else if (addr == MAX_ADDRESS_filter_in_data_log) done = 1;
      else done = 0;

    end
  endtask  // filter_in_data_log_task

  localparam MAX_ADDRESS_filter_out = 1270;
  localparam MAX_ADDRESS_BIT_filter_out = 14;

  task filter_out_task;
    input clk;
    input reset;
    input rdenb;
    inout [MAX_ADDRESS_BIT_filter_out-1:0] addr;
    output done;
    begin

      // Counter to generate the address
      if (reset == 1) addr = 0;
      else begin
        if (rdenb == 1) begin
          if (addr == MAX_ADDRESS_filter_out) addr = addr;
          else addr = #1 addr + 1;
        end
      end

      // Done Signal generation.
      if (reset == 1) done = 0;
      else if (addr == MAX_ADDRESS_filter_out) done = 1;
      else done = 0;

    end
  endtask  // filter_out_task

  // Constants
  parameter clk_high = 5;
  parameter clk_low = 5;
  parameter clk_period = 10;
  parameter clk_hold = 2;


  reg signed [15:0] filter_in_data_log_force[0:MAX_ADDRESS_filter_in_data_log];
  reg [NUMBER_OF_FILTERS*GAIN_BITS-1:0] amplifier_gains_data_log_force[0:MAX_ADDRESS_filter_in_data_log];
  reg signed [15:0] filter_out_expected[0:MAX_ADDRESS_filter_out];


  integer filter_in_data_log_force_address;
  integer amplifier_gains_data_log_force_address;

  localparam IMPULSE_ADDRESS = 30;
  localparam IMPULSE_VALUE = 16'h7fff;
  integer infile_txt;  //file descriptors

  initial  //Input & Output data
    begin
      $dumpfile("./Test/test_impulse.vcd");
      $dumpvars;
      infile_txt = $fopen("./Test/i_impulse_bin.txt", "w");
      // Input data for filter_in_data_log
      for (
          filter_in_data_log_force_address = 0;
          filter_in_data_log_force_address < MAX_ADDRESS_filter_in_data_log;
          filter_in_data_log_force_address = filter_in_data_log_force_address + 1
      ) begin
        if (filter_in_data_log_force_address == IMPULSE_ADDRESS) begin
          filter_in_data_log_force[filter_in_data_log_force_address] = IMPULSE_VALUE;
        end else begin
          filter_in_data_log_force[filter_in_data_log_force_address] = 0;
        end
        $fdisplay(infile_txt, "%b",
                  filter_in_data_log_force[filter_in_data_log_force_address]);  //write as binary
      end

      for (
        amplifier_gains_data_log_force_address = 0;
        amplifier_gains_data_log_force_address < MAX_ADDRESS_filter_in_data_log/2;
        amplifier_gains_data_log_force_address = amplifier_gains_data_log_force_address + 1
      ) begin
        amplifier_gains_data_log_force[amplifier_gains_data_log_force_address] = {((NUMBER_OF_FILTERS*GAIN_BITS)/2){2'b01}};
      end

      for (
        amplifier_gains_data_log_force_address = MAX_ADDRESS_filter_in_data_log/2 + 1;
        amplifier_gains_data_log_force_address < MAX_ADDRESS_filter_in_data_log;
        amplifier_gains_data_log_force_address = amplifier_gains_data_log_force_address + 1
      ) begin
        amplifier_gains_data_log_force[amplifier_gains_data_log_force_address] = {((NUMBER_OF_FILTERS*GAIN_BITS)/2){2'b11}};
      end

    end

  integer outfile_txt;  //file descriptors
  initial begin
    outfile_txt = $fopen("./Test/o_impulse_bin.txt", "w");
  end

  always @(posedge phase_1) begin
    $fdisplay(outfile_txt, "%b", filter_out);  //write as binary
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
  reg [MAX_ADDRESS_BIT_filter_in_data_log-1:0] filter_in_data_log_addr;  // ufix7
  reg filter_in_data_log_done;  // boolean
  wire signed [15:0] rawData_filter_in;  // sfix16
  reg signed [15:0] holdData_filter_in;  // sfix16
  integer filter_out_errCnt;  // uint32
  wire delayLine_out;  // boolean
  wire expected_ce_out;  // boolean
  reg [MAX_ADDRESS_BIT_filter_out-1:0] filter_out_addr;  // ufix7
  wire signed [15:0] filter_out_ref;  // sfix16
  wire signed [15:0] filter_out_dataTable;  // sfix16
  wire signed [15:0] filter_out_refTmp;  // sfix16
  reg signed [15:0] regout;  // sfix16


  parameter FILTER_IN_BITS = 16;
  parameter FILTER_OUT_BITS = 16;
  parameter NUMBER_OF_FILTERS = 8;
  parameter GAIN_BITS = 2;

  // Module Instances
  reg clk;  // boolean
  reg clk_enable;  // boolean
  reg rst;  // boolean
  reg amplifier_enable = 1;
  reg [NUMBER_OF_FILTERS*GAIN_BITS-1:0] amplifier_gains;
  reg signed [15:0] filter_in;  // sfix16
  wire signed [15:0] filter_out;  // sfix16

  filter #(
    .FILTER_IN_BITS(FILTER_IN_BITS),
    .FILTER_OUT_BITS(FILTER_OUT_BITS),
    .NUMBER_OF_FILTERS(NUMBER_OF_FILTERS),
    .GAIN_BITS(GAIN_BITS)
  ) uut (
      .clk(clk),
      .clk_enable(clk_enable),
      .rst(rst),
      .amplifier_enable(amplifier_enable),
      .amplifier_gains(amplifier_gains),
      .filter_in(filter_in),
      .filter_out(filter_out)
  );


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



endmodule  // filter_impluse_tb
