module Single_Port_Async_RAM (din,clk,rst_n,rx_valid,dout,tx_valid);

parameter MEM_DEPTH = 256;
parameter ADDR_SIZE = 8;

input [9:0] din;
input clk, rx_valid, rst_n; //active low synchronous

//Vivado may not be accepting the asynchronous control signals and may not map them directly on the FPGA board as 
//FSM or RAM. If you experience this during implementation, then change the reset to be synchronized with the clock.
//so  used the active low synch rst
output reg [7:0] dout;
output reg tx_valid;

reg [7:0] RAM [MEM_DEPTH - 1 : 0];

// Two Address for write and read respectively
reg [ADDR_SIZE - 1 : 0] Wr_Addr, Rd_Addr;

// read/write-----> address
always @(posedge clk) begin
    if (~rst_n) begin
        dout <= 0;
        tx_valid <= 0;
        Wr_Addr <= 0;
        Rd_Addr <= 0;
    end
    else begin
        //to "Read Data" tx_valid must be -> 1 in order to read data from the SPI slave 
        tx_valid <= (din[9] & din[8] & rx_valid)? 1 : 0;
        //rx_valid -> 1 , the din[7:0] is accepted
        if (rx_valid) begin
            case (din[9:8])
                2'b00 : Wr_Addr <= din[7:0];      // Write Address
                2'b01 : RAM[Wr_Addr] <= din[7:0]; // Write Data
                2'b10 : Rd_Addr <= din[7:0];      // Read Address
                2'b11 : dout <= RAM[Rd_Addr];     // Read Data
            endcase
        end
    end
end
endmodule