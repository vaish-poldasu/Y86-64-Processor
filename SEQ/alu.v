////full adder////
module full_adder(a,b,c,sum,carry);
input  a,b,c;
output sum,carry;
wire sub_y1,sub_y2,sub_y3,sum1;
xor gate1(sum1,a,b);
xor gate1a(sum,sum1,c);
and gate2(sub_y1,a,b);
and gate3(sub_y2,b,c);
and gate4(sub_y3,c,a);
or gate5(carry,sub_y1,sub_y2,sub_y3);
endmodule;

////adder////
module adder(A,B,sum,overflow,carry);
input signed [63:0] A,B;
output signed [63:0] sum;
output overflow;
output carry;

wire [64:0]c;
assign c[0] = 1'b0;

genvar i;
generate
    for(i = 0; i <=63; i = i+1)
    begin
        full_adder o3(A[i],B[i],c[i],sum[i],c[i+1]);
    end
endgenerate
or g1(carry,c[64],0);

//overflow occurs when there is carry into MSB and no carry out or vice-versa
//c[64] : carry out from MSB and c[63] : carry into the MSB
xor o4(overflow,c[64],c[63]);


endmodule

module full_add(a,b,c,sum,carry);
input  a,b,c;
output sum,carry;
wire sub_y1,sub_y2,sub_y3,sum1;
xor gate1(sum1,a,b);
xor gate1a(sum,sum1,c);
and gate2(sub_y1,a,b);
and gate3(sub_y2,b,c);
and gate4(sub_y3,c,a);
or gate5(carry,sub_y1,sub_y2,sub_y3);
endmodule;

////full subtractor////
module full_subtractor(A,B,diff,overflow,carry);
input signed [63:0] A,B;
output signed [63:0] diff;
output overflow;
output carry;

wire [64:0]c;
assign c[0] = 1'b1;

genvar i;
generate
    for(i = 0; i <= 63; i = i+1)
    begin
        full_add o3(A[i],B[i],c[i],diff[i],c[i+1]);
    end
endgenerate
or g1(carry,c[64],0);
xor o4(overflow,c[64],c[63]);
endmodule

////subtractor////
module subtractor(A,B,diff,overflow,carry);
input signed [63:0] A,B;
output signed [63:0] diff;
output carry;
output overflow;

wire [63:0] BN;
genvar k;
generate
    for(k = 0;k <= 63;k = k+1)
    begin
        xor o5(BN[k],B[k],1);
    end
endgenerate

full_subtractor func2(A,BN,diff,overflow,carry);

endmodule

////andgate////
module and1(A1,B1,Y1);
input A1;
input B1;
output Y1;
and gate1(Y1,A1,B1);
endmodule

module andgate(A,B,Y);
input signed [63:0] A,B;
output signed [63:0] Y;

genvar i;
generate
    for(i = 0; i <= 63; i = i+1)
    begin
        and1 o1(A[i],B[i],Y[i]);
    end
endgenerate
endmodule

////xorgate////
module xor1(A1,B1,Y1);
input A1,B1;
output Y1;
xor gate2(Y1,A1,B1);
endmodule

module xorgate(A,B,Y);
input signed [63:0] A,B;
output signed [63:0] Y;

genvar i;
generate
    for(i = 0; i <= 63; i = i+1)
    begin
        xor1 o2(A[i],B[i],Y[i]);
    end
endgenerate
endmodule

//// ALU ////
module alu(control, A, B, Y, overflow);
input [1:0] control;
input signed [63:0]A;
input signed [63:0]B;
output reg signed [63:0]Y;
output reg overflow;

wire signed [63:0] ans_add, ans_sub, ans_and, ans_xor;
wire overflow_add, overflow_sub;
wire carry_add,carry_sub;

adder g1(A, B, ans_add, overflow_add,carry_add);
subtractor g2(A, B, ans_sub, overflow_sub,carry_sub);
andgate g3(A, B, ans_and);
xorgate g4(A, B, ans_xor);


always @(*)
begin
  case (control)
  2'b00: begin // Addition
    Y = ans_add;
    overflow = overflow_add;
    end
  2'b01: begin // Subtraction
    Y = ans_sub;
    overflow = overflow_sub;
    end
  2'b10: begin // AND
    Y = ans_and;
    overflow = 1'b0;
    end
  2'b11: begin // XOR
    Y = ans_xor;
    overflow = 1'b0;
    end
  default: begin
    Y = 64'b0;
    overflow = 1'b0;
    end
  endcase
end

endmodule