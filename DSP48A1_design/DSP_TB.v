module DSP_TB();
reg [17:0]A,B,D;
reg [47:0]C,Pcin;
reg [17:0]Bcin;
reg clk,carryin;
reg [7:0]opmode;
reg rstA,rstB,rstM,rstP,rstC,rstD,rstcarryin,rstopmode;
reg ceA,ceB,ceM,ceP,ceC,ceD,cecarryin,ceopmode;



wire [17:0]Bcout_dut;
wire [47:0]Pcout_dut,P_dut;
wire [35:0]M_dut;
wire carryout_dut,carryoutF_dut;


DSP48A1 dut(A,B,Bcin,C,D,carryin,M_dut,P_dut,carryout_dut,carryoutF_dut,clk,opmode,ceA,ceB,ceC,cecarryin,ceD,ceM,ceopmode,ceP,rstA,rstB,rstC,rstcarryin,rstD,rstM,rstopmode,rstP,Bcout_dut,Pcin,Pcout_dut);

initial begin
    clk=0;
    forever begin
        #5;
        clk=~clk;
    end
end

initial begin
    rstA=1;
    rstB=1;
    rstM=1;
    rstP=1;
    rstC=1;
    rstD=1;
    rstcarryin=1;
    rstopmode=1;
    repeat(50)begin
        ceA=$random;
        ceB=$random;
        ceM=$random;
        ceP=$random;
        ceC=$random;
        ceD=$random;
        cecarryin=$random;
        ceopmode=$random;
        A=$random;
        B=$random;
        D=$random;
        C=$random;
        Pcin=$random;
        Bcin=$random;
        carryin=$random;
        opmode=$random;
        @(negedge clk);
        if(M_dut!=0 || P_dut!=0 || Bcout_dut!=0 || carryout_dut!=0 || carryoutF_dut!=0 || P_dut!=0)begin
            $display("Error");
            $stop;
        end
    end
    rstA=0;
    rstB=0;
    rstM=0;
    rstP=0;
    rstC=0;
    rstD=0;
    rstcarryin=0;
    rstopmode=0;
    ceA=1;
    ceB=1;
    ceM=1;
    ceP=1;
    ceC=1;
    ceD=1;
    cecarryin=1;
    ceopmode=1;
    A=2;
    C=0;
    D=1;
    B=1;
    opmode[6] = 0; //adder1 = D+B
    opmode[4] =1 ; //adder1_mux_out
    opmode[1:0] =1;
    opmode[3:2] = 0;
    opmode[7]= 0;
    carryin =0;
    @(negedge clk);
    //output Bcout =2 , p=2 ,M =2 ,PCout =2 
    repeat(5000) begin
        A=$random;
        B=$random;  
        D=$random;
        C=$random;
        Pcin=$random;
        Bcin=$random;
        carryin=$random;
        opmode=$random;
        @(negedge clk);
    end
    $stop; 
end

initial begin
    $monitor("A = %b\t B = %b\t C = %b\t D = %b\t PCin = %b\t carryin = %b\t opmode =%b\t \nBcout = %b\t PCout =%b\t P = %b\t M =%b\t Carry_Out = %b\t Carry_OutF = %b",A,B,C,D,Pcin,carryin,opmode,Bcout_dut,Pcout_dut,P_dut,M_dut,carryout_dut,carryoutF_dut);
end
endmodule