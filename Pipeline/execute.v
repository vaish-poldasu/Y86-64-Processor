`include "alu.v"
module execute(clk,E_stat,E_icode,E_ifun,E_valC,E_valA,E_valB,E_dstE,E_dstM,
               M_stat,M_icode,M_cnd,M_valE,M_valA,M_dstE,M_dstM,M_bubble,
               W_stat,e_valE,e_dstE,e_cnd,m_stat,SetCC);

//inputs
input clk, M_bubble, SetCC;
input [0:3] E_stat,m_stat, W_stat;
input [3:0] E_icode,E_ifun,E_dstE,E_dstM;
input [63:0] E_valC,E_valA,E_valB;

//outputs
output reg M_cnd;
output reg [0:3] M_stat;
output reg [3:0] M_icode, M_dstE,M_dstM,e_dstE;
output reg [63:0] M_valE,M_valA,e_valE;
output reg e_cnd=1;

reg [2:0] CC_out = 3'b000;      // o_f,s_f,z_f condition codes

wire overflow;
wire overflow1;

wire [63:0] valE_cmov, valE_CB,valE_opq, valE_inc, valE_dec;


//assigning condition codes   
wire z_f, s_f, o_f;
assign z_f = CC_out[0];
assign s_f = CC_out[1];
assign o_f = CC_out[2];

always @*
begin
    if (E_icode == 4'b0010 || E_icode == 4'b0111)
    begin
        // unconditional
        if (E_ifun == 4'b0000)
        begin          
            e_cnd = 1;
        end

        // less than equal to
        else if (E_ifun == 4'b0001) 
        begin    
            e_cnd = (o_f ^ s_f) | z_f;
        end
        
        // less than
        else if (E_ifun == 4'b0010)
        begin     
            e_cnd = o_f ^ s_f;
        end

        // equal
        else if (E_ifun == 4'b0011)
        begin    
            e_cnd = z_f;
        end

        // not equal
        else if (E_ifun == 4'b0100)
        begin     
            e_cnd = ~z_f;
        end

        // greater than equal to
        else if (E_ifun == 4'b0101)
        begin     
            e_cnd = ~(s_f ^ o_f);
        end

        // greater than
        else if (E_ifun == 4'b0110)
        begin     
            e_cnd = ~(s_f ^ o_f) & ~z_f;
        end
        e_dstE = e_cnd ? E_dstE : 4'hF;
    end
    else
    begin
        e_dstE = E_dstE;
    end
end

//ALU for executing instructions
alu func1(2'b0,E_valA,E_valB,valE_cmov,overflow1);
alu func2(E_ifun[1:0],E_valA,E_valB,valE_opq,overflow);
alu func3(2'b0,E_valC,E_valB,valE_CB,overflow1);
alu func4(2'b0,64'd1,E_valB,valE_inc,overflow1);
alu func5(2'b1,64'd1,E_valB,valE_dec,overflow1);


always @*
begin 
    // cmovx
    if (E_icode == 4'b0010)
    begin 
        e_valE = valE_cmov; 
    end

    // irmovq          
    else if (E_icode == 4'b0011)
    begin
        e_valE = valE_CB;
    end

    //rmmovq           
    else if (E_icode == 4'b0100)
    begin
        e_valE = valE_CB;
    end 

    // mrmovq          
    else if (E_icode == 4'b0101)
    begin
        e_valE = valE_CB;
    end

    // opq           
    else if (E_icode == 4'b0110)
    begin                           
        e_valE = valE_opq;
        if (SetCC)
        begin
            CC_out[2] = o_f;
            CC_out[1] = e_valE[63];
            CC_out[0] = e_valE ? 0 : 1;
        end
    end

    // call
    else if (E_icode == 4'b1000)
    begin
       e_valE = valE_dec;
    end

    // ret          
    else if (E_icode == 4'b1001)
    begin 
          e_valE = valE_inc;
    end

    // pushq         
    else if (E_icode == 4'b1010)
    begin
        e_valE = valE_dec;
    end
    // popq         
    else if (E_icode == 4'b1011)
    begin
       e_valE = valE_inc;
    end          
    else
    begin
        e_valE = 0;
    end
end


always@(posedge clk)
begin
    if(M_bubble)
    begin
        M_stat <= 4'b1000;
        M_icode <= 4'b001;
        M_cnd <= 1;
        M_valE <= 0;
        M_valA <= 0;
        M_dstE <= 4'hF;
        M_dstM <= 4'hF;
    end
    else
    begin
        M_stat <= E_stat;
        M_icode <= E_icode;
        M_cnd <= e_cnd;
        M_valE <= e_valE;
        M_valA <= E_valA;
        M_dstE <= e_dstE;
        M_dstM <= E_dstM;
    end
end


endmodule