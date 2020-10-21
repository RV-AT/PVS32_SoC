/*
all input ports like data_i , data_o are the inputs or outputs for the cpu
eg: data_p_i is the bus for io part output to the cpu
*/

module bus_martix(
// 对cpu的信号
input [31:0]addr_cpu,
input [31:0]data_o_cpu,
output [31:0]data_i_cpu,
input rd_n_cpu,
input wr_n_cpu,
input h32,
input h24,
input l16,
input l8,
output rdy_cpu,
output acc_fault,

//对ROM的信号
input [31:0]data_rom,
output [11:0]addr,
input rdy_rom,

//对RAM的信号
output [7:0]data_ram0_o,
output [7:0]data_ram1_o,
output [7:0]data_ram2_o,
output [7:0]data_ram3_o,
input [7:0]data_ram0_i,
input [7:0]data_ram1_i,
input [7:0]data_ram2_i,
input [7:0]data_ram3_i,
output[9:0]addr_ram,
output wr_ram0,
output wr_ram1,
output wr_ram2,
output wr_ram3,
input rdy_ram,

//对定时器的信号
input [31:0]mtimerh_i,
input [31:0]mtimerl_i,
input [31:0]mtimecmph_i,
input [31:0]mtimecmpl_i,

output wrtimeh_n,
output wrtimel_n,
output wrtimecmph_n,
output wrtimecmpl_n,

//对P口的信号
input [31:0]data_p_i,
output[31:0]data_p_o,

output rd_n_p,
output wr_n_p,

output h32_p,
output h24_p,
output l16_p,
output l8_p

);



//处理器口赋值
assign data_i_cpu = ((addr_cpu[31:2]==30'h3fff_ffff) ? data_p_i : 32'b0) |                          //ROM
                    ((addr_cpu[31:14]==18'b0)? data_rom : 32'b0)         |
                    ((addr_cpu[31:13]==19'b0000_0000_0000_0000_101) ? {data_ram0_i,data_ram1_i,data_ram2_i,data_ram3_i} : 32'b0) |//RAM
                    ((addr_cpu[31:2]==30'h0000_3800) ? mtimerl_i : 32'b0)|  //timer
                    ((addr_cpu[31:2]==30'h0000_3801) ? mtimerh_i : 32'b0)|
                    ((addr_cpu[31:2]==30'h0000_3802) ? mtimecmpl_i : 32'b0) |
                    ((addr_cpu[31:2]==30'h0000_3803) ? mtimecmph_i : 32'b0) |
					((addr_cpu[31:2]==30'h0000_3803) ? mtimecmph_i : 32'b0));
                    
                  
                    
assign rdy_cpu    = ((addr_cpu[31:2]==30'h3fff_ffff) ? 1'b1     : 1'b0 )  |
                    ((addr_cpu[31:10]==20'b0)? rdy_rom  : 1'b0 )          |
                    ((addr_cpu[31:10]==20'h0000a)?rdy_ram : 1'b0 )        |
                    ((addr_cpu[31:4]==28'h0000e00)?1'b1 : 1'b0) ;
                    

//P口赋值                    
assign data_p_o = data_o_cpu;
assign h32_p    = (addr_cpu[31:2]==30'h3fff_ffff) ? h32 : 1'b0;
assign h24_p    = (addr_cpu[31:2]==30'h3fff_ffff) ? h24 : 1'b0;
assign l16_p    = (addr_cpu[31:2]==30'h3fff_ffff) ? l16 : 1'b0;
assign l8_p     = (addr_cpu[31:2]==30'h3fff_ffff) ? l8  : 1'b0;

assign rd_n_p   = (addr_cpu[31:2]==30'h3fff_ffff) ? rd_n_cpu : 1'b1;
assign wr_n_p   = (addr_cpu[31:2]==30'h3fff_ffff) ? wr_n_cpu : 1'b1;

//timer口赋值
assign wrtimeh_n    =(addr_cpu[31:2]==30'h0000_3801)?wr_n_cpu : 1'b1;
assign wrtimel_n    =(addr_cpu[31:2]==30'h0000_3800)?wr_n_cpu : 1'b1;
assign wrtimecmph_n =(addr_cpu[31:2]==30'h0000_3803)?wr_n_cpu : 1'b1;
assign wrtimecmpl_n =(addr_cpu[31:2]==30'h0000_3802)?wr_n_cpu : 1'b1;

//rom口赋值
assign addr     = (addr_cpu[31:14]==18'b0)?addr_cpu[13:2] : 8'b0;

assign acc_fault = 1'b0;

//ram口赋值
assign addr_ram =     addr_cpu[11:2] ;
assign data_ram0_o = data_o_cpu[7:0];
assign data_ram1_o = data_o_cpu[15:8];
assign data_ram2_o = data_o_cpu[23:16];
assign data_ram3_o = data_o_cpu[31:24];

assign wr_ram0 = ((addr_cpu[31:13]==19'b0000_0000_0000_0000_101) & h32 & !wr_n_cpu) ;
assign wr_ram1 = ((addr_cpu[31:13]==19'b0000_0000_0000_0000_101) & h24 & !wr_n_cpu) ;
assign wr_ram2 = ((addr_cpu[31:13]==19'b0000_0000_0000_0000_101) & l16 & !wr_n_cpu) ;
assign wr_ram3 = ((addr_cpu[31:13]==19'b0000_0000_0000_0000_101) & l8  & !wr_n_cpu) ;



/*
//系统化总的总线控制信号
wire rd_n;
wire wr_n;
wire h32;
wire h24;
wire l16;
wire l8;
//系统总的访问失败信号
wire acc_fault;
//系统总rdy信号
wire rdy;
//系统总int信号
wire int;

wire [31:0]data_i;
wire [31:0]data_o;
wire [31:0]addr_in;
//程序储存器数据总线
reg  rdy_rom;
wire [31:0]data_rom;

assign addr = (addr_in[31:8]==24'hffffff) ? addr_in[7:0] : 8'b0; 

//内部处理器输入数据总线赋值
assign data_i = rd_n ? 32'b0 : (addr_in[31:11]==21'b0) ? data_rom : (addr_in[31:8]==24'hffffff) ? data : 32'b0;

//外部数据总线赋值
assign data = wr_n ? 32'bz :(addr_in[31:8]==24'hffffff) ? data_o : 32'bz;

//外部总线控制信号赋值
assign rd_n_o = (addr_in[31:8]==24'hffffff) ? rd_n : 1'b1;
assign wr_n_o = (addr_in[31:8]==24'hffffff) ? wr_n : 1'b1;
assign h32_o  = (addr_in[31:8]==24'hffffff) ? h32  : 1'b1;
assign h24_o  = (addr_in[31:8]==24'hffffff) ? h24  : 1'b1;
assign l16_o  = (addr_in[31:8]==24'hffffff) ? l16  : 1'b1;
assign l8_o   = (addr_in[31:8]==24'hffffff) ? l8   : 1'b1;

//总的int进行裁决
assign int = int_o;

assign acc_fault = (addr_in[31:8]==24'hffffff) ? acc_fault_o   : 1'b0;


assign rdy    = (wr_n & rd_n) ? 1'b0 : (addr_in[31:8]==24'hffffff) ? rdy_o : (addr_in[31:8]==24'h000000) ? rdy_rom : 1'b0;
*/
endmodule
