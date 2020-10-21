`timescale 10ns/1ns
module UART_IP_TB();
wire LOOP,TxBusy,RxError,INT,ACK;
wire [7:0]RXD;
reg clk,rst,SEND;
reg [7:0]TX;
UART_IP u1(clk,rst,8'b11110111,16'd64,SEND,LOOP,LOOP,TX,RXD,TxBusy,RxError,INT,ACK);
initial
  begin
    clk=0;rst=0;SEND=0;TX<=0;
    #10 rst=1;
	#20 rst=0;
  end
  always #5 clk=~clk; 
  always #15000  SEND=~SEND;
	always @(posedge SEND)TX<=$random(); 
endmodule
