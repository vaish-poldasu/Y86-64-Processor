module fetch(clk, f_predPC, F_predPC, D_stat, D_icode, D_ifun, D_rA, D_rB, D_valC, D_valP,
             M_icode, M_cnd, M_valA, W_icode, W_valM, F_stall, D_stall, D_bubble);

    //inputs
    input clk,M_cnd;                             
    input [3:0] M_icode,W_icode;
    input [63:0] M_valA,W_valM,F_predPC;               
    input F_stall,D_stall,D_bubble;
    
    //outputs
    output reg [3:0] D_icode, D_ifun, D_rA, D_rB;              
    output reg [63:0] D_valC,D_valP,f_predPC;                  
    output reg [0:3] D_stat=4'b1000;  

    reg [3:0] icode, ifun,rA, rB;                        
    reg [63:0] valC,valP;                                 
    reg [0:3] stat;                  // AOK, HLT, ADR, INS
    reg [0:79] instr;                   
    reg [7:0] instr_mem[0:2048];       
    reg [63:0] PC;  
    reg instr_mem_error=0, instr_valid=1;                          

    initial 
        PC = F_predPC;    //predicted PC_value

    always@*
    begin
        // Jump not taken
        if(M_icode==4'b0111 & !M_cnd) 
            PC = M_valA;
        // Return 
        else if(W_icode==4'b1001)      
            PC = W_valM;
        else
            PC = F_predPC;         
    end

    always@* 
    begin 

        instr_valid=1;
        if(PC>2048)
        begin
            instr_mem_error=1;
        end
        instr = {instr_mem[PC],instr_mem[PC+1],instr_mem[PC+2],
                 instr_mem[PC+3],instr_mem[PC+4],instr_mem[PC+5],
                 instr_mem[PC+6],instr_mem[PC+7],instr_mem[PC+8],instr_mem[PC+9]};
        {icode, ifun} = instr[0:7];
        
        // halt
        if (icode == 4'b0000)
        begin
            valP = PC;              
            f_predPC = valP;
        end

        // nop
        else if (icode == 4'b0001) 
        begin
            valP = PC + 1;         
            f_predPC = valP;
        end

        // cmovq
        else if (icode == 4'b0010) 
        begin 
            {rA, rB} = instr[8:15];
            valP = PC + 2;
            f_predPC = valP;
        end

        // irmovq
        else if (icode == 4'b0011) 
        begin 
            {rA, rB, valC} = instr[8:79];
            valP = PC + 10;
            f_predPC = valP;
        end

        // rmmovq
        else if (icode == 4'b0100) 
        begin 
            {rA, rB, valC} = instr[8:79];
            valP = PC + 10;
            f_predPC = valP;
        end

        // mrmovq
        else if (icode == 4'b0101)
        begin 
            {rA, rB, valC} = instr[8:79];
            valP = PC + 10;
            f_predPC = valP;
        end

        // OPq
        else if (icode == 4'b0110) 
        begin 
            {rA, rB} = instr[8:15];
            valP = PC + 2;
            f_predPC = valP;
        end

        // jxx
        else if (icode == 4'b0111)
        begin 
            valC = instr[8:71];
            valP = PC + 9;
            f_predPC = valC;
        end

        // call
        else if (icode == 4'b1000)
        begin 
            valC = instr[8:71];
            valP = PC + 9;
            f_predPC = valC;
        end

        // ret
        else if (icode == 4'b1001) 
        begin
            valP = PC + 1;
        end

        // pushq
        else if (icode == 4'b1010)
        begin
            {rA, rB} = instr[8:15];
            valP = PC + 2;
            f_predPC = valP;
        end

        // popq
        else if (icode == 4'b1011) 
        begin 
            {rA, rB} = instr[8:15];
            valP = PC + 2;
            f_predPC = valP;
        end
        else
        begin                     
            instr_valid = 1'b0;
        end

        if(instr_valid==0)
        stat = 4'b0001;
        else if(instr_mem_error==1)
        begin
        stat = 4'b0010;
        end
        else if(icode==4'b0000)
        stat = 4'b0100;
        else
        stat = 4'b1000;
    end

     // Assigning to decode registers
    always@(posedge clk)
    begin
        if(F_stall)
        begin
            PC = F_predPC;
        end

        if(D_stall)
        begin
        end
        else if(D_bubble)
        begin
            D_icode <= 4'b0001;
            D_ifun <= 4'b0000;
            D_rA <= 4'b0000;
            D_rB <= 4'b0000;
            D_valC <= 64'b0;
            D_valP <= 64'b0;
            D_stat <= 4'b1000;
        end
        else
        begin
            D_icode <= icode;
            D_ifun <= ifun;
            D_rA <= rA;
            D_rB <= rB;
            D_valC <= valC;
            D_valP <= valP;
            D_stat <= stat;
        end
    end

    initial
    begin

   // Reference for 1.txt
   //opq , halt along with irmovq  
   //$readmemb("test1_pipe.txt", instr_mem);

  //rrmovq , rmmovq , nop , halt along with opq
  //$readmemb("test2_pipe.txt", instr_mem);

  //jump, halt along with irmovq
  //$readmemb("test3_pipe.txt", instr_mem);

   //opq , halt along with irmovq 
  //$readmemb("test4_pipe.txt", instr_mem);

  //cmovxx , halt along with irmovq and opq
  //$readmemb("test5_pipe.txt", instr_mem);

   //opq , halt along with irmovq 
  //$readmemb("test6_pipe.txt", instr_mem);

  //push, pop, halt along with irmovq
  //$readmemb("test7_pipe.txt", instr_mem);

  //irmovq, mrmovq, opq along with halt
  //$readmemb("test8_pipe.txt", instr_mem);

    //call, return, rrmovq along with conditional and unconditional jumps
    $readmemb("test9_pipe.txt", instr_mem);

end
endmodule