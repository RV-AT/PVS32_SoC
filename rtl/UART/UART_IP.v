//UART Module @ 11.0592MHz
//Engineer:Hong,XiaoYu
//Company:ChengDu College of UESTC
//Mode select register:first 3 bit for Baud Rate,Odd Check Enable,TxEn,RxEn,INT Enable,module enable.
module UART_IP(clk,rst,mode,DIV,send,TxD,RxD,TxReg,RxReg,TxBusy,RxError,INT,ACK);
input clk,rst,send,RxD;
input [7:0]TxReg;
input [7:0]mode;
input [15:0]DIV;
output reg ACK;
output INT;
output TxD,TxBusy,RxError;
output [7:0]RxReg;
//reg TxSend;
//reg [7:0]ModeReg;
reg send_int;
wire BaudL,BaudOut,TINT,INT_R;
assign INT=TINT|INT_R;
always@(posedge send or posedge rst or negedge TxBusy)
begin
	if(rst)send_int<=0;
	else if(send&(!send_int))send_int<=1;
	else if(!TxBusy)send_int<=0;
	
end
BaudGen u2(DIV,mode[7],clk,rst,BaudOut,BaudL);
UART_Tx u3(BaudL,rst,mode[4],mode[3],send_int,TxReg,TxBusy,TINT,TxD);
UART_Rx u4(BaudOut,rst,mode[5],mode[3],RxD,RxReg,RxError,INT_R);
endmodule


