module biu(

input clk,

input rst,
//总线信号

input wire [31:0]data_i,
output wire[31:0]data_o,

input wire rdy,
//访问失败信号
input wire acc_fault,

output wire [31:0]addr,

output wire rd_n,

output wire wr_n,

output wire l8,

output wire l16,

output wire h24,

output wire h32,

//对内部信号
input wire [31:0]addr_in,

input wire [31:0]data_in,
//机器状态输入
input wire [2:0]statu,

input wire [31:0]pc,

//指令decode输入
input wire w32,     //状态0001

input wire w16,     //状态0010

input wire w8,      //状态0011

input wire r32,     //状态0100

input wire r16,     //状态0101

input wire r8,      //状态0110

//指令寄存器输出

output reg [31:0]ins,

//数据寄存器输出

output reg [31:0]data_out,

//异常报告
//指令地址不对齐
output wire ins_addr_mis,
//指令无法访问
output wire ins_acc_fault,
//非法指令
output wire ill_ins,
//载入的地址不对齐
output wire addr_mis,
//载入错误
output wire load_acc_fault,
output wire rdy_biu,
output wire [3:0] statu_biu_out


);

//机器状态寄存器
reg [3:0] statu_biu;

//通过寄存器对输出异常信号进行延迟，保证进入异常处理后能捕捉到异常
wire ins_addr_mis_judge;
wire ins_acc_fault_judge;
wire ill_ins_judge;
wire addr_mis_judge;
wire load_acc_fault_judge;

reg ins_addr_mis_st;
reg ins_acc_fault_st;
reg ill_ins_st;
reg addr_mis_st;
reg load_acc_fault_st;

//产生异常信号

assign ins_addr_mis     =   ins_addr_mis_judge   |  ins_addr_mis_st;
assign ins_acc_fault    =   ins_acc_fault_judge  |  ins_acc_fault_st;
assign ill_ins          =   ill_ins_judge        |  ill_ins_st;
assign addr_mis         =   addr_mis_judge       |  addr_mis_st;
assign load_acc_fault   =   load_acc_fault_judge |  load_acc_fault_st;

//异常判断
assign load_acc_fault_judge   = acc_fault;
assign ins_addr_mis_judge = (pc[1:0] != 2'b00);
assign ins_acc_fault_judge= (statu == 3'b000) &  acc_fault;
assign ill_ins_judge      = (statu == 3'b000) & rdy & !((data_i[6:0] == 7'b0110111) |
                                                       (data_i[6:0] == 7'b0010111) |
                                                       (data_i[6:0] == 7'b1101111) |
                                                       (data_i[6:0] == 7'b1100111) & (data_i[14:12] == 3'b000) |
                                                       (data_i[6:0] == 7'b1100011) & (data_i[14:13] != 2'b10)  |
                                                       (data_i[6:0] == 7'b0000011) & ((data_i[14:12] != 3'b011) | (data_i[14:12] != 3'b110) | (data_i[14:12] != 3'b111)) |
                                                       (data_i[6:0] == 7'b0100011) & ((data_i[14:12] == 3'b000) | (data_i[14:12] != 3'b001) | (data_i[14:12] != 3'b010)) |
                                                       (data_i[6:0] == 7'b0010011) |
                                                       (data_i[6:0] == 7'b0110011) |
                                                       (data_i[6:0] == 7'b0001111) & (data_i[14:12] == 3'b000) |
                                                       (data_i[6:0] == 7'b1110011));
                                                       
                                                       
assign addr_mis_judge = ((w32 | r32) & (addr[1:0] != 2'b00)) | ((w16 | r16) & ( addr[1:0]==2'b11)) ;  
//对异常进行寄存                                                       
always @ (posedge clk) begin

        ins_addr_mis_st     <= rst ? 1'b0 : ins_addr_mis_judge;
        ins_acc_fault_st    <= rst ? 1'b0 : ins_acc_fault_judge;
        ill_ins_st          <= rst ? 1'b0 : ill_ins_judge;
        addr_mis_st         <= rst ? 1'b0 : addr_mis_judge;
        load_acc_fault_st   <= rst ? 1'b0 : load_acc_fault_judge;
end
                                                       

//biu状态变动

always @ (posedge clk)begin

        if(rst)begin
               
            statu_biu    <= 4'b0000;
            ins          <= 32'b0;
            data_out     <= 32'b0;
            
        end
        
        else if(!((statu == 3'b000) | (statu == 3'b010)))begin
        
            statu_biu <= 4'b0000;
            
        end
        
        else if((statu==3'b000) & (statu_biu == 4'b0000)) begin
        
            statu_biu <= (ins_addr_mis_judge | ins_acc_fault_judge) ? 4'b1001 : 4'b0111;
            
        end
        
        else if((statu==3'b010) & (statu_biu == 4'b0000))begin
        
            statu_biu <=    w32 ? 4'b0001: w16 ? 4'b0010 : w8 ? 4'b0011 : r32 ? 4'b0100 : r16 ? 4'b0101 : r8 ? 4'b0110 : 4'b0000;
                            
        end
        
        else if((statu_biu[3] == 1'b0) & (statu_biu!=4'b0000))begin
            
            statu_biu <= (((statu==3'b000) & (ins_addr_mis | ins_acc_fault | ill_ins)) | addr_mis | load_acc_fault) ? 4'b1001 : rdy ? 4'b1000 : statu_biu;
            
        end
        
        else if(statu_biu == 4'b1000)begin
            
            ins       <= (statu==3'b000) ? data_i :  ins;
            data_out  <= (statu!=3'b010) ? data_out : (r8 & (addr_in[1:0]==2'b00)) ? {24'b0,data_i[7:0]}  :
                                                                                     (r8 & (addr_in[1:0]==2'b01)) ? {24'b0,data_i[15:8]} :
                                                                                     (r8 & (addr_in[1:0]==2'b10)) ? {24'b0,data_i[23:16]}:
                                                                                     (r8 & (addr_in[1:0]==2'b11)) ? {24'b0,data_i[31:24]}:
                                                                                     (r16& (addr_in[1:0]==2'b00)) ? {16'b0,data_i[15:0]} :
                                                                                     (r16& (addr_in[1:0]==2'b01)) ? {16'b0,data_i[23:8]} :
                                                                                     (r16& (addr_in[1:0]==2'b10)) ? {16'b0,data_i[31:16]}:
                                                                                     r32 ? data_i : data_out; 
           
            statu_biu <= 4'b0000;
            
        end
        
        else if(statu_biu == 4'b1001)begin
            
            ins     <= (statu == 3'b000) ? data_i : ins;
            data_out<= data_out;
            statu_biu <= 4'b0000;
            
        end
        
end

assign data_o = (statu == 3'b000) ? 32'b0 : (statu != 3'b010) ? 32'b0 :
              (w8 & (addr_in[1:0]==2'b00)) ? {24'b0,data_in[7:0]}  :
              (w8 & (addr_in[1:0]==2'b01)) ? {16'b0,data_in[7:0],8'b0} :
              (w8 & (addr_in[1:0]==2'b10)) ? {8'b0,data_in[7:0],16'b0}:
              (w8 & (addr_in[1:0]==2'b11)) ? {data_in[7:0],24'b0}:
              (w16& (addr_in[1:0]==2'b00)) ? {16'b0,data_in[15:0]} :
              (w16& (addr_in[1:0]==2'b01)) ? {8'b0,data_in[15:0],8'b0} :
              (w16& (addr_in[1:0]==2'b10)) ? {data_in[15:0],16'b0}:
               w32 ? data_in : 32'b0;  
           
assign rd_n = !((r8|r16|r32|statu==3'b000)&((statu_biu == 4'b0100) | (statu_biu == 4'b0101) | (statu_biu == 4'b0110) | (statu_biu == 4'b0111)|(statu_biu==4'b1000))); 

assign wr_n = !((statu_biu == 4'b0001) | (statu_biu == 4'b0010) | (statu_biu == 4'b0011));

assign l8 = ((statu == 3'b000)|(statu_biu!=4'b0000)&(w8 | r8)&(addr[1:0]==2'b00) | (w16 | r16) & (addr[1:0]==2'b00) | w32 | r32);

assign l16= ((statu == 3'b000)|(statu_biu!=4'b0000)&(w8 | r8)&(addr[1:0]==2'b01) | (w16 | r16) & ((addr[1:0]==2'b00)|(addr[1:0]==2'b01)) | w32 | r32);

assign h24= ((statu == 3'b000)|(statu_biu!=4'b0000)&(w8 | r8)&(addr[1:0]==2'b10) | (w16 | r16) & ((addr[1:0]==2'b01)|(addr[1:0]==2'b10)) | w32 | r32);

assign h32= ((statu == 3'b000)|(statu_biu!=4'b0000)&(w8 | r8)&(addr[1:0]==2'b11) | (w16 | r16) & (addr[1:0]==2'b10) | w32 | r32);

assign addr = (statu == 3'b000)&((statu_biu == 4'b0111)|(statu_biu == 4'b1000)) ? pc :
              (statu == 3'b010)&((statu_biu[3] == 1'b0)&(statu_biu != 4'b0000) | (statu_biu == 4'b1000)) ? addr_in : 32'b0;

assign rdy_biu = (statu_biu == 4'b1000);
assign statu_biu_out = statu_biu;

endmodule
        
        
