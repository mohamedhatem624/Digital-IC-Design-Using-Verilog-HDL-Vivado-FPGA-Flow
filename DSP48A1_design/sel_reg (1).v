module sel_reg(D,clk,E,rst,out);
parameter size=18;
parameter z=1;
parameter RSTTYPE="SYNC";
input [size-1:0] D;
input clk,rst,E;
output [size-1:0]out;
reg [size-1:0]temp;
generate
    if (z) begin
        if(RSTTYPE=="SYNC")begin
            always @(posedge clk ) begin
                if(rst)temp<=0; 
                else if(E)temp<=D;
            end
        end
        else begin
            always @(posedge clk or posedge rst) begin
                if(rst)temp<=0;
                else if(E)temp<=D;
            end
        end
        assign out = temp;
    end
    else assign out=D;
endgenerate
endmodule