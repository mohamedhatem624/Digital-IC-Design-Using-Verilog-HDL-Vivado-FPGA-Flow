module DSP48A1(A,B,Bcin,C,D,carryin,M,P,carryout,carryoutF,clk,opmode,ceA,ceB,ceC,cecarryin,ceD,ceM,ceopmode,ceP,rstA,rstB,rstC,rstcarryin,rstD,rstM,rstopmode,rstP,Bcout,Pcin,Pcout);
//parameters
parameter A0REG = 0; 
parameter A1REG = 1;
parameter B0REG = 0; 
parameter B1REG = 1;
parameter CREG = 1;
parameter DREG = 1;
parameter MREG = 1;
parameter PREG = 1;
parameter CARRYINREG = 1;
parameter CARRYOUTREG = 1;
parameter OPMODEREG = 1;
parameter CARRYINSEL ="OPMODE5";
parameter B_INPUT ="DIRECT";
parameter RSTTYPE ="SYNC";
//inputs
input [17:0]A,B,D;
input [47:0]C,Pcin;
input [17:0]Bcin;
input clk,carryin;
input [7:0]opmode;
input rstA,rstB,rstM,rstP,rstC,rstD,rstcarryin,rstopmode;
input ceA,ceB,ceM,ceP,ceC,ceD,cecarryin,ceopmode;
//outputs
output [17:0]Bcout;
output [47:0]Pcout,P;
output [35:0]M;
output carryout,carryoutF;
//wires
wire [17:0]Bmux_out;
wire [17:0]A0REG_out,B0REG_out,DREG_out,A1REG_out,adder1,adder1_mux_out,B1REG_out;
wire [47:0]CREG_out,PREG_out;
wire [35:0]multiply_out,MREG_out;
wire carryin_MUX_out,CIN;
wire [7:0] opmode_reg_out;
wire [47:0]DAB_conc;
wire [47:0]Xmux_out,Zmux_out,adder2_out;
wire [35:0] M_buff ;
wire carry ;
//reg
reg [47:0]reg_X_temp,reg_Z_temp;

//________________________________________________________________
// verilog design
//________________________________________________________________

assign Bmux_out=(B_INPUT =="DIRECT")? B :(B_INPUT =="CASCADE")? Bcin:0;

sel_reg #(18,A0REG,RSTTYPE) _A0REG(A,clk,ceA,rstA,A0REG_out);//A0REG
sel_reg #(18,A1REG,RSTTYPE) _A1REG(A0REG_out,clk,ceA,rstA,A1REG_out);//A1REG
sel_reg #(18,B0REG,RSTTYPE) _B0REG(Bmux_out,clk,ceB,rstB,B0REG_out);//B0REG
sel_reg #(48,CREG,RSTTYPE) _CREG (C,clk,ceC,rstC,CREG_out);//CREG
sel_reg #(18,DREG,RSTTYPE) _DREG (D,clk,ceD,rstD,DREG_out);//DREG
sel_reg #(8,OPMODEREG,RSTTYPE) _OPMODEREG(opmode,clk,ceopmode,rstopmode,opmode_reg_out);//opcodereg

assign adder1=(opmode_reg_out[6])? (DREG_out-B0REG_out) : (DREG_out+B0REG_out);//first adder
assign adder1_mux_out=(opmode_reg_out[4])? adder1 : B0REG_out;

sel_reg #(18,B1REG,RSTTYPE) _B1REG(adder1_mux_out,clk,ceB,rstB,B1REG_out); //B1REG

assign Bcout=B1REG_out;

assign multiply_out=A1REG_out*B1REG_out;

sel_reg #(36,MREG,RSTTYPE) _MREG (multiply_out,clk,ceM,rstM,MREG_out);//MREG
assign M_buff=MREG_out;
assign M = M_buff;

assign carryin_MUX_out=(CARRYINSEL =="OPMODE5")? opmode_reg_out[5]:(CARRYINSEL =="CARRYIN")? carryin : 0;

sel_reg #(1,CARRYINREG,RSTTYPE) _CYI(carryin_MUX_out,clk,cecarryin,rstcarryin,CIN);
//________________________________________________________________Xmux
always @(*) begin
    case (opmode_reg_out[1:0])
        0:reg_X_temp=0;
        1:reg_X_temp={12'b0,MREG_out};
        2:reg_X_temp=Pcout;
        3:reg_X_temp=DAB_conc;
    endcase
end
assign DAB_conc={DREG_out[11:0],A1REG_out,B1REG_out};
assign Xmux_out=reg_X_temp;
//________________________________________________________________Zmux
always @(*) begin
    case (opmode_reg_out[3:2])
        0:reg_Z_temp=0;
        1:reg_Z_temp=Pcin;
        2:reg_Z_temp=Pcout;
        3:reg_Z_temp=CREG_out;
    endcase
end
assign Zmux_out=reg_Z_temp;
assign {carry,adder2_out}=(opmode_reg_out[7])?(Zmux_out-(Xmux_out+carryin)):(Zmux_out+Xmux_out+carryin);

sel_reg #(48,PREG,RSTTYPE) _PREG (adder2_out,clk,ceP,rstP,P);

assign Pcout=P;

sel_reg #(1,CARRYOUTREG,RSTTYPE) _CARRYOUTREG (carry,clk,cecarryin,rstcarryin,carryout);
assign carryoutF=carryout;
assign Pcout=P;
endmodule