module memory(clk,icode,valE,valP,valA,valM,dmem_error);

//inputs
input clk;
input [3:0] icode;
input [63:0] valE;
input [63:0] valP;
input [63:0] valA;

//outputs
output reg [63:0] valM;
output reg dmem_error=0;

reg [63:0] data_mem [0:1023];

always@(posedge clk)
begin 
if(valE>18446744073709551616) //2^64
begin
dmem_error = 1;
end

// rmmovq
if(icode == 4'b0100)
begin
data_mem[valE] <= valA;
end

// mrmovq
else if(icode == 4'b0101)
begin
valM = data_mem[valE];
end

// call
else if(icode == 4'b1000)
begin
data_mem[valE] <= valP;
end

// ret
else if(icode == 4'b1001)
begin
valM = data_mem[valA];   
end

// pushq
else if(icode == 4'b1010)
begin
data_mem[valE] <= valA;  
end

// popq
else if(icode == 4'b1011)
begin
valM = data_mem[valA];   
end

end
endmodule