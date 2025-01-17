module fetch(clk, PC, instr, icode, ifun, rA, rB, valC, valP, ins_mem_error, valid_instr,halt);
//inputs
input clk;                  // Clock input
input [63:0] PC;            // Program Counter
input [0:79] instr;         // 10 bytes are required instruction encodings

//outputs
output reg [3:0] icode;       //Instruction code
output reg [3:0] ifun;        //Function code
output reg [3:0] rA;          //Register A(src)
output reg [3:0] rB;          //Register B(dest)
output reg [63:0] valC;       // Immediate value 
output reg [63:0] valP;       // Next program counter
output reg ins_mem_error = 0;         // Instruction memory error flag
output reg valid_instr = 1 ;      // Valid instruction flag
output reg halt = 0;              //halt the program

always @(*)
begin
   if(PC>20480)
    begin
        ins_mem_error=1;
    end 
end

always @(*) 
begin
    icode = instr[0:3];
    ifun = instr[4:7];
    
    //halt
    if(icode == 4'b0000)
    begin
        halt = 1;
        valP = PC + 64'd1;
    end

    //nop
    else if(icode == 4'b0001)
    begin
        valP = PC + 64'd1;
    end

    //cmovq
    else if(icode == 4'b0010)
    begin
        rA = instr[8:11];
        rB = instr[12:15];
        valP = PC + 64'd2;
    end

    //irmovq
    else if(icode == 4'b0011)
    begin
        rA = instr[8:11];
        rB = instr[12:15];
        valC = instr[16:79]; //8 bytes for constant value
        valP = PC + 64'd10;
    end

    //rmmovq
    else if(icode == 4'b0100)
    begin
        rA = instr[8:11];
        rB = instr[12:15];
        valC = instr[16:79]; //8 bytes for constant value
        valP = PC + 64'd10;
    end

    //mrmovq
    else if(icode == 4'b0101)
    begin
        rA = instr[8:11];
        rB = instr[12:15];
        valC = instr[16:79]; //8 bytes for constant value
        valP = PC + 64'd10;
    end

    //opq
    else if(icode == 4'b0110)
    begin
        rA = instr[8:11];
        rB = instr[12:15];
        valP = PC + 64'd2;
    end

    //jxx
    else if(icode == 4'b0111)
    begin
        valC = instr[8:71];
        valP = PC + 64'd9;
    end

    //call
    else if(icode == 4'b1000)
    begin
        valC = instr[8:71];
        valP = PC + 64'd9;
    end

    //ret
    else if(icode == 4'b1001)
    begin
         valP = PC + 64'd1;
    end

    //pushq
    else if(icode == 4'b1010)
    begin
        rA = instr[8:11];
        rB = instr[12:15];
        valP = PC + 64'd2;
    end

    //popq
    else if(icode == 4'b1011)
    begin
        rA = instr[8:11];
        rB = instr[12:15];
        valP = PC + 64'd2;
    end
  
    else
    begin
        valid_instr = 1'b0;
    end

end

endmodule