module biu8(
//对外部总线的信号
inout [7:0]p,

//对内部总线的信号

input [7:0]data_o,

input wr_n,
input rd_n,

input en,

output  [7:0]data_i,
//控制寄存器选择信号
input sel


);

reg [7:0] data;

reg [7:0] data_p;



assign p = sel ? 8'bz : data_p; //sel=1: high z or input , sel=0 output 1/0

always@(negedge rd_n)begin
    data <= p;
   
  end
 
always@(posedge wr_n)begin
    data_p <= en ? data_o : data_p ;
    
  end
  
assign data_i = data;
 


 
endmodule   
        