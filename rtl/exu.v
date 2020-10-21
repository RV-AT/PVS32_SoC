module exu(
input clk,
input rst,

//寄存器组数据输入

input wire [31:0]pc,
input wire [31:0]rs1,
input wire [31:0]rs2,
input wire [19:0]imm20,
input wire [11:0]imm12,
input wire [4:0] shamt,
input wire [31:0]csr,

input wire [4:0]rs1_index,


//译码输入

input wire addi ,
input wire slti,
input wire sltiu,
input wire andi,
input wire ori,
input wire xori,
input wire slli,
input wire srli,
input wire srai,

input wire lui,
input wire auipc,
input wire add_,
input wire sub_,
input wire slt_,
input wire sltu_,
input wire and_,
input wire or_,
input wire xor_,
input wire sll_,
input wire srl_,
input wire sra_,

input wire jal,
input wire jalr,

input wire beq,
input wire bne,
input wire blt,
input wire bltu,
input wire bge,
input wire bgeu,

input wire w8,
input wire w16,
input wire w32,
input wire r8,
input wire r16,
input wire r32,

input wire csrrw,
input wire csrrs,
input wire csrrc,
input wire csrrwi,
input wire csrrsi,
input wire csrrci,

//机器状态输入

input wire [2:0]statu,

//数据输出

output reg [31:0]data_out,
output reg [31:0]addr_csr_out,

//控制信号输出

output reg jmp,
output wire rdy_exu
);

reg  [4:0]shift_count;
reg statu_exu;

wire [31:0]addr_csr;
wire [31:0]data;
wire [4:0] shift;

/* assign data = {32{addi}} & (rs1 + {{20{imm12[11]}},imm12}) |                                
              {32{slti}} & ((rs1[31]==1'b1 & imm12[11]==1'b0)?32'd1 : (rs1[31]==1'b0 & imm12[11]==1'b1) ? 32'd0 :(rs1 < {{20{imm12[11]}},imm12}) ? {31'b0,1'b1}:{32'b0}) |
              {32{sltiu}}& ((rs1 < {{20{imm12[11]}},imm12}) ? {31'b0,1'b1}:{32'b0}) |
              {32{andi}} & (rs1 & {{20{imm12[11]}},imm12}) |
              {32{ori}}  & (rs1 | {{20{imm12[11]}},imm12}) |
              {32{xori}} & (rs1 ^ {{20{imm12[11]}},imm12}) |
              {32{slli}} & (rs1) | {32{srli}} & (rs1) | {32{srai}} & (rs1) |
              {32{lui}}  & {imm20,12'b0}                     |
              {32{auipc}}& (pc + {imm20,12'b0})              |
              {32{add_}} & (rs1 + rs2)                       |
              {32{sub_}} & (rs1 - rs2)                       |
              {32{slt_}} & ((rs1[31]==1'b1 & rs2[31]==1'b0)?32'd1 : (rs1[31]==1'b0 & rs2[31]==1'b1) ? 32'd0 :(rs1 < rs2) ? {31'b0,1'b1}:{32'b0}) |
              {32{sltu_}}& ((rs1<rs2)?1'b1 : 1'b0)           |
              {32{and_}} & (rs1 & rs2)                       |
              {32{or_}}  & (rs1 | rs2)                       |
              {32{xor_}} & (rs1 ^ rs2)                       |
              {32{sll_}} & (rs1) | {32{srl_}}&(rs1) | {32{sra_}}&(rs1)   |
              {32{jal}}  & (pc + 32'd4)                      |
              {32{jalr}} & (pc + 32'd4)                      |
              {32{w8}}   & (rs2) | {32{w16}}&(rs2) | {32{w32}}&(rs2)     |
              {{32{csrrw}}}& csr | csrrs & csr | csrrc & csr | csrrwi & csr | csrrsi & csr |csrrci & csr | 32'b0;
 */
 
 /*always @ (*)begin
    if(addi | add_)begin
         data = (rs1 + (addi ? {{20{imm12[11]}},imm12} :  rs2));
    end
     
    else if(slti )begin
         data = ((rs1[31]==1'b1 & imm12[11]==1'b0)?32'd1 : (rs1[31]==1'b0 & imm12[11]==1'b1) ? 32'd0 :(rs1 < {{20{imm12[11]}},imm12}) ? {31'b0,1'b1}:{32'b0});
    end
        
     else if(sltiu)begin
         data = ((rs1 < {{20{imm12[11]}},imm12}) ? {31'b0,1'b1}:{32'b0});
     end
     
     else if(andi | and_)begin
         data =  rs1 & (andi ? {{20{imm12[11]}},imm12} : rs2);
      end
      
     else if(ori | or_)begin
         data =  rs1 | (ori ? {{20{imm12[11]}},imm12}  : rs2);
     end
     
     else if(xori | xor_)begin
         data = rs1 ^ (xori ? {{20{imm12[11]}},imm12}  : rs2);
     end
     
     else if(slli | srli | srai | sll_ | srl_ | sra_)begin
         data = rs1;
     end
     
     else if(lui)begin
         data = {imm20,12'b0} ;
     end
     
     else if(auipc)begin
         data = (pc + {imm20,12'b0});
     end
     
     else if(sub_)begin
         data = rs1 - rs2;
     end
     
     else if(slt_)begin
         data = ((rs1[31]==1'b1 & rs2[31]==1'b0)?32'd1 : (rs1[31]==1'b0 & rs2[31]==1'b1) ? 32'd0 :(rs1 < rs2) ? {31'b0,1'b1}:{32'b0});
     end
     
     else if(sltu_)begin
         data = ((rs1<rs2)?1'b1 : 1'b0);
     end
     
     else if(jal | jalr)begin
         data = (pc + 32'd4);
     end
     
     else if(w8 | w16 | w32)begin
         data = rs2;
     end
     
     else if(csrrwi | csrrsi | csrrci | csrrw | csrrs | csrrc)begin
         data = csr;
     end
     
 end
 */
 assign data =
     (addi | add_) ?  (rs1 + (addi ? {{20{imm12[11]}},imm12} :  rs2)) :
    
     
     (slti )       ?  ((rs1[31]==1'b1 & imm12[11]==1'b0)?32'd1 : (rs1[31]==1'b0 & imm12[11]==1'b1) ? 32'd0 :(rs1 < {{20{imm12[11]}},imm12}) ? {31'b0,1'b1}:{32'b0}) : 

        
     (sltiu)        ? ((rs1 < {{20{imm12[11]}},imm12}) ? {31'b0,1'b1}:{32'b0}):
     
     
     (andi | and_)  ?
      (rs1 & (andi ? {{20{imm12[11]}},imm12} : rs2)):
     
      
     (ori | or_)    ?
     (rs1 | (ori ? {{20{imm12[11]}},imm12}  : rs2)):
     
     
     (xori | xor_)  ?
     (rs1 ^ (xori ? {{20{imm12[11]}},imm12}  : rs2)):
     
     
     (slli | srli | srai | sll_ | srl_ | sra_)?
          rs1 :
     
     
     (lui)?
        {imm20,12'b0} :
     
     
     (auipc)?
          (pc + {imm20,12'b0}):
     
     
     (sub_)?
          (rs1 - rs2):
     
     
    (slt_)?
         ((rs1[31]==1'b1 & rs2[31]==1'b0)?32'd1 : (rs1[31]==1'b0 & rs2[31]==1'b1) ? 32'd0 :(rs1 < rs2) ? {31'b0,1'b1}:{32'b0}):
     
     
     (sltu_)?
        ((rs1<rs2)?1'b1 : 1'b0):
     
     
     (jal | jalr)?
        (pc + 32'd4) :
    
     
     (w8 | w16 | w32)?
          rs2 :
     
     
     (csrrwi | csrrsi | csrrci | csrrw | csrrs | csrrc)?
          csr : 32'b0;
     
     
 
 
assign addr_csr =   //pc地址生成
                    (beq | bne | blt | bltu | bge | bgeu ) ?  (pc+{{19{imm12[11]}},imm12,1'b0}) :
	                jal ? ( pc +{{11{imm20[19]}},imm20,1'b0})  				       :
		    jalr? ( rs1 +{{19{imm12[11]}},imm12,1'b0})                             :
                    //读写地址生成
                    (r8 | r16 | r32 | w8 | w16 | w32) ? (rs1 + {{20{imm12[11]}},imm12}) :
                    //csr写回生成
                    csrrw ?  rs1                                             :
                    csrrs ?  (csr | rs1)                                     :
                    csrrc ? (csr | !rs1)                                     :
                    csrrwi? {27'b0,rs1_index}                                 :
                    csrrsi? (csr | {27'b0,rs1_index})                         :
                    csrrci? (csr | !{27'b0,rs1_index})                        :32'b0;
                    
                    
                  

always @ (posedge clk)begin 
    
        if(rst)begin
            
            statu_exu <= 1'b0;
            shift_count <=5'b0;
            data_out <= 32'b0;
            addr_csr_out <=32'b0;
            jmp <= 1'b0;
        end
        
        else if(statu!=3'b001)begin
        
            statu_exu <= 1'b0;
            shift_count <= 5'b0;
            data_out  <= data_out;
            addr_csr_out <= addr_csr_out;
            jmp  <= jmp;
        end
            
        else if((statu == 3'b001) & (!slli & !srli & !srai & !sll_ & !srl_ & !sra_)&(statu_exu==1'b0))begin
        
            data_out  <=  data;
            addr_csr_out <= addr_csr;
            jmp      <=     beq & (rs1 == rs2) | bne & (rs1 !=rs2) | blt & (rs1[31]==1'b1&rs2[31]==1'b0 | (rs1[31]==rs2[31])&rs1 < rs2) | bltu & (rs1 < rs2) | bge & ((rs1[31]==1'b0&rs2[31]==1'b1 | (rs1[31]==rs2[31])&rs1 < rs2)) | bgeu & (rs1 > rs2) | jal | jalr;
            shift_count <= 5'b0;
            statu_exu <=1'b0;
        end
        
        else if((statu == 3'b001) & (slli | srli | srai | sll_ | srl_ |sra_)&(statu_exu ==1'b0))begin
        
            data_out <= data;
            addr_csr_out <=addr_csr;
            jmp     <= 1'b0;
            shift_count <= (slli | srli | srai ) ? shamt : rs2[4:0];
            statu_exu <= ((slli|srli|srai)&(shamt==5'b0)|(sll_ | srl_ | sra_ )&(rs2[4:0]==5'b0)) ? 1'b0 : 1'b1;
        end
        else if((statu_exu==1'b1) & (slli | sll_))begin
            
            data_out <= (data_out<<1);
            shift_count <= shift_count - 5'd1;
            statu_exu <= (shift_count==5'd1)?1'b0 : statu_exu;
        
        end
        
        else if(statu_exu==1'b1 & (srli|srl_))begin
            
            data_out <= (data_out>>1);
            shift_count <= shift_count-5'd1;
            statu_exu <= (shift_count==5'd1)?1'b0 : statu_exu;
        end
        
        else if((statu_exu == 1'b1) & (srai | sra_))begin
            
            data_out <= (data_out>>1);                                 //此处有一个bug，我不知道有符号数怎么搞
            shift_count<=shift_count - 5'd1;
            statu_exu <= (shift_count==5'd1)?1'b0 : statu_exu;
        end
        
end

assign rdy_exu = (!(slli | srli | srai | sll_ | srl_ | sra_)|((slli|srli|srai)&(shamt==5'b0)|(sll_ | srl_ | sra_ )&(rs2[4:0]==5'b0))) ? 1'b1 : (shift_count == 5'd1)? 1'b1 : 1'b0;
            
        
endmodule



