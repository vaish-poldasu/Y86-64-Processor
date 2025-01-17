module decode_writeback(clk, icode, cnd, rA, rB, valA, valB, valE, valM,
                        reg_0,reg_1,reg_2, reg_3, reg_4, reg_5, reg_6, reg_7, 
                        reg_8, reg_9, reg_10, reg_11, reg_12, reg_13, reg_14);
//inputs
input clk, cnd;
input [3:0] icode;
input [3:0] rA,rB;
input[63:0] valE,valM;

//outputs
output reg[63:0] valA, valB;
output reg[63:0] reg_0,reg_1,reg_2, reg_3, reg_4, reg_5, reg_6, reg_7,reg_8, reg_9, reg_10, reg_11, reg_12, reg_13, reg_14;

reg [63:0] reg_memory[0:14]; //15 program registers

initial
begin
    reg_memory[0] = 64'd0;
    reg_memory[1] = 64'd1;
    reg_memory[2] = 64'd2;
    reg_memory[3] = 64'd3;
    reg_memory[4] = 64'd4;
    reg_memory[5] = 64'd5;
    reg_memory[6] = 64'd6;
    reg_memory[7] = 64'd7;
    reg_memory[8] = 64'd8;
    reg_memory[9] = 64'd9;
    reg_memory[10] = 64'd10;
    reg_memory[11] = 64'd11;
    reg_memory[12] = 64'd12;
    reg_memory[13] = 64'd13;
    reg_memory[14] = 64'd14;
end

//////////////decode////////////////
always@(*)
begin
  //cmovq
  if(icode == 4'b0010)
  begin
    valA = reg_memory[rA];
    valB = 64'b0;
  end

  //irmovq
  if(icode == 4'b0011)
  begin
    valA = 64'b0;
    valB = 64'b0;
  end

  //rmmovq
  else if(icode == 4'b0100)
  begin
    valA = reg_memory[rA];
    valB = reg_memory[rB];
  end

  //mrmovq
  else if(icode == 4'b0101)
  begin
    valB = reg_memory[rB];
  end

  //opq
  else if(icode == 4'b0110)
  begin
    valA = reg_memory[rA];
    valB = reg_memory[rB];
  end

  //call
  else if(icode == 4'b1000)
  begin
    valB = reg_memory[4];  
  end

  //ret
  else if(icode == 4'b1001)
  begin
    valA = reg_memory[4];
    valB = reg_memory[4];
  end

  //pushq
  else if(icode == 4'b1010)
  begin
    valA = reg_memory[rA];
    valB = reg_memory[4];
   end

  //popq
  else if(icode == 4'b1011)
  begin
    valA = reg_memory[4];
    valB = reg_memory[4];
  end
end


///////////////write back/////////////////

always@(posedge clk) begin  
  //cmovxx
  if(icode==4'b0010) 
  begin
    if(cnd)
      reg_memory[rB]=valE;
  end
    
  //irmovq
  else if(icode==4'b0011)
  begin 
    reg_memory[rB]=valE;
  end

  //mrmovq
  else if(icode==4'b0101) 
  begin
    reg_memory[rA] = valM;
  end

  //OPq
  else if(icode==4'b0110) 
  begin
    reg_memory[rB] = valE;
  end

  //call
  else if(icode==4'b1000) 
  begin
    reg_memory[4] = valE;
  end

  //ret
  else if(icode==4'b1001) 
  begin
    reg_memory[4] = valE;
  end

  //pushq
  else if(icode==4'b1010) 
  begin
    reg_memory[4] = valE;
   end

  //popq
  else if(icode==4'b1011) 
  begin
    reg_memory[4] = valE;
    reg_memory[rA] = valM;
  end

  reg_0 <= reg_memory[0];
  reg_1 <= reg_memory[1];
  reg_2 <= reg_memory[2];
  reg_3 <= reg_memory[3];
  reg_4 <= reg_memory[4];
  reg_5 <= reg_memory[5];
  reg_6 <= reg_memory[6];
  reg_7 <= reg_memory[7];
  reg_8 <= reg_memory[8];
  reg_9 <= reg_memory[9];
  reg_10 <= reg_memory[10];
  reg_11 <= reg_memory[11];
  reg_12 <= reg_memory[12];
  reg_13 <= reg_memory[13];
  reg_14 <= reg_memory[14];
end
endmodule
