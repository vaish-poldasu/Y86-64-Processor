`include "fetch.v"
`include "decode_wb.v"
`include "execute.v"
`include "memory.v"
`include "pipe_controlling.v"

module processor;
reg clk;
reg[63:0] F_predPC;
reg[7:0] instr_mem[0:2048];
reg [0:3] stat = 4'b1000;    // AOK, HLT, ADR, INS

wire F_stall, D_stall, D_bubble, E_bubble, M_bubble, W_stall, SetCC;
wire M_cnd, e_cnd;
wire [0:3] D_stat,E_stat,M_stat,W_stat,m_stat;
wire [3:0] D_icode, D_ifun, D_rA, D_rB, d_srcA, d_srcB,
           E_icode, E_ifun, E_dstE, E_dstM, E_srcA, E_srcB, e_dstE,
           M_icode, M_dstE, M_dstM,
           W_icode, W_dstE, W_dstM ;

wire [63:0] reg_0,reg_1,reg_2,reg_3,reg_4,reg_5,reg_6,reg_7,
            reg_8,reg_9,reg_10,reg_11,reg_12,reg_13,reg_14;

wire [63:0] f_predPC, D_valC, D_valP,
            E_valC, E_valA, E_valB, e_valE,
            M_valE, M_valA, m_valM,
            W_valE, W_valM;

 // stat is calculated at every stage of the processor
always@(W_stat)
begin
    stat = W_stat;
end  

  // always halt logic
always@(stat) 
begin
    if(stat==4'b0001) begin
      $display("Instruction Error - INS");
      $finish;
    end
    
    else if(stat==4'b0010) begin
      $display("Address Error - ADR");
      $finish;
    end

    else if(stat==4'b0100) begin
      $display("Halting");
      $finish;
    end    
end

always #10 clk = ~clk;
always @(posedge clk) F_predPC <= f_predPC;

fetch fetch(.clk(clk), .f_predPC(f_predPC), .F_predPC(F_predPC),.D_stat(D_stat), .D_icode(D_icode), .D_ifun(D_ifun), .D_rA(D_rA), .D_rB(D_rB), .D_valC(D_valC),.D_valP(D_valP),
            .M_icode(M_icode), .M_cnd(M_cnd), .M_valA(M_valA), .W_icode(W_icode), .W_valM(W_valM),
            .F_stall(F_stall),.D_stall(D_stall),.D_bubble(D_bubble));


decode_wb decode_wb(.clk(clk), .D_stat(D_stat),.D_icode(D_icode), .D_ifun(D_ifun), .D_rA(D_rA), .D_rB(D_rB), .D_valC(D_valC),.D_valP(D_valP),
                 .d_srcA(d_srcA),.d_srcB(d_srcB), .E_bubble(E_bubble), .E_stat(E_stat), .E_icode(E_icode), .E_ifun(E_ifun),.E_valC(E_valC), 
                 .E_valA(E_valA), .E_valB(E_valB), .E_dstE(E_dstE), .E_dstM(E_dstM), .E_srcA(E_srcA), .E_srcB(E_srcB), .e_dstE(e_dstE), .e_valE(e_valE),
                 .M_dstE(M_dstE), .M_dstM(M_dstM), .M_valE(M_valE), .m_valM(m_valM), .W_dstE(W_dstE), .W_dstM(W_dstM), .W_valE(W_valE),.W_valM(W_valM),.W_icode(W_icode),
                 .reg_0(reg_0),.reg_1(reg_1),.reg_2(reg_2),.reg_3(reg_3),.reg_4(reg_4),.reg_5(reg_5),.reg_6(reg_6),.reg_7(reg_7),
                 .reg_8(reg_8),.reg_9(reg_9),.reg_10(reg_10),.reg_11(reg_11),.reg_12(reg_12),.reg_13(reg_13),.reg_14(reg_14));

execute execute(.clk(clk),.E_stat(E_stat),.E_icode(E_icode),.E_ifun(E_ifun),.E_valC(E_valC),.E_valA(E_valA),.E_valB(E_valB),.E_dstE(E_dstE),.E_dstM(E_dstM),
               .M_stat(M_stat),.M_icode(M_icode),.M_cnd(M_cnd),.M_valE(M_valE),.M_valA(M_valA),.M_dstE(M_dstE),.M_dstM(M_dstM),.M_bubble(M_bubble),
               .W_stat(W_stat),.e_valE(e_valE),.e_dstE(e_dstE),.e_cnd(e_cnd),.m_stat(m_stat),.SetCC(SetCC));

memory memory(.clk(clk), .M_stat(M_stat), .M_icode(M_icode), .M_cnd(M_cnd), .M_valE(M_valE), .M_valA(M_valA), .M_dstE(M_dstE), .M_dstM(M_dstM),
               .m_valM(m_valM),.m_stat(m_stat),.W_stat(W_stat),.W_icode(W_icode),.W_valE(W_valE),.W_valM(W_valM),.W_dstE(W_dstE),.W_dstM(W_dstM),.W_stall(W_stall));

pipe_controlling pipe_controlling(.D_icode(D_icode), .d_srcA(d_srcA), .d_srcB(d_srcB), .E_icode(E_icode), .E_dstM(E_dstM), .e_cnd(e_cnd),.M_icode(M_icode), .m_stat(m_stat), .W_stat(W_stat),
                         .F_stall(F_stall),.D_stall(D_stall),.D_bubble(D_bubble),.E_bubble(E_bubble),.M_bubble(M_bubble),.W_stall(W_stall), .SetCC(SetCC));



initial begin

    $dumpfile("processor.vcd");
    $dumpvars(0,processor);
    F_predPC=64'd0;
    clk=0;

   $monitor("clk=%d f_predPC=%d F_predPC=%d D_icode=%d,E_icode=%d, M_icode=%d, ifun=%d,rax=%d,rdx=%d,rbx=%d,rcx=%d\n",clk,f_predPC,F_predPC, D_icode,E_icode,M_icode,D_ifun,reg_0,reg_2,reg_3,reg_1);
   //$monitor("clk=%d f_predPC=%d F_predPC=%d rax=%d rdx=%d rbx=%d rsp=%d rsi=%d\n",clk,f_predPC,F_predPC,reg_0,reg_2,reg_3,reg_4,reg_6);
end
endmodule

