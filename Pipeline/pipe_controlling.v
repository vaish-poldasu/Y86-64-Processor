module pipe_controlling(D_icode, d_srcA, d_srcB, E_icode, E_dstM, e_cnd,M_icode, m_stat, W_stat,
                         F_stall,D_stall,D_bubble,E_bubble,M_bubble,W_stall, SetCC);


//inputs
input [3:0] D_icode,E_icode,M_icode,d_srcA,d_srcB,E_dstM;
input [0:3] m_stat, W_stat;
input e_cnd;

//outputs
output reg F_stall, D_stall, D_bubble, E_bubble, M_bubble, W_stall;
output reg SetCC;

always@*
begin
    F_stall = 0;D_stall = 0;D_bubble = 0;
    E_bubble = 0;M_bubble = 0;W_stall = 0;
    SetCC = 1;
    if(E_icode==4'b0111 & !e_cnd)
    begin
        D_bubble = 1;
        E_bubble = 1;
    end
    else if((E_icode == 4'b0101 | E_icode == 4'b1011) & (E_dstM==d_srcA | E_dstM==d_srcB))
    begin
        F_stall = 1;
        D_stall = 1;
        E_bubble = 1;
    end
    else if(E_icode == 4'b1001 | M_icode == 4'b1001 | D_icode == 4'b1001)
    begin
        F_stall = 1;
        D_bubble = 1;
    end
    else if(E_icode == 4'b0000 | m_stat!=4'b1000 | W_stat!=4'b1000)
    begin
        SetCC = 0;
    end

    end

endmodule

