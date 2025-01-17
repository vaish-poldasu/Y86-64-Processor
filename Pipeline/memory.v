module memory(clk, M_stat, M_icode, M_cnd, M_valE, M_valA, M_dstE, M_dstM,
               m_valM,m_stat,W_stat,W_icode,W_valE,W_valM,W_dstE,W_dstM,W_stall);

//inputs
input clk, M_cnd, W_stall;
input [0:3] M_stat;
input [3:0] M_icode, M_dstE, M_dstM;
input [63:0] M_valE, M_valA;

//outputs
output reg [0:3] W_stat, m_stat;
output reg [3:0] W_icode, W_dstE, W_dstM;
output reg [63:0] m_valM, W_valE, W_valM;

reg mem_read;
reg [63:0] data_memory[0:1023];
reg data_mem_error = 0;

always @*
begin
    if(data_mem_error)
        m_stat = 4'b0010;
    else
        m_stat = M_stat;
end

always @*
begin
    // rmmovq, call, pop
    if(M_icode == 4'b0100 | M_icode == 4'b1000 | M_icode == 4'b1011)
    begin
       mem_read = 1;
    end
    else
    begin
        mem_read = 0;
    end
end

always@(posedge clk)
begin
    if(M_valE > 1023 & mem_read)
    begin
        data_mem_error = 1;
    end
    else
    begin

        // rmmovq
        if(M_icode == 4'b0100)
        begin
           data_memory[M_valE] <= M_valA; 
        end

        // mrmovq
        if(M_icode == 4'b0101)
        begin
           m_valM = data_memory[M_valE]; 
        end

        // call
        if(M_icode == 4'b1000)
        begin
           data_memory[M_valE] <= M_valA;
        end

        // return
        if(M_icode == 4'b1001)
        begin
           m_valM = data_memory[M_valA]; 
        end

        // pushq
        if(M_icode == 4'b1010)
        begin
           data_memory[M_valE] <= M_valA; 
        end

        // popq
        if(M_icode == 4'b1011)
        begin
           m_valM = data_memory[M_valA]; 
        end

    end
    
end

always@(posedge clk)
begin
    if(W_stall)
    begin
    
    end
    else
    begin
        W_stat <= m_stat;
        W_icode <= M_icode;
        W_valE <= M_valE;
        W_valM <= m_valM;
        W_dstE <= M_dstE;
        W_dstM <= M_dstM;
    end
end
endmodule

