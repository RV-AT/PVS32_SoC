module mtimecmp(

input clk,
input rst,
input wrh_n,
input wrl_n,

input [63:0]mtime,

input [31:0]mtimecmp_o,

output reg[31:0] mtimecmph_i,
output reg[31:0] mtimecmpl_i,

output wire timer_int

);

always@(posedge clk)begin

    mtimecmph_i <= rst ? 32'b0 : !wrh_n ? mtimecmp_o : mtimecmph_i ; 
    mtimecmpl_i <= rst ? 32'b0 : !wrl_n ? mtimecmp_o : mtimecmpl_i ;
    
end

assign timer_int = mtime > {mtimecmph_i,mtimecmpl_i} ;

endmodule
