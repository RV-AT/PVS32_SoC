module plic_cell(
input int_src,
input rst,
input [7:0]prio,
input [7:0]thres,
input en,
input icomp,
output ip,
output iclaim

);
reg gate;
assign ip=gate;
always@(posedge int_src or posedge rst or posedge icomp)
begin
assign gate<=(rst|ack)?1'b0:(int_src)?1'b1:1'b0;
end
assign iclaim=(prio>thres)&gate;


endmodule