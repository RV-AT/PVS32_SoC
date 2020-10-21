`timescale 10ns/1ns
module PORT8080_TB;
  reg CLK,RST,EN;
  reg [7:0]IN;
  reg [7:0]datain;
  reg [7:0]cmd;
  reg [2:0]func;
  wire OUT,busy,wr,rd,rs;
  wire [7:0]data_o;
  wire [7:0]dataout;
//  reg [5:0]count;
  port8080 u1(IN,data_o,wr,rd,rs,datain,dataout,cmd,func,EN,busy,CLK,RST);
  initial
  begin
    CLK=0;RST=0;IN=8'b0;datain=8'b0;cmd=8'haa;func=2'h1;EN=0;
    #10 RST=1;EN=1;
    #20 EN=0;
	#120 IN=8'hac;func=2'h2;EN=1;
	#130 EN=0;
	#240 datain=8'h5a; func=2'h3; EN=1;
	#250 EN=0;
	#360 $stop;
	
  end
  
  always #5 CLK=~CLK; 
  
  // always @(posedge CLK)
  // begin
    // count<=count+1;
    // if(count==6)
      // begin
        // EN<=1;
        // IN<={$random}%15;
        // count<=0;
      // end
    // else
      // begin
       // EN<=0; 
      // end
      
  // end
  //initial $monitor ($time,,,"CLK=%b RST=%b out=%d",CLK,RST,OUT);
  
endmodule