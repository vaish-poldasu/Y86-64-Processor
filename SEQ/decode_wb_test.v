`include "fetch.v"
`include "decode_writeback.v"

module decode_wb_test;
  reg clk;
  reg [63:0] PC;
  wire [3:0] icode;
  wire [3:0] ifun;
  wire [3:0] rA;
  wire [3:0] rB; 
  wire [63:0] valA, valB, valC, valM,valE;
  wire [63:0] valP;
  wire ins_mem_error, valid_instr;
  reg [7:0] instr_mem[0:20480];
  reg [0:79] instr;
  reg cnd;

  wire [63:0] reg_0,reg_1,reg_2,reg_3,reg_4,reg_5,reg_6,reg_7,reg_8,reg_9,reg_10,reg_11,reg_12,reg_13,reg_14; 


fetch func1(
  .clk(clk),
  .PC(PC),
  .instr(instr),
  .icode(icode),
  .ifun(ifun),
  .rA(rA),
  .rB(rB),
  .valC(valC),
  .valP(valP),
  .ins_mem_error(ins_mem_error),
  .valid_instr(valid_instr),.halt(halt)
    
);
  
decode_writeback func2(
  .clk(clk),.icode(icode),.rA(rA),.rB(rB),.valA(valA),.valB(valB),.valM(valM),.valE(valE),.cnd(cnd),
  .reg_0(reg_0),.reg_1(reg_1),.reg_2(reg_2),.reg_3(reg_3),.reg_4(reg_4),
  .reg_5(reg_5),.reg_6(reg_6),.reg_7(reg_7),.reg_8(reg_8),.reg_9(reg_9),
  .reg_10(reg_10),.reg_11(reg_11),.reg_12(reg_12),.reg_13(reg_13),.reg_14(reg_14)
);

// always@(PC) begin
//   instr={
//     instr_mem[PC],
//     instr_mem[PC+1],
//     instr_mem[PC+9],
//     instr_mem[PC+8],
//     instr_mem[PC+7],
//     instr_mem[PC+6],
//     instr_mem[PC+5],
//     instr_mem[PC+4],
//     instr_mem[PC+3],
//     instr_mem[PC+2]
//   };
// end

always@(PC) begin
  instr={
    instr_mem[PC],
    instr_mem[PC+1],
    instr_mem[PC+2],
    instr_mem[PC+3],
    instr_mem[PC+4],
    instr_mem[PC+5],
    instr_mem[PC+6],
    instr_mem[PC+7],
    instr_mem[PC+8],
    instr_mem[PC+9]
  };
end

always @(icode) begin
  if(halt==1) 
    $finish;
end

  always #10 clk = ~clk;
  always @(posedge clk) PC<=valP;

initial begin
  $dumpfile("decode_wb_test.vcd");
  $dumpvars(0,decode_wb_test); 
	$monitor("clk=%d icode=%b ifun=%b rA=%b rB=%b valA=%d valB=%d valE=%d valM=%d\n",clk,icode,ifun,rA,rB,valA,valB,valE,valM); 
  clk=1;
  PC=64'd0;
  
////////////////////////////////Test Case 1////////////////////////////
// Reference for 1.txt

// //opq , halt along with irmovq 

// //irmovq $0x100, %rbx
// instr_mem[0]=8'b00110000;
// instr_mem[1]=8'b11110011;
// instr_mem[2]=8'b00000000;
// instr_mem[3]=8'b00000001;
// instr_mem[4]=8'b00000000;
// instr_mem[5]=8'b00000000;
// instr_mem[6]=8'b00000000;
// instr_mem[7]=8'b00000000;
// instr_mem[8]=8'b00000000;
// instr_mem[9]=8'b00000000;

// //irmovq $0x200, %dx
// instr_mem[10]=8'b00110000;
// instr_mem[11]=8'b11110010;
// instr_mem[12]=8'b00000000;
// instr_mem[13]=8'b00000010;
// instr_mem[14]=8'b00000000;
// instr_mem[15]=8'b00000000;
// instr_mem[16]=8'b00000000;
// instr_mem[17]=8'b00000000;
// instr_mem[18]=8'b00000000;
// instr_mem[19]=8'b00000000;

// //addq %rdx, %rbx
// instr_mem[20]=8'b01100000;
// instr_mem[21]=8'b00100011;

// //halt
// instr_mem[22]=8'b00000000;


////////////////////////////////Test Case 2////////////////////////////

// //rrmovq , rmmovq , nop , halt along with opq

// //opq add
// instr_mem[0] = 8'b01100000;
// //%rax = 1 %rbx = 3
// instr_mem[1] = 8'b00010011; 
// // rrmovq 
// instr_mem[2] = 8'b00100000;
// instr_mem[3] = 8'b00010011; 
// // src = %rax dest = %rbx

// //rmmovq 
// instr_mem[4] = 8'b01000000; 
//  //rax and (rbx)
// instr_mem[5] = 8'b00010011;
// //VALC
// instr_mem[6] = 8'b00001111;  
// instr_mem[7] = 8'b00000000;
// instr_mem[8] = 8'b00000000;
// instr_mem[9] = 8'b00000000;
// instr_mem[10] = 8'b00000000;
// instr_mem[11] = 8'b00000000;
// instr_mem[12] = 8'b00000000;
// instr_mem[13] = 8'b00000000;

// //no operation
// instr_mem[14] = 8'b00010000; 

// //halt
// instr_mem[15] = 8'b00000000; 

////////////////////////////////Test Case 3////////////////////////////

// //jump, halt along with irmovq 

// //irmovq $0xc, %rbx
// //3 0
  // instr_mem[20]=8'b00110000; 
  // //F rB=3
  // instr_mem[21]=8'b00000011; 
  // instr_mem[22]=8'b00000000;           
  // instr_mem[23]=8'b00000000;           
  // instr_mem[24]=8'b00000000;           
  // instr_mem[25]=8'b00000000;           
  // instr_mem[26]=8'b00000000;           
  // instr_mem[27]=8'b00000000;           
  // instr_mem[28]=8'b00000000;          
  // instr_mem[29]=8'b00001100; 
// // Val=12

  // //jmp :find
  //  //7 jxx
  // instr_mem[30]=8'b01110000;
  // instr_mem[31]=8'b00000000; 
  // instr_mem[32]=8'b00000000; 
  // instr_mem[33]=8'b00000000; 
  // instr_mem[34]=8'b00000000; 
  // instr_mem[35]=8'b00000000; 
  // instr_mem[36]=8'b00000000; 
  // instr_mem[37]=8'b00000000; 
  // instr_mem[38]=8'b00100111; 
  
  // // find:
  // // opq //6 add
  // instr_mem[39]=8'b01100000; 
  // //rA=0 rB=3
  // instr_mem[40]=8'b00000011; 
  // instr_mem[41]=8'b00000000;

  ////////////////////////////////Test Case 4////////////////////////////
  
  ////call , ret , halt along with irmovq 

//   //irmovq $0x2, %rax
//   //3 0
//   instr_mem[0]=8'b00110000; 
//   //F rB=0
//   instr_mem[1]=8'b00000000; 
//   instr_mem[2]=8'b00000000;           
//   instr_mem[3]=8'b00000000;           
//   instr_mem[4]=8'b00000000;           
//   instr_mem[5]=8'b00000000;           
//   instr_mem[6]=8'b00000000;           
//   instr_mem[7]=8'b00000000;           
//   instr_mem[8]=8'b00000000;          
//   instr_mem[9]=8'b00000010; 
//  //Val=2

//   //irmovq $0x10, %rdx
//   //3 0
//   instr_mem[10]=8'b00110000; 
//   //F rB=2
//   instr_mem[11]=8'b00000010; 
//   instr_mem[12]=8'b00000000;           
//   instr_mem[13]=8'b00000000;           
//   instr_mem[14]=8'b00000000;           
//   instr_mem[15]=8'b00000000;           
//   instr_mem[16]=8'b00000000;           
//   instr_mem[17]=8'b00000000;           
//   instr_mem[18]=8'b00000000;          
//   instr_mem[19]=8'b01010001; 
//   //Val=81

// //1 0
// instr_mem[20]=8'b00010000; 
//   //call
//   //8 0
//     instr_mem[21]=8'b10000000; 
//     //dest
//     instr_mem[22]=8'b00000000; 
//     instr_mem[23]=8'b00000000; 
//     instr_mem[24]=8'b00000000; 
//     instr_mem[25]=8'b00000000; 
//     instr_mem[26]=8'b00000000; 
//     instr_mem[27]=8'b00000000; 
//     instr_mem[28]=8'b00000000; 
//     instr_mem[29]=8'b00000001; 

//   //ret
//   // 9 0
//     instr_mem[30]=8'b10010000; 
    
  
//   //halt
//   // 0 0
//     instr_mem[31]=8'b00000000;

////////////////////////////////Test Case 5////////////////////////////
  
// //cmovxx , halt along with irmovq and opq

// //addq %rdx, %rbx
// instr_mem[0]=8'b00110000;
// instr_mem[1]=8'b11110011;
// instr_mem[2]=8'b00000000;
// instr_mem[3]=8'b00000000;
// instr_mem[4]=8'b00000000;
// instr_mem[5]=8'b00000000;
// instr_mem[6]=8'b00000000;
// instr_mem[7]=8'b00000000;
// instr_mem[8]=8'b00000101;
// instr_mem[9]=8'b00001000;
// instr_mem[10]=8'b00110000;
// instr_mem[11]=8'b11110010;
// instr_mem[12]=8'b00000000;
// instr_mem[13]=8'b00000000;
// instr_mem[14]=8'b00000000;
// instr_mem[15]=8'b00000000;
// instr_mem[16]=8'b00000000;
// instr_mem[17]=8'b00000000;
// instr_mem[18]=8'b00000000;
// instr_mem[19]=8'b00000001;

// instr_mem[20]=8'b01100000;
// instr_mem[21]=8'b00100011;

// instr_mem[22] = 8'b00010000;

// //cmov
// // 2 fn
// instr_mem[23]=8'b00100000; 
// // rA rB
// instr_mem[24]=8'b00110100; 

// //halt
// instr_mem[25] = 8'b00000000; 

////////////////////////////////Test Case 6////////////////////////////

// //opq , halt along with irmovq 

instr_mem[0]=8'b00110000;
instr_mem[1]=8'b11110011;
instr_mem[2]=8'b00000000;
instr_mem[3]=8'b00000000;
instr_mem[4]=8'b00000000;
instr_mem[5]=8'b00000000;
instr_mem[6]=8'b00000000;
instr_mem[7]=8'b00000000;
instr_mem[8]=8'b00000000;
instr_mem[9]=8'b00000100;
instr_mem[10]=8'b00110000;
instr_mem[11]=8'b11110010;
instr_mem[12]=8'b00000000;
instr_mem[13]=8'b00000000;
instr_mem[14]=8'b00000000;
instr_mem[15]=8'b00000000;
instr_mem[16]=8'b00000000;
instr_mem[17]=8'b00000000;
instr_mem[18]=8'b00000110;
instr_mem[19]=8'b00000000;
instr_mem[20]=8'b01100001;
instr_mem[21]=8'b00100011;

instr_mem[22]=8'b00000000;
end
  

endmodule