module Program_Rom(
	output logic [13:0] Rom_data_out, 
	input [10:0] Rom_addr_in
);

    logic [13:0] data;
    always_comb
        begin
            case (Rom_addr_in)
                10'h0 : data = 14'h0103;
                10'h1 : data = 14'h01A5;
                10'h2 : data = 14'h3003;
                10'h3 : data = 14'h00A5;
                10'h4 : data = 14'h3000;
                10'h5 : data = 14'h3E01;
                10'h6 : data = 14'h0BA5;
                10'h7 : data = 14'h2805;
                10'h8 : data = 14'h2808;
                10'h9 : data = 14'h3400;
                10'ha : data = 14'h3400;
                default: data = 14'h0;   
            endcase
        end

     assign Rom_data_out = data;

endmodule
