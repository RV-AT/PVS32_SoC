module px_spi(

input clk,              //连接在处理器主时钟上
input rst,

input wr_n,
input rd_n,

input [7:0]data_t,
input [1:0]mode,        //SPI发送模式选择     

input [1:0]div_clk,     //SPI发送时钟选择

output reg[1:0]mode_out,
output reg[1:0]div_clk_out,

output[7:0]data_r,

output reg rdy              //准备好信号
);


always@(posedge wr_n)begin
    
       mode_out <= mode;
       div_clk_out <= div_clk;
       
end


endmodule
