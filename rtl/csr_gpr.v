module csr_gpr(

input wire clk,

input wire rst,

//控制独热码

//gpr数据源选择
input wire sorc_sel,
//gpr符号位拓展选择
input wire lb,
input wire lh,
//读使能
input wire gpr_rd_en,
input wire csr_rd_en,
//写使能
input wire gpr_wr_en,
input wire csr_wr_en,
//跳转信号
input wire pc_jmp,
//ret指令
input wire ret,
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
//断点
input wire break_point,
//载入的地址不对齐
input wire addr_mis,
//载入错误
input wire load_acc_fault,
//环境调用
input wire env_call,



//当前状态

input wire [2:0] statu,

//寄存器索引

input wire [4:0] rs1_index,
input wire [4:0] rs2_index,
input wire [4:0] rd_index,


//csr索引

input wire [11:0] csr_index,

//mtval输入



input wire [31:0] ins,


//数据总线输入

input wire [31:0]data0,
input wire [31:0]data1,
input wire [31:0]data_biu,

//pc值输出

output reg [31:0]pc,

//gpr寄存器读口

output wire [31:0] rs1,
output wire [31:0] rs2,

//csr寄存器读口

output wire [31:0] csr,

//仲裁之后的中断信号

output wire timer_int_acc_o,    
output wire ext_int_acc_o,        
output wire soft_int_acc_o     

);

wire [31:0]data_gpr;

//定义csr

reg [31:0]mepc;
reg [31:0]mcause;
reg [31:0]mtval;
reg [31:0]mip;
reg [31:0]mscratch;
reg [31:0]mtvec;
reg [31:0]mie;
reg [31:0]mstatus;

//定义寄存器组

reg [31:0]gpr[31:0];

//中断接受信号 

 wire   timer_int_acc;
 wire   ext_int_acc;
 wire   soft_int_acc;

 assign timer_int_acc_o = timer_int_acc;    
 assign ext_int_acc_o   = ext_int_acc;     
 assign soft_int_acc_o  = soft_int_acc;
 
 //中断值编码器
 wire  [31:0] mcause_encoder;


//通用寄存器输出

assign rs1 = gpr_rd_en & (rs1_index==5'b0000)?32'b0:gpr[rs1_index];
assign rs2 = gpr_rd_en & (rs2_index==5'b0000)?32'b0:gpr[rs2_index];

//csr读取数据选择器

assign csr =             (    {32{(csr_index == 12'h300)}} & mstatus 
                            | {32{(csr_index == 12'h304)}} & mie
                            | {32{(csr_index == 12'h305)}} & mtvec
                            | {32{(csr_index == 12'h340)}} & mscratch
                            | {32{(csr_index == 12'h341)}} & mepc
                            | {32{(csr_index == 12'h342)}} & mcause
                            | {32{(csr_index == 12'h343)}} & mtval
                            | {32{(csr_index == 12'h344)}} & mip
                            
);

//对外部中断进行仲裁

assign  timer_int_acc    = mstatus[3] & mie[7] & mip[7];
assign  ext_int_acc      = mstatus[3] & mie[11]& mip[11];  
assign  soft_int_acc     = mstatus[3] & mie[3] & mip[3];

//异常值编码器（此处应为优先级编码器）

assign  mcause_encoder   =      ins_addr_mis ? 32'd 0 : 

                                ins_acc_fault? 32'd 1 :

                                     ill_ins ? 32'd 2 :

                                break_point  ? 32'd 3 :
                            
                                    addr_mis ? 32'd 4 :

                              load_acc_fault ? 32'd 5 :
                              
                                   env_call  ? 32'd 11:
            
                                 ext_int_acc ? 32'd 2147483659 : 

                                soft_int_acc ? 32'd 2147483651 :
                                
                              timer_int_acc  ? 32'd 2147483655 : 32'b 0;
                              
//模块读取信号选择器

assign data_gpr = sorc_sel ? data1 : lb ? {{24{data_biu[7]}},data_biu[7:0]} : lh ? {{16{data_biu[15]}},data_biu[15:0]} : data_biu;

                                                       
always @ (posedge clk)begin

//同步复位

        if(rst)begin
             pc       <=  32'b0;
             mepc     <=  32'b0;
             mcause   <=  32'b0;
             mtval    <=  32'b0;
             mscratch <=  32'b0;
             mtvec    <=  32'b0;
             mie      <=  32'b0;
             mstatus  <=  32'b0;
             
         end

//当前状态不在写回，异常处理
     
     
        else if(statu != 3'b011 & statu != 3'b100 )begin
            
            //空操作
            
        end
//当前状态在写回且没有返回指令
        else if( statu == 3'b011 & !ret)begin
        
            
            
            pc   <=  pc_jmp ? data0 : pc + 4;
            
            case(csr_index)
                            12'h300:  mstatus <= data0; 
                            12'h304:  mie     <= data0;
                            12'h305:  mtvec   <= data0;
                            12'h340:  mscratch<= data0;
                            12'h341:  mepc    <= data0;
                            12'h342:  mcause  <= data0;
                            12'h343:  mtval   <= data0;
                            
            
            endcase
                                
                        
        end

//当前状态在写回并且有返回指令       
        
        else if( statu == 3'b011 & ret)begin
        
            mstatus[3] <= mstatus[7];
            
            pc <= mepc;
                        
        end
        
//当前状态需要异常处理       
        else if( statu == 3'b100)  begin
        
            mepc     <= pc;
            
            mtval    <= (ins_addr_mis|ins_acc_fault) ? pc :  (addr_mis | load_acc_fault) ? data0 : ill_ins ? ins : mtval ;
            
            pc       <= (mtvec[1:0]==2'b00) ? {mtvec[31:2],2'b00} : (!mcause_encoder[31])? {mtvec[31:3],2'b00} : 
							{mtvec[31:2],2'b00} + {22'b0,mcause_encoder[7:0],2'b00};
            
            mcause   <= mcause_encoder;  
       
            mstatus[7] <= mstatus[3];
            
            mstatus[3] <= 1'b0;

           
        end
        
 end
 
 //mip寄存器操作
 
 always @ (posedge clk) begin
        
        if(rst)begin
        
            mip <= 32'b0;
        end
        
        else begin
        
            mip[11] <= ext_int;     //外部中断输入
            mip[7]  <= timer_int;   //定时器中断输入
            mip[3]  <= soft_int;    //软件中断输入
        
        end
end

always @ (posedge clk)begin
            
           if(statu ==3'b0011 & gpr_wr_en)begin
           
                gpr[rd_index] <=  data_gpr;
           
           end
           
           
           
end
 
endmodule

            
            
