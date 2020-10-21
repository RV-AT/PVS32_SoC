module iu(

input wire clk,

input wire rst,

//exu准备好信号
input wire rdy_exu,
input wire rdy_biu,

//指令输入
input wire [31:0]ins,

//中断独热码输入(仲裁之后的）
//软件中断
input wire soft_int,
//定时器中断
input wire timer_int,
//外部中断
input wire ext_int,


//指令地址不对齐
input wire ins_addr_mis,
//指令无法访问
input wire ins_acc_fault,
//非法指令
input wire ill_ins,

//载入的地址不对齐
input wire addr_mis,
//载入错误
input wire load_acc_fault,


//机器状态输出
output reg [2:0]statu,



//译码器结果输出
output wire addi ,
output wire slti,
output wire sltiu,
output wire andi,
output wire ori,
output wire xori,
output wire slli,
output wire srli,
output wire srai,

output wire lui,
output wire auipc,
output wire add_,
output wire sub_,
output wire slt_,
output wire sltu_,
output wire and_,
output wire or_,
output wire xor_,
output wire sll_,
output wire srl_,
output wire sra_,

output wire jal,
output wire jalr,

output wire beq,
output wire bne,
output wire blt,
output wire bltu,
output wire bge,
output wire bgeu,

output wire w8,
output wire w16,
output wire w32,
output wire r8,
output wire r16,
output wire r32,
output wire lb,
output wire lh,
output wire sorc_sel,

output wire csrrw,
output wire csrrs,
output wire csrrc,
output wire csrrwi,
output wire csrrsi,
output wire csrrci,

output wire csr_rd_en,
output wire csr_wr_en,
output wire gpr_rd_en,
output wire gpr_wr_en,

output wire ebreak,
output wire ecall,
output wire ret,
 
output wire [4:0]rs1_index,
output wire [4:0]rs2_index,
output wire [4:0]rd_index,
output wire [11:0]csr_index,


output wire [19:0]imm20,
output wire [11:0]imm12,
output wire [4:0] shamt

);

always@(posedge clk)begin
        
        if(rst)begin
       
            statu   <=  3'b000;
            
         end
         
         else if(statu==3'b000)begin
         
            statu   <= ( ins_addr_mis | ins_acc_fault | ill_ins) ? 3'b100 : rdy_biu ? 3'b001 : statu ;     //取指令进行minidecode的时候一旦遇到异常就转到异常处理状态
            
         end
         
                 
         else if(statu==3'b001 )begin
         
            statu<= (!rdy_exu)?statu: (w8 | w16 | w32 | r8 | r16 | r32) ? 3'b010 : 3'b011;  //执行的时候等待
            
         end
         
         
         else if(statu==3'b010 )begin
         
            statu   <=  ( addr_mis | load_acc_fault ) ? 3'b100 : rdy_biu ? 3'b011 : statu;       //内存访问的时候遇到异常转到异常处理    
            
         end
         
                
         else if(statu==3'b011)begin
         
            statu   <=  (soft_int | timer_int | ext_int | ecall | ebreak) ? 3'b100 : 3'b000;           //最后的时候如果有中断转到异常处理
            
         end

	 else if(statu==3'b100)begin
            statu   <=  3'b000;
	 end
         
         
end

assign addi = ((ins[6:0]==7'b0010011)&(ins[14:12]==3'b000))? 1'b1 : 1'b0;
assign slti = ((ins[6:0]==7'b0010011)&(ins[14:12]==3'b010))? 1'b1 : 1'b0;
assign sltiu= ((ins[6:0]==7'b0010011)&(ins[14:12]==3'b011))? 1'b1 : 1'b0;
assign xori = ((ins[6:0]==7'b0010011)&(ins[14:12]==3'b100))? 1'b1 : 1'b0;
assign ori  = ((ins[6:0]==7'b0010011)&(ins[14:12]==3'b110))? 1'b1 : 1'b0;
assign andi = ((ins[6:0]==7'b0010011)&(ins[14:12]==3'b111))? 1'b1 : 1'b0;
assign slli = ((ins[6:0]==7'b0010011)&(ins[14:12]==3'b001))? 1'b1 : 1'b0;
assign srli = ((ins[6:0]==7'b0010011)&(ins[14:12]==3'b101)&(ins[31:25]==7'b0000000))? 1'b1 : 1'b0;
assign srai = ((ins[6:0]==7'b0010011)&(ins[14:12]==3'b101)&(ins[31:25]==7'b0100000))? 1'b1 : 1'b0;

assign lui = ((ins[6:0])==7'b0110111)?1'b1 : 1'b0;
assign auipc = (ins[6:0]==7'b0010111) ? 1'b1 : 1'b0;

assign add_ = ((ins[6:0]==7'b0110011)&(ins[14:12]==3'b000)&(ins[31:25]==7'b0000000))? 1'b1 : 1'b0;
assign sub_ = ((ins[6:0]==7'b0110011)&(ins[14:12]==3'b000)&(ins[31:25]==7'b0100000))? 1'b1 : 1'b0;
assign sll_ = ((ins[6:0]==7'b0110011)&(ins[14:12]==3'b001))? 1'b1 : 1'b0;
assign slt_ = ((ins[6:0]==7'b0110011)&(ins[14:12]==3'b010))? 1'b1 : 1'b0;
assign sltu_= ((ins[6:0]==7'b0110011)&(ins[14:12]==3'b011))? 1'b1 : 1'b0;
assign xor_ = ((ins[6:0]==7'b0110011)&(ins[14:12]==3'b100))? 1'b1 : 1'b0;
assign srl_ = ((ins[6:0]==7'b0110011)&(ins[14:12]==3'b101)&(ins[31:25]==7'b0000000))? 1'b1 : 1'b0;
assign sra_ = ((ins[6:0]==7'b0110011)&(ins[14:12]==3'b101)&(ins[31:25]==7'b0100000))? 1'b1 : 1'b0;
assign or_  = ((ins[6:0]==7'b0110011)&(ins[14:12]==3'b110))? 1'b1 : 1'b0;
assign and_ = ((ins[6:0]==7'b0110011)&(ins[14:12]==3'b111))? 1'b1 : 1'b0;

assign jal  = (ins[6:0]==7'b1101111)? 1'b1 : 1'b0;
assign jalr = (ins[6:0]==7'b1100111)? 1'b1 : 1'b0;

assign beq  = ((ins[6:0]==7'b1100011)&(ins[14:12]==3'b000))?1'b1:1'b0;
assign bne  = ((ins[6:0]==7'b1100011)&(ins[14:12]==3'b001))?1'b1:1'b0; 
assign blt  = ((ins[6:0]==7'b1100011)&(ins[14:12]==3'b100))?1'b1:1'b0;
assign bge  = ((ins[6:0]==7'b1100011)&(ins[14:12]==3'b101))?1'b1:1'b0;
assign bltu = ((ins[6:0]==7'b1100011)&(ins[14:12]==3'b110))?1'b1:1'b0;
assign bgeu = ((ins[6:0]==7'b1100011)&(ins[14:12]==3'b111))?1'b1:1'b0;

assign csrrw= ((ins[6:0]==7'b1110011)&(ins[14:12]==3'b001))?1'b1:1'b0;
assign csrrs= ((ins[6:0]==7'b1110011)&(ins[14:12]==3'b010))?1'b1:1'b0;
assign csrrc= ((ins[6:0]==7'b1110011)&(ins[14:12]==3'b011))?1'b1:1'b0;
assign csrrwi=((ins[6:0]==7'b1110011)&(ins[14:12]==3'b101))?1'b1:1'b0;
assign csrrsi=((ins[6:0]==7'b1110011)&(ins[14:12]==3'b110))?1'b1:1'b0;
assign csrrci=((ins[6:0]==7'b1110011)&(ins[14:12]==3'b111))?1'b1:1'b0;

assign ebreak=((ins[6:0]==7'b1110011)&(ins[14:12]==3'b000)&(ins[31:25]==12'b0000_0000_0001))?1'b1:1'b0;
assign ecall =((ins[6:0]==7'b1110011)&(ins[14:12]==3'b000)&(ins[31:25]==12'b0000_0000_0000))?1'b1:1'b0;
assign ret   =((ins[6:0]==7'b1110011)&(ins[14:12]==3'b000)&(ins[31:20]==12'b0011_0000_0010))?1'b1:1'b0;

assign w8    =((ins[6:0]==7'b0100011)&(ins[14:12]==3'b000))?1'b1:1'b0;
assign w16   =((ins[6:0]==7'b0100011)&(ins[14:12]==3'b001))?1'b1:1'b0;
assign w32   =((ins[6:0]==7'b0100011)&(ins[14:12]==3'b010))?1'b1:1'b0;
assign r8    =((ins[6:0]==7'b0000011)&((ins[14:12]==3'b000)|(ins[14:12]==3'b100)))?1'b1:1'b0;
assign r16   =((ins[6:0]==7'b0000011)&((ins[14:12]==3'b001)|(ins[14:12]==3'b101)))?1'b1:1'b0;
assign r32   =((ins[6:0]==7'b0000011)&(ins[14:12]==3'b010))?1'b1:1'b0;
//让人头大的指令译码逻辑
//微码+1

assign sorc_sel = (ins[6:0]==7'b0000011)? 1'b0:1'b1;        //为0时选择的是从biu输入，为1选择exu输入

//rs1解码

assign rs1_index=ins[19:15];      //这个接口也被用作是zimm
assign rs2_index=ins[24:20];
assign rd_index =ins[11:7];
assign csr_index=ins[31:20];
assign imm20    =ins[31:12];
assign imm12    =((ins[6:0]==7'b1100011) | (ins[6:0]==7'b0100011)) ? {ins[31:25],ins[11:7]} : ins[31:20];
assign shamt    =ins[24:20];

assign csr_wr_en = (csrrw | csrrs |csrrc | csrrwi | csrrsi | csrrci) ? 1'b1 : 1'b0;
assign csr_rd_en = (csrrw | csrrs |csrrc | csrrwi | csrrsi | csrrci) ? 1'b1 : 1'b0;
assign gpr_wr_en = (lui | auipc | jal | jalr | r8 | r16 | r32 | addi | slti | sltiu | xori | ori | ori | andi | slli | srli | srai
          | add_ | sub_ | sll_ | slt_ | sltu_ |xor_ |srl_ |sra_ |or_ |and_ |csrrw | csrrs | csrrc | csrrwi |csrrsi | csrrci) ? 1'b1 : 1'b0;
                        
assign gpr_rd_en = 1'b1;

assign lb = ((ins[6:0]==7'b0000011)&(ins[14:12]==3'b000))?1'b1:1'b0;
assign lh = ((ins[6:0]==7'b0000011)&(ins[14:12]==3'b001))?1'b1:1'b0;


endmodule
         
         
        
        