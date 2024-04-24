module SPI_Slave_Interface (MOSI,MISO,SS_n,clk,rst_n,rx_data,rx_valid,tx_data,tx_valid);

parameter IDLE = 3'b000;
parameter CHK_CMD = 3'b001;
parameter WRITE = 3'b010;
parameter READ_ADD = 3'b011;
parameter READ_DATA = 3'b100;

//FSM Encoding Method ----->GRAY

(* fsm_encoding = "gray" *)

// Input Declaration
input MOSI, SS_n, clk, rst_n, tx_valid; //Active Low SYNC rst
input [7:0] tx_data;

output reg MISO, rx_valid;
output reg [9:0] rx_data;

//ensure that Read Address Comes 1st and Read Data Comes 2nd
reg rd_addr_recieved; //high ---> READ SIGNAL IS RECEIVED

reg [2:0] cs, ns; 
reg[3:0] counter;


// State Memory Logic
always @(posedge clk) begin
    if (~rst_n)
        cs <= IDLE;
    else
        cs <= ns;
end

// Next State Logic
always @(*) begin
    case (cs)
        IDLE : 
            begin
                if (SS_n)
                    ns = IDLE;
                else
                    ns = CHK_CMD;
            end
        CHK_CMD : 
            begin
                if (SS_n)
                    ns = IDLE;
                else if (~MOSI)
                    ns = WRITE;
                else if (~rd_addr_recieved)
                    ns = READ_ADD;
                else
                    ns = READ_DATA;
            end
        WRITE : 
            begin
                if (SS_n)
                    ns = IDLE;
                else
                    ns = WRITE;
            end
        READ_ADD : 
            begin
                if (SS_n)
                    ns = IDLE;
                else
                    ns = READ_ADD;
            end
        READ_DATA : 
            begin
                if (SS_n)
                    ns = IDLE;
                else
                    ns = READ_DATA;
            end
        default : ns = IDLE; 
    endcase
end
//output logic
always @(posedge clk) begin
    if (~rst_n) begin
        rx_data <= 0;
        rx_valid <= 0;
        rd_addr_recieved <= 0;
        MISO <= 0;
        counter <= 0;
    end
    else begin
        case (cs)
            IDLE :
                begin
                    counter <= 0;
                    rx_valid <= 0;
                    MISO <= 0;
                end
            CHK_CMD :
                begin
                    counter <= 0;
                    rx_valid <= 0;
                end
            WRITE :
                begin
                    if (counter <= 9) begin
                        rx_data <= {rx_data[8:0],MOSI};
                        rx_valid <= 0;
                        counter <= counter + 1;
                    end
                    if (counter >= 9) begin
                        rx_valid <= 1;
                    end
                end
            READ_ADD :
                begin
                    if (counter <= 9) begin
                        rx_data <= {rx_data[8:0],MOSI};
                        rx_valid <= 0;
                        rd_addr_recieved <= 1;
                        counter <= counter + 1;
                    end
                    if (counter >= 9)
                        rx_valid <= 1;
                end
            READ_DATA :
                begin
                    if(tx_valid && counter >= 3) begin
                        MISO <= tx_data[counter - 3];
                        counter <= counter - 1;
                    end
                    else 
                    if(counter <= 9) begin
                        rx_data <= {rx_data[8:0],MOSI}; // recieved bits are MSB TO LSB
                        rx_valid <= 0;
                        counter <= counter + 1;
                    end
                    if(counter >= 9) begin
                        rx_valid <= 1;
                        rd_addr_recieved <= 0;
                    end
                end
        endcase
    end
end
endmodule
