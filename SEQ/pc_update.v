module pc_update(clk,icode,cnd,valC,valM,valP,PC);

//inputs
input clk;            // Clock input
input [3:0] icode;    //Instruction code
input cnd;          //Condition
input [63:0] valC;    // Immediate value 
input [63:0] valM;    //Memory mod output
input [63:0] valP;    // Next program counter

//outputs
output reg [63:0] PC; // Program Counter

always@(posedge clk)
begin

if(icode == 4'b0000)
begin
PC <= 0;
end

if(icode == 4'b0001)
begin
PC <= valP;
end

if(icode == 4'b0010)
begin
PC <= valP;
end

if(icode == 4'b0011)
begin
PC <= valP;
end

if(icode == 4'b0100)
begin
PC <= valP;
end

if(icode == 4'b0101)
begin
PC <= valP;
end

if(icode == 4'b0110)
begin
PC <= valP;
end

if(icode == 4'b0111)
begin
PC <= cnd ? valC:valP;
end

if(icode == 4'b1000)
begin
PC <= valC;
end

if(icode == 4'b1001)
begin
PC <= valM;
end

if(icode == 4'b1010)
begin
PC <= valP;
end

if(icode == 4'b1011)
begin
PC <= valP;
end

end
endmodule