module ram(

input clock,
input wren,
input [9:0]address,
input [7:0]data,
output reg[7:0]q
);

reg [7:0] regfile [1023:0];

always@(posedge clock)begin
if(wren)begin	
	regfile[address] <= data;
        q		 <=data;
end
else begin
	q<= regfile[address];
end

end

endmodule
