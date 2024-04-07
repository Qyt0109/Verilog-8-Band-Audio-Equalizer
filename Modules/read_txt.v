`timescale 1ns / 1ps

module tb ();

  reg [15:0] A[0:15];  //memory declaration for storing the contents of file.
  integer outfile_d, outfile_b, outfile_h;  //file descriptors
  integer i;  //index used in "for" loop

  initial begin
    //read the contents of the file A_hex.txt as hexadecimal values into memory "A".
    $readmemb("i_tft.txt", A);  // $readmemh $readmemb
    //The $fopen function opens a file and returns a multi-channel descriptor 
    //in the format of an unsized integer.
    outfile_d = $fopen("o_tft_d.txt", "w");
    outfile_b = $fopen("o_tft_b.txt", "w");
    outfile_h = $fopen("o_tft_h.txt", "w");

    //Write one by one the contents of vector "A" into text files.
    for (i = 0; i < 16; i = i + 1) begin
      $fdisplay(outfile_d, "%d", A[i]);  //write as decimal
      $fdisplay(outfile_b, "%b", A[i]);  //write as binary
      $fdisplay(outfile_h, "%h", A[i]);  //write as hexadecimal
    end
    //once writing is finished, close all the files.
    $fclose(outfile_d);
    $fclose(outfile_b);
    $fclose(outfile_h);
    //wait and then stop the simulation.
    #100;
    $finish;
  end
endmodule
