module decode_wb(clk, D_stat, D_icode, D_ifun, D_rA, D_rB, D_valC,D_valP,
                 d_srcA, d_srcB, E_bubble, E_stat, E_icode, E_ifun, E_valC, 
                 E_valA, E_valB, E_dstE, E_dstM, E_srcA, E_srcB, e_dstE, e_valE,
                 M_dstE, M_dstM, M_valE, m_valM, W_dstE, W_dstM, W_valE,W_valM,W_icode,
                 reg_0,reg_1,reg_2,reg_3,reg_4,reg_5,reg_6,reg_7,
                 reg_8,reg_9,reg_10,reg_11,reg_12,reg_13,reg_14 );

//decode stage + reg
input clk;
input [0:3] D_stat;
input [3:0] D_icode,D_ifun,D_rA,D_rB;
input [63:0] D_valC,D_valP;

output reg [3:0] d_srcA,d_srcB;

//execute stage + reg
input E_bubble;
input [3:0] e_dstE;
input [63:0] e_valE;

output reg [0:3] E_stat;
output reg [3:0] E_icode,E_ifun;
output reg [63:0] E_valC,E_valA,E_valB;
output reg [3:0] E_dstE,E_dstM,E_srcA,E_srcB;

//memory stage + reg
input [3:0] M_dstE, M_dstM;
input [63:0] M_valE, m_valM;

//writeback stage + reg
input [3:0] W_icode, W_dstE, W_dstM;
input [63:0] W_valE, W_valM;

output reg[63:0] reg_0,reg_1,reg_2,reg_3,reg_4,reg_5,reg_6,reg_7,
reg_8,reg_9,reg_10,reg_11,reg_12,reg_13,reg_14;

reg [3:0] d_dstE,d_dstM;
reg [63:0] d_rvalA,d_rvalB,d_valA,d_valB,reg_mem[0:14];


initial begin
    reg_mem[0] = 0;
    reg_mem[1] = 1;
    reg_mem[2] = 2;
    reg_mem[3] = 3;
    reg_mem[4] = 4;
    reg_mem[5] = 5;
    reg_mem[6] = 6;
    reg_mem[7] = 7;
    reg_mem[8] = 8;
    reg_mem[9] = 9;
    reg_mem[10] = 10;
    reg_mem[11] = 11;
    reg_mem[12] = 12;
    reg_mem[13] = 13;
    reg_mem[14] = 14;
end
always@(*)
begin
  d_srcA = 4'hF;
  d_srcB = 4'hF;
  d_dstE = 4'hF;
  d_dstM = 4'hF;

//cmovq
if (D_icode == 4'b0010) begin
  d_srcA = D_rA;
  d_dstE = D_rB;
  d_rvalA=reg_mem[D_rA];
  d_rvalB=64'b0;
end

//irmovq
else if (D_icode == 4'b0011) begin
  d_dstE = D_rB;
  d_rvalB=64'b0;
end

//rmmovq
else if (D_icode == 4'b0100) begin
  d_srcA = D_rA;
  d_srcB = D_rB;
  d_rvalA=reg_mem[D_rA];
  d_rvalB=reg_mem[D_rB];
end

//mrmovq
else if (D_icode == 4'b0101) begin
  d_srcB = D_rB;
  d_dstM = D_rA;
  d_rvalB=reg_mem[D_rB];
end

//OPq
else if (D_icode == 4'b0110) begin
  d_srcA = D_rA;
  d_srcB = D_rB;
  d_dstE = D_rB;
  d_rvalA=reg_mem[D_rA];
  d_rvalB=reg_mem[D_rB];
end

//call
else if (D_icode == 4'b1000) begin
  d_srcB = 4;
  d_dstE = 4;
  d_rvalB=reg_mem[4];
end

//ret
else if (D_icode == 4'b1001) begin
  d_srcA = 4;
  d_srcB = 4;
  d_dstE = 4;
  d_rvalA=reg_mem[4]; 
  d_rvalB=reg_mem[4];
end

//pushq
else if (D_icode == 4'b1010) begin
  d_srcA = D_rA;
  d_srcB = 4;
  d_dstE = 4;
  d_rvalA=reg_mem[D_rA];
  d_rvalB=reg_mem[4];
end

//popq
else if (D_icode == 4'b1011) begin
  d_srcA = 4;
  d_srcB = 4;
  d_dstE = 4;
  d_dstM = D_rA;
  d_rvalA=reg_mem[4]; 
  d_rvalB=reg_mem[4];
end

 // Forwarding A
 //jxx or call
if(D_icode==4'b0111 | D_icode == 4'b1000) 
    d_valA = D_valP;
else if(d_srcA==e_dstE & e_dstE!=4'hF)
    d_valA = e_valE;
else if(d_srcA==M_dstM & M_dstM!=4'hF)
    d_valA = m_valM;
else if(d_srcA==W_dstM & W_dstM!=4'hF)
    d_valA = W_valM;
else if(d_srcA==M_dstE & M_dstE!=4'hF)
    d_valA = M_valE;
else if(d_srcA==W_dstE & W_dstE!=4'hF)
    d_valA = W_valE;
else
    d_valA = d_rvalA;

// Forwarding B
//  from execute
if(d_srcB==e_dstE & e_dstE!=4'hF)      
    d_valB = e_valE;

// from memory
else if(d_srcB==M_dstM & M_dstM!=4'hF) 
    d_valB = m_valM;

// memory value from write back stage
else if(d_srcB==W_dstM & W_dstM!=4'hF) 
    d_valB = W_valM;

// execute value from memory stage
else if(d_srcB==M_dstE & M_dstE!=4'hF) 
    d_valB = M_valE;

// execute value from write back stage 
else if(d_srcB==W_dstE & W_dstE!=4'hF) 
    d_valB = W_valE;
else
    d_valB = d_rvalB;
end

always@(posedge clk)
begin 
    if(E_bubble)
    begin
      E_stat <= 4'b1000;
      E_icode <= 4'b0001;
      E_ifun <= 4'b0000;
      E_valC <= 4'b0000;
      E_valA <= 4'b0000;
      E_valB <= 4'b0000;
      E_dstE <= 4'hF;
      E_dstM <= 4'hF;
      E_srcA <= 4'hF;
      E_srcB <= 4'hF;
    end

    // Execute register update
    else
    begin
      E_stat <= D_stat;
      E_icode <= D_icode;
      E_ifun <= D_ifun;
      E_valC <= D_valC;
      E_valA <= d_valA;
      E_valB <= d_valB;
      E_srcA <= d_srcA;
      E_srcB <= d_srcB;
      E_dstE <= d_dstE;
      E_dstM <= d_dstM;
    end
end

// writeback 
always@(posedge clk) begin

//cmovxx
if(W_icode==4'b0010) 
begin
    reg_mem[W_dstE]=W_valE;
end

//irmovq
else if(W_icode==4'b0011)
begin 
    reg_mem[W_dstE]=W_valE;
end

//mrmovq
else if(W_icode==4'b0101) 
begin
    reg_mem[W_dstM] = W_valM;
end

//OPq
else if(W_icode==4'b0110) 
begin
    reg_mem[W_dstE] = W_valE;
end

//call
else if(W_icode==4'b1000) 
begin
    reg_mem[W_dstE] = W_valE;
end

//ret
else if(W_icode==4'b1001) 
begin
    reg_mem[W_dstE] = W_valE;
end

//pushq
else if(W_icode==4'b1010) 
begin
    reg_mem[W_dstE] = W_valE;
end

//popq
else if(W_icode==4'b1011) 
begin
    reg_mem[W_dstE] = W_valE;
    reg_mem[W_dstM] = W_valM;
end

reg_0 <= reg_mem[0];
reg_1 <= reg_mem[1];
reg_2 <= reg_mem[2];
reg_3 <= reg_mem[3];
reg_4 <= reg_mem[4];
reg_5 <= reg_mem[5];
reg_6 <= reg_mem[6];
reg_7 <= reg_mem[7];
reg_8 <= reg_mem[8];
reg_9 <= reg_mem[9];
reg_10 <= reg_mem[10];
reg_11 <= reg_mem[11];
reg_12 <= reg_mem[12];
reg_13 <= reg_mem[13];
reg_14 <= reg_mem[14];
end
endmodule

