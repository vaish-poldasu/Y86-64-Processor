`include "fetch.v"
`include "decode_wb.v"

module decode_wb_test;
reg clk;
  
wire [3:0] D_icode, D_stat, D_ifun, D_rA, D_rB;
wire [63:0] D_valC,D_valP, f_predPC;

wire [0:3] E_stat;
wire [3:0] E_icode,E_ifun, E_dstE,E_dstM,E_srcA,E_srcB,d_srcA, d_srcB;
wire [63:0] E_valC,E_valA,E_valB;
wire [63:0] reg_0,reg_1,reg_2,reg_3,reg_4,reg_5,reg_6,reg_7,reg_8,reg_9,reg_10,reg_11,reg_12,reg_13,reg_14; 

reg [3:0] M_icode,W_icode;
reg [3:0] e_dstE,M_dstE,M_dstM,W_dstE,W_dstM;
reg [63:0] M_valA, F_predPC_in;
reg [63:0] e_valE,M_valE,m_valM,W_valE,W_valM; 
reg [7:0] instr_mem[0:20480];

fetch fetch(.D_icode(D_icode),.D_ifun(D_ifun),.D_rA(D_rA),.D_rB(D_rB),
    .D_valC(D_valC),.D_valP(D_valP),.D_stat(D_stat),.f_predPC(f_predPC),
    .M_icode(M_icode),.M_cnd(M_cnd),.M_valA(M_valA),.W_icode(W_icode),
    .W_valM(W_valM),.F_predPC(F_predPC_in),.clk(clk)
    );

decode_wb decode_wb(clk, D_stat, D_icode, D_ifun, D_rA, D_rB, D_valC,D_valP,
                 d_srcA, d_srcB, E_bubble, E_stat, E_icode, E_ifun, E_valC, 
                 E_valA, E_valB, E_dstE, E_dstM, E_srcA, E_srcB, e_dstE, e_valE,
                 M_dstE, M_dstM, M_valE, m_valM, W_dstE, W_dstM, W_valE,W_valM,W_icode,
                 reg_0,reg_1,reg_2,reg_3,reg_4,reg_5,reg_6,reg_7,
                 reg_8,reg_9,reg_10,reg_11,reg_12,reg_13,reg_14 );

always @(D_icode) begin
    if(D_icode==0) 
      $finish;
  end

  always @(posedge clk) F_predPC_in <= f_predPC;

  always #10 clk = ~clk;

  initial begin 
    clk=1;
    F_predPC_in=64'd32;
end
  initial 
		$monitor("clk=%d F_predPC=%d F_predPC_in=%d icode=%b ifun=%b valA=%d valB=%d,valC=%d\n",clk,f_predPC,F_predPC_in, E_icode,E_ifun,E_valA,E_valB,E_valC);
    //$monitor("%d %d %d %d %d %d %d %d %d %d %d %d %d %d\n", reg_0,reg_1,reg_2,reg_3,reg_4,reg_5,reg_6,reg_7,reg_8,reg_9,reg_10,reg_11,reg_12,reg_13,reg_14);

endmodule