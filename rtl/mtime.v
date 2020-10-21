module mtime(

input rst,
input clk,
input wrh_n,
input wrl_n,

input [31:0]mtimer_o,


output reg [31:0]mtimerh_i,
output reg [31:0]mtimerl_i

);

always@(posedge clk)begin

    mtimerh_i <= rst ? 32'b0 : !wrh_n ? mtimer_o : (mtimerl_i==32'hffffffff) ? (mtimerh_i + 32'b1) : mtimerh_i;
    mtimerl_i <= rst ? 32'b0 : !wrl_n ? mtimer_o : mtimerl_i + 32'b1;
    
end

endmodule
