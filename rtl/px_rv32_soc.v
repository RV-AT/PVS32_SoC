
//PRV32F0 MCU

module px_rv32_soc(
inout  [7:0]p0,
inout  [7:0]p1,
inout  [7:0]p2,

output wire [2:0]statu,
output wire [3:0]statu_biu,

output wire ext_int_acc_o,
output wire timer_int_acc_o,
output wire soft_int_acc_o,
output wire pc_jmp,

input wire clk,
input wire rst_n

);

wire rst;

reg rdy_rom;
reg rdy_ram;

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
wire timer_int;
wire soft_int;
wire ext_int;

//cpu的数据总线信号
wire [31:0]data_i;
wire [31:0]data_o;
wire [31:0]addr_in;

//rom的信号

wire [31:0]data_rom;
wire [11:0] addr_rom;

//RAM口的信号

wire [7:0]data_ram0_o;
wire [7:0]data_ram1_o;
wire [7:0]data_ram2_o;
wire [7:0]data_ram3_o;
wire [7:0]data_ram0_i;
wire [7:0]data_ram1_i;
wire [7:0]data_ram2_i;
wire [7:0]data_ram3_i;
wire [9:0]addr_ram;
wire wr_ram0;
wire wr_ram1;
wire wr_ram2;
wire wr_ram3;

//P口的信号
wire [31:0]data_p_i;
wire [31:0]data_p_o;

wire rd_n_p;
wire wr_n_p;

wire h32_p;
wire h24_p;
wire l16_p;
wire l8_p;

wire sel00;
wire sel01;
wire sel02;

//timer信号
wire [31:0]mtimer_o;
wire [31:0]mtimerh_i;
wire [31:0]mtimerl_i;

wire [31:0]mtimecmph_i;
wire [31:0]mtimecmpl_i;

wire wrtimeh_n;
wire wrtimel_n;
wire wrtimecmph_n;
wire wrtimecmpl_n;


assign test = addr_in;
assign test1 = timer_int;

assign soft_int = 1'b0;
assign ext_int  = 1'b0;

assign rst = !rst_n;

bus_martix bus_martix(

// 对cpu的信号
.addr_cpu       (addr_in),
.data_o_cpu     (data_o),
.data_i_cpu     (data_i),
.rd_n_cpu       (rd_n),
.wr_n_cpu       (wr_n),
.h32            (h32),
.h24            (h24),
.l16            (l16),
.l8             (l8),
.rdy_cpu        (rdy),
.acc_fault      (acc_fault),

//对ROM的信号
.data_rom       (data_rom),
.addr           (addr_rom),
.rdy_rom        (rdy_rom),

//对RAM的信号
.data_ram0_o    (data_ram0_o),
.data_ram1_o    (data_ram1_o),
.data_ram2_o    (data_ram2_o),
.data_ram3_o    (data_ram3_o),
.data_ram0_i    (data_ram0_i),
.data_ram1_i    (data_ram1_i),
.data_ram2_i    (data_ram2_i),
.data_ram3_i    (data_ram3_i),
.addr_ram       (addr_ram),
.wr_ram0        (wr_ram0),
.wr_ram1        (wr_ram1),
.wr_ram2        (wr_ram2),
.wr_ram3        (wr_ram3),
.rdy_ram        (rdy_ram),

//对定时器的信号
.mtimerh_i      (mtimerh_i),
.mtimerl_i      (mtimerl_i),
.mtimecmph_i    (mtimecmph_i),
.mtimecmpl_i    (mtimecmpl_i),

.wrtimeh_n      (wrtimeh_n),
.wrtimel_n      (wrtimel_n),
.wrtimecmph_n   (wrtimecmph_n),
.wrtimecmpl_n   (wrtimecmpl_n),


//对P口的信号
.data_p_i       (data_p_i),
.data_p_o       (data_p_o),
 
.rd_n_p         (rd_n_p),
.wr_n_p         (wr_n_p),

.h32_p          (h32_p),
.h24_p          (h24_p),
.l16_p          (l16_p),
.l8_p           (l8_p)

);

mtime mtime(
.rst            (rst),
.clk            (clk),
.wrh_n          (wrtimeh_n),
.wrl_n          (wrtimel_n),

.mtimer_o       (data_o),


.mtimerh_i      (mtimerh_i),
.mtimerl_i      (mtimerl_i)

);

mtimecmp mtimecmp(
.clk            (clk),
.rst            (rst),
.wrh_n          (wrtimecmph_n),
.wrl_n          (wrtimecmpl_n),

.mtime          ({mtimerh_i,mtimerl_i}),

.mtimecmp_o     (data_o),

.mtimecmph_i    (mtimecmph_i),
.mtimecmpl_i    (mtimecmpl_i),

.timer_int      (timer_int)

);

port_sel port_sel0(
.data_o         (data_p_o[31:24]),

.wr_n           (wr_n_p),
.rd_n           (rd_n_p),


.en             (h32_p),

.data_i         (data_p_i[31:24]),
.sel0           (sel00),
.sel1           (sel01),
.sel2           (sel02)

);


biu8 port0(
//对外部总线的信号
.p              (p0),

//对内部总线的信号

.data_i         (data_p_i[7:0]),

.wr_n           (wr_n_p),
.rd_n           (rd_n_p),

.en             (l8_p),

.data_o         (data_p_o[7:0]),
//控制寄存器选择信号
.sel            (sel00)

);

biu8 port1(
//对外部总线的信号
.p              (p1),

//对内部总线的信号

.data_i         (data_p_i[15:8]),

.wr_n           (wr_n_p),
.rd_n           (rd_n_p),

.en             (l16_p),

.data_o         (data_p_o[15:8]),
//控制寄存器选择信号
.sel            (sel01)

);
biu8 port2(
//对外部总线的信号
.p              (p2),

//对内部总线的信号

.data_i         (data_p_i[23:16]),

.wr_n           (wr_n_p),
.rd_n           (rd_n_p),

.en             (h24_p),

.data_o         (data_p_o[24:16]),
//控制寄存器选择信号
.sel            (sel02)

);




always@(posedge clk)begin
    rdy_rom <= rst ? 1'b0 : rd_n ? 1'b0 : 1'b1;
    rdy_ram <= rst ? 1'b0 : (rd_n & wr_n) ? 1'b0 : 1'b1;
end

rom rom(

.address    (addr_rom),
.q          (data_rom),
.clock      (clk)

);

ram ram_0(
.address    (addr_ram),
.q          (data_ram0_i),
.data       (data_ram0_o),
.wren       (wr_ram0),
.clock      (clk)

);
ram ram_1(
.address    (addr_ram),
.q          (data_ram1_i),
.data       (data_ram1_o),
.wren       (wr_ram1),
.clock      (clk)

);
ram ram_2(
.address    (addr_ram),
.q          (data_ram2_i),
.data       (data_ram2_o),
.wren       (wr_ram2),
.clock      (clk)

);
ram ram_3(
.address    (addr_ram),
.q          (data_ram3_i),
.data       (data_ram3_o),
.wren       (wr_ram3),
.clock      (clk)

);


px_rv32 px_rv32(


.clk        (clk),

.rst        (rst),
//数据准备好信号
.rdy        (rdy),
//访问失败信号
.acc_fault  (acc_fault),
//总线信号
.data_i     (data_i),
.data_o     (data_o),

.addr       (addr_in),

.rd_n       (rd_n),

.wr_n       (wr_n),

.l8         (l8),

.l16        (l16),

.h24        (h24),

.h32        (h32),

.timer_int  (timer_int),

.soft_int   (soft_int),

.ext_int    (ext_int),

//机器状态信号输出
.statu      (statu),

.statu_biu  (statu_biu),

.timer_int_acc_o    (timer_int_acc_o),
.ext_int_acc_o      (ext_int_acc_o),
.soft_int_acc_o     (soft_int_acc_o),

.pc_jmp             (pc_jmp)

);

endmodule



