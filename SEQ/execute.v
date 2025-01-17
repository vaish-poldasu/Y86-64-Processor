`include "alu.v"

module execute(cnd, icode, ifun, valA,valB, valC, valE, cond_c_in,zero_f,sign_f,overflow_f);
//inputs
input [3:0] icode, ifun;
input [63:0] valC, valA, valB;
input [2:0] cond_c_in;

//outputs
output reg [63:0] valE;
output reg cnd;
output reg zero_f,sign_f,overflow_f; //condition codes
      
wire overflow;
wire overflow1;

//input condition codes   
wire z_f, s_f, o_f;
assign z_f = cond_c_in[0];
assign s_f = cond_c_in[1];
assign o_f = cond_c_in[2];

wire [63:0] valE_cmov, valE_CB, valE_opq, valE_inc, valE_dec;

always @* begin
    cnd=0;
    //for conditional instructions
    if (icode == 4'b0010 || icode == 4'b0111) begin
        if (ifun == 4'b0000) begin
            cnd = 1; // unconditional
        end
        
        // less than equal to
        else if (ifun == 4'b0001) begin
            cnd = (o_f ^ s_f) || z_f; 
        end

        // less than
        else if (ifun == 4'b0010) begin
            cnd = o_f ^ s_f; 
        end

        // equal to
        else if (ifun == 4'b0011) begin
            cnd = z_f; 
        end

        // not equal to
        else if (ifun == 4'b0100) begin
            cnd = ~z_f; 
        end

        //greater than equal to
        else if (ifun ==4'b0101) begin
            cnd = ~(s_f ^ o_f); 
        end
       
        //greater than
        else if (ifun == 4'b0110) begin
            cnd = ~(s_f ^ o_f) & ~z_f; 
        end
    end
end


//ALU for executing instructions
alu alu1( 2'b0, valA, valB,valE_cmov, overflow1);
alu alu2(ifun[1:0], valA, valB,valE_opq, overflow);
alu alu3( 2'b0, valC, valB,valE_CB, overflow1);
alu alu4( 2'b0, 64'd8, valB,valE_inc, overflow1);
alu alu5( 2'b1, valB,64'd8,valE_dec, overflow1);

always @* begin
    // cmovx
    if (icode == 4'b0010) begin 
        valE = valE_cmov;
    end

    // irmovq, rmmovq, mrmovq
    else if (icode == 4'b0011 || icode == 4'b0100 || icode == 4'b0101) begin 
        valE = valE_CB;
    end

    // opq
    else if (icode == 4'b0110) begin 
        valE = valE_opq;
        //setting condition codes
        overflow_f <= overflow;
        sign_f <= valE[63];
        zero_f <= valE ? 0 : 1;
    end

    // call and pushq
    else if (icode == 4'b1000 || icode == 4'b1010) begin 
        valE = valE_dec;
    end

    // return and popq
    else if (icode == 4'b1001 || icode == 4'b1011) begin 
        valE = valE_inc;
    end

    else begin
        valE = 0;
    end
end

endmodule


