/*
=========================================================
|                Gu_Processor V0.0                      |
|                 Author:Jack Pan                       |
|             Date: 25th, May 2019 Sat                  |
|        gugugugugugugugugugugugugugugugugu~            |
|         GuTech (C) 2019 All right reserved            |
=========================================================
*/
/* GuTeck family 1 , Stepping 00 
Date: 4th, June 2019 
Signed number operating bug has been fixed 
*/
`include "./biu.v"
`include "./exu.v"
`include "./csr_gpr.v"
`include "./iu.v"
module px_rv32(

input wire clk,

input wire rst,
//数据准备好信号
input wire rdy,
//访问失败信号
input wire acc_fault,
//总线信号
input wire [31:0]data_i,

//中断信号
input  wire timer_int,
input  wire soft_int,
input  wire ext_int, 
output wire [31:0]data_o,

output wire [31:0]addr,

output wire rd_n,

output wire wr_n,

output wire l8,

output wire l16,

output wire h24,

output wire h32,

//机器状态信号输出
output wire [2:0]statu,

output wire [3:0]statu_biu,

output wire timer_int_acc_o,
output wire ext_int_acc_o,
output wire soft_int_acc_o,

output wire pc_jmp
);


//exu准备好信号
wire rdy_exu;
wire rdy_biu;

//指令输入
wire [31:0]ins;

//中断独热码输入(仲裁之后的）
//软件中断



//指令地址不对齐
wire ins_addr_mis;
//指令无法访问
wire ins_acc_fault;
//非法指令
wire ill_ins;

//载入的地址不对齐
wire addr_mis;
//载入错误
wire load_acc_fault;


//译码器结果输出
wire addi ;
wire slti;
wire sltiu;
wire andi;
wire ori;
wire xori;
wire slli;
wire srli;
wire srai;

wire lui;
wire auipc;
wire add_;
wire sub_;
wire slt_;
wire sltu_;
wire and_;
wire or_;
wire xor_;
wire sll_;
wire srl_;
wire sra_;

wire jal;
wire jalr;

wire beq;
wire bne;
wire blt;
wire bltu;
wire bge;
wire bgeu;

wire w8;
wire w16;
wire w32;
wire r8;
wire r16;
wire r32;
wire lb;
wire lh;
wire sorc_sel;

wire csrrw;
wire csrrs;
wire csrrc;
wire csrrwi;
wire csrrsi;
wire csrrci;

wire csr_rd_en;
wire csr_wr_en;
wire gpr_rd_en;
wire gpr_wr_en;

wire ebreak;
wire ecall;
wire ret;

wire [31:0]csr;
wire [31:0]rs1;
wire [31:0]rs2;
 
wire [4:0]rs1_index;
wire [4:0]rs2_index;
wire [4:0]rd_index;
wire [11:0]csr_index;


wire [19:0]imm20;
wire [11:0]imm12;
wire [4:0] shamt;


wire [31:0]addr_csr;

//控制信号输出

wire jmp;

//对内部信号
wire [31:0]addr_in;

wire [31:0]data_inside;

wire [31:0]data_biu;


wire [31:0]pc;




biu biu( 
    .clk        (clk),
    .rst        (rst),
    .data_i     (data_i),
    .data_o     (data_o),
    .rdy        (rdy),
    .acc_fault  (acc_fault),
    .addr       (addr),
    .rd_n       (rd_n),
    .wr_n       (wr_n),
    .l8         (l8),
    .l16        (l16),
    .h24        (h24),
    .h32        (h32),
    .addr_in    (addr_csr),
    .data_in    (data_inside),
    .statu      (statu),
    .pc         (pc),
    .w32        (w32),
    .w16        (w16),
    .w8         (w8),
    .r32        (r32),
    .r16        (r16),
    .r8         (r8),
    .ins        (ins),
    .data_out   (data_biu),
    .ins_addr_mis (ins_addr_mis),
    .ins_acc_fault(ins_acc_fault),
    .ill_ins      (ill_ins),
    .addr_mis   (addr_mis),
    .load_acc_fault(load_acc_fault),
    .rdy_biu    (rdy_biu),
    .statu_biu_out (statu_biu)
    
);

iu iu(
    .clk        (clk),
    .rst        (rst),
    .rdy_exu    (rdy_exu),
    .rdy_biu    (rdy_biu),
    .ins        (ins),
    .soft_int   (soft_int_acc_o),
    .timer_int  (timer_int_acc_o),
    .ext_int    (ext_int_acc_o),
    .ins_addr_mis   (ins_addr_mis),
    .ins_acc_fault  (ins_acc_fault),
    .ill_ins        (ill_ins),
    .addr_mis       (addr_mis),
    .load_acc_fault (load_acc_fault),
    .statu          (statu),
    .addi           (addi),
    .slti           (slti),
    .sltiu          (sltiu),
    .andi           (andi),
    .ori            (ori),
    .xori           (xori),
    .slli           (slli),
    .srli           (srli),
    .srai           (srai),
    .lui            (lui),
    .auipc          (auipc),
    .add_           (add_),
    .sub_           (sub_),
    .slt_           (slt_),
    .sltu_          (sltu_),
    .and_           (and_),
    .or_            (or_),
    .xor_           (xor_),
    .sll_           (sll_),
    .srl_           (srl_),
    .sra_           (sra_),
    .jal            (jal),
    .jalr           (jalr),
    .beq            (beq),
    .bne            (bne),
    .blt            (blt),
    .bltu           (bltu),
    .bge            (bge),
    .bgeu           (bgeu),
    .w8             (w8),
    .w16            (w16),
    .w32            (w32),
    .r8             (r8),
    .r16            (r16),
    .r32            (r32),
    .lb             (lb),
    .lh             (lh),
    .sorc_sel       (sorc_sel),
    .csrrw          (csrrw),
    .csrrs          (csrrs),
    .csrrc          (csrrc),
    .csrrwi         (csrrwi),
    .csrrsi         (csrrsi),
    .csrrci         (csrrci),
    .csr_rd_en      (csr_rd_en),
    .csr_wr_en      (csr_wr_en),
    .gpr_rd_en      (gpr_rd_en),
    .gpr_wr_en      (gpr_wr_en),
    .ebreak         (ebreak),
    .ecall          (ecall),
    .ret            (ret),
    .rs1_index      (rs1_index),
    .rs2_index      (rs2_index),
    .rd_index       (rd_index),
    .csr_index      (csr_index),
    .imm20          (imm20),
    .imm12          (imm12),
    .shamt          (shamt)

);
    
exu exu(
    .clk            (clk),
    .rst            (rst),
    .pc             (pc),
    .rs1            (rs1),
    .rs2            (rs2),
    .imm20          (imm20),
    .imm12          (imm12),
    .shamt          (shamt),
    .csr            (csr),
    .rs1_index      (rs1_index),
    .addi           (addi),
    .slti           (slti),
    .sltiu          (sltiu),
    .andi           (andi),
    .ori            (ori),
    .xori           (xori),
    .slli           (slli),
    .srli           (srli),
    .srai           (srai),
    .lui            (lui),
    .auipc          (auipc),
    .add_           (add_),
    .sub_           (sub_),
    .slt_           (slt_),
    .sltu_          (sltu_),
    .and_           (and_),
    .or_            (or_),
    .xor_           (xor_),
    .sll_           (sll_),
    .srl_           (srl_),
    .sra_           (sra_),
    .jal            (jal),
    .jalr           (jalr),
    .beq            (beq),
    .bne            (bne),
    .blt            (blt),
    .bltu           (bltu),
    .bge            (bge),
    .bgeu           (bgeu),
    .w8             (w8),
    .w16            (w16),
    .w32            (w32),
    .r8             (r8),
    .r16            (r16),
    .r32            (r32),
    .csrrw          (csrrw),
    .csrrs          (csrrs),
    .csrrc          (csrrc),
    .csrrwi         (csrrwi),
    .csrrsi         (csrrsi),
    .csrrci         (csrrci),
    .statu          (statu),
    .data_out       (data_inside),
    .addr_csr_out   (addr_csr),
    .jmp            (jmp),
    .rdy_exu        (rdy_exu)
);

csr_gpr csr_gpr(
    .clk            (clk),
    .rst            (rst),
    .sorc_sel       (sorc_sel),
    .lb             (lb),
    .lh             (lh),
    .gpr_rd_en      (gpr_rd_en),
    .csr_rd_en      (csr_rd_en),
    .gpr_wr_en      (gpr_wr_en),
    .csr_wr_en      (csr_wr_en),
    .pc_jmp         (jmp),
    .ret            (ret),
    .soft_int       (soft_int),
    .timer_int      (timer_int),
    .ext_int        (ext_int),
    .ins_addr_mis   (ins_addr_mis),
    .ins_acc_fault  (ins_acc_fault),
    .ill_ins        (ill_ins),
    .break_point    (ebreak),
    .addr_mis       (addr_mis),
    .load_acc_fault (load_acc_fault),
    .env_call       (ecall),
    .statu          (statu),
    .rs1_index      (rs1_index),
    .rs2_index      (rs2_index),
    .rd_index       (rd_index),
    .csr_index      (csr_index),
    .ins            (ins),
    .data0          (addr_csr),
    .data1          (data_inside),
    .data_biu       (data_biu),
    .pc             (pc),
    .rs1            (rs1),
    .rs2            (rs2),
    .csr            (csr),
    .timer_int_acc_o(timer_int_acc_o),
    .ext_int_acc_o  (ext_int_acc_o),
    .soft_int_acc_o (soft_int_acc_o)

);
 
assign pc_jmp = jmp; 

endmodule
