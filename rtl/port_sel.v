module port_sel(


//对内部总线的信号

input [7:0]data_o,

input wr_n,
input rd_n,

input en,


output  [7:0]data_i,
output sel0,
output sel1,
output sel2

);

reg [7:0] selreg;

always@(posedge wr_n )begin
            
            selreg <= en ? data_o : selreg;
            
end

assign data_i = selreg;

assign sel0 = selreg[0];
assign sel1 = selreg[1];
assign sel2 = selreg[2];

endmodule

        