module counter#(
           parameter CNT_WIDTH = 4
       )
       (
           input clk_i,
           input rst_n_i,
           input en_i,
           input clr_i,
           output reg[CNT_WIDTH-1:0] cnt_ff
       );


reg[CNT_WIDTH-1:0] cnt_wr;

always @(posedge clk_i or negedge rst_n_i)
begin
    if(~rst_n_i)
    begin
      cnt_ff <= 'd0;
    end
    else if(clr_i)
    begin
      cnt_ff <= 'd0;
    end
    else if(en_i)
    begin
      cnt_ff <= cnt_ff + 1;
    end
    else
    begin
      cnt_ff <= cnt_ff;
    end
end

assign cnt_wr = clr_i ? 'd0 : (en_i ? cnt_ff + 1 : cnt_ff);

// always @(*)
// begin
//     if(clr_i)
//     begin
//         cnt_wr='d0;
//     end
//     else if(en_i)
//     begin
//         cnt_wr=cnt_ff+1;
//     end
//     else
//     begin
//         cnt_wr = cnt_ff;
//     end
// end




endmodule
