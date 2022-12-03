module LSFR#(
           parameter S_WIDTH   = 8 //INT8 ,
           parameter INT_WIDTH = 2 //ind_state length
       )
       (
           input clk_i,
           input rst_i,
           input random_seed_valid_i,
           //mode 0: 0~255 , mode 1:0 ~ 3, mode 2: 1~255
           input [1:0] mode_i,
           input [S_WIDTH-1:0] random_seed_i,
           output reg[S_WIDTH-1:0]  random_num_ff_02_o,
           output reg[INT_WIDTH-1:0]random_num_ff_1_o
       );
reg ff_sequence[0:S_WIDTH-1];
reg [S_WIDTH-1:0] random_num_ff_wr;

always @(posedge clk_i or negedge rst_i)
begin
    if(rst_i)
        random_num_ff_1_o <= 'd0;
    else
        random_num_ff_wr[INT_WIDTH:0];
end

always @(posedge clk_i or negedge rst_i)
begin
    if (rst_i) begin
        random_num_ff_02_o <= 'd0;
    end
    else begin
        random_num_ff_02_o <= random_num_ff_wr;
    end
end

// Uses x^8 + x^6 + x^5 + x^4 + 1
integer i;
always @(posedge clk_i or negedge rst_i)
begin
    for(i = 0 ; i < S_WIDTH ; i = i + 1)
    begin: ff_seq
        if(rst_i)
        begin
            ff_sequence[i] <= 0;
        end
        else if(random_seed_valid_i)
        begin
            ff_sequence[i] <= random_seed_i[i];
        end
        else
        begin
            if( (i === 5) || (i ===4) || (i === 3))
            begin
                ff_sequence[i-1]       <= ff_sequence[i] ^ ff_sequence[0];
            end
            else if(i === 0)
            begin
                ff_sequence[S_WIDTH-1] <= ff_sequence[0];
            end
            else
            begin
                ff_sequence[i-1]       <= ff_sequence[i];
            end
        end
    end
end

//Outputs
integer j;
always @(*)
begin
    for (j = 0; j < S_WIDTH; j = j + 1)
    begin
        case(mode_i)
            2'b00:
            begin
                random_num_ff_wr[j] = ff_sequence[j];
            end
            2'b10:
            begin
                if(j>=1)
                begin
                    random_num_ff_wr[j] = {ff_sequence[j],1'b0};
                end
            end
            default:
            begin
                random_num_ff_wr[j] = 'd0;
            end
        endcase
    end
end

endmodule
