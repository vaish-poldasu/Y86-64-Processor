module add4(S, Cout, C3, A, B, C0);
  output [3:0] S;
  output Cout, C3;
  input [3:0] A, B;
  input C0;

  wire g0, g1, g2, g3;
  wire p0, p1, p2, p3;
  wire G, P;

  assign g0 = A[0] & B[0];
  assign g1 = A[1] & B[1];
  assign g2 = A[2] & B[2];
  assign g3 = A[3] & B[3];

  assign p0 = A[0] ^ B[0];
  assign p1 = A[1] ^ B[1];
  assign p2 = A[2] ^ B[2];
  assign p3 = A[3] ^ B[3];

  assign G = g3 | (g2 & p3) | (g1 & p2 & p3) | (g0 & p1 & p2 & p3);
  assign P = p3 | (p2 & p3) | (p1 & p2 & p3) | (p0 & p1 & p2 & p3);

  assign C3 = g3 | (g2 & p3) | (g1 & p2 & p3) | (g0 & p1 & p2 & p3) | (p0 & p1 & p2 & p3);
  assign Cout = G | (P & C0);

  assign S = A + B + C0;
endmodule

////////////////////////////adder///////////////////////
module add(S, OF, A, B, cin);
  output [63:0] S;
  output reg OF;
  input [63:0] A, B;
  input cin;

    add4 CLA1(S[3:0], Cout1, C3_1, A[3:0], B[3:0], cin);
    add4 CLA2(S[7:4], Cout2, C3_2, A[7:4], B[7:4], Cout1);
    add4 CLA3(S[11:8], Cout3, C3_3, A[11:8], B[11:8], Cout2);
    add4 CLA4(S[15:12], Cout4, C3_4, A[15:12], B[15:12], Cout3);
    add4 CLA5(S[19:16], Cout5, C3_5, A[19:16], B[19:16], Cout4);
    add4 CLA6(S[23:20], Cout6, C3_6, A[23:20], B[23:20], Cout5);
    add4 CLA7(S[27:24], Cout7, C3_7, A[27:24], B[27:24], Cout6);
    add4 CLA8(S[31:28], Cout8, C3_8, A[31:28], B[31:28], Cout7);
    add4 CLA9(S[35:32], Cout9, C3_9, A[35:32], B[35:32], Cout8);
    add4 CLA10(S[39:36], Cout10, C3_10, A[39:36], B[39:36], Cout9);
    add4 CLA11(S[43:40], Cout11, C3_11, A[43:40], B[43:40], Cout10);
    add4 CLA12(S[47:44], Cout12, C3_12, A[47:44], B[47:44], Cout11);
    add4 CLA13(S[51:48], Cout13, C3_13, A[51:48], B[51:48], Cout12);
    add4 CLA14(S[55:52], Cout14, C3_14, A[55:52], B[55:52], Cout13);
    add4 CLA15(S[59:56], Cout15, C3_15, A[59:56], B[59:56], Cout14);
    add4 CLA16(S[63:60], Cout16, C3_16, A[63:60], B[63:60], Cout15);

    xor overflow(err, Cout16, C3_16);
    always @* OF = err;
    
endmodule

module notgate(A_not, A);
  input [63:0] A;
  output [63:0] A_not;
 
  genvar k;

  for(k=0; k<64; k=k+1) begin
      not(A_not[k],A[k]);
  end
endmodule

///////////////////subtract/////////////////////////////////////
module subtract(S, err, A, B, cin);
  input [63:0] A, B;
  input cin;
  output [63:0] S;
  output err;

  wire [63:0] B_1;
  notgate complement(B_1, B);   

  add Subtract(S, err, A, B_1, cin);
endmodule

/////////////////////////////////andgate/////////////////////////////
module andgate(Y, A, B);
  input [63:0] A, B;
  output [63:0] Y;
    
  genvar k;

  for(k = 0; k < 64; k = k + 1) begin
      and(Y[k], A[k], B[k]);
  end
endmodule

//////////////////////////xorgate///////////////////////////////////
module xorgate(Y, A, B);
  input [63:0] A, B;
  output [63:0] Y;
    
  genvar k;
    
  for(k=0; k<64; k=k+1) begin
      xor(Y[k], A[k], B[k]);
  end
endmodule

///////////////////////////ALU////////////////////////////////////
module alu(control, A, B, Y, OF);

input [1:0] control;
input [63:0] A,B;
output reg [63:0] Y;
output reg OF;

wire [63:0] add_y, sub_y, and_y, xor_y;
reg [63:0]to_send;
wire OF_add, OF_sub;

add ADD(add_y, OF_add, A, B, control[0]);
subtract SUB(sub_y,OF_sub, B, A, control[0]);
andgate AND(and_y, A, B);
xorgate XOR(xor_y, A, B);

always @*
begin
  if (control==2'b00)begin
  Y = add_y;
  OF = OF_add;
  end

  else if (control==2'b01)begin
  Y = sub_y;
  OF = OF_sub;
  end

  else if (control==2'b10)
  Y = and_y;

  else if (control==2'b11)
  Y = xor_y;
end
endmodule




