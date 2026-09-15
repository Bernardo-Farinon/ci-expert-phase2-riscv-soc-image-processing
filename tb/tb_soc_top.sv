`timescale 1ns/1ps

module tb_soc_top;

    reg sys_clk;
    reg [7:0] serial_sink_data;
    reg serial_sink_valid;
    wire serial_sink_ready;
    wire [7:0] serial_source_data;
    reg serial_source_ready;
    wire serial_source_valid;
    wire sim_trace;

    sim uut (
        .serial_sink_data(serial_sink_data),
        .serial_sink_ready(serial_sink_ready),
        .serial_sink_valid(serial_sink_valid),
        .serial_source_data(serial_source_data),
        .serial_source_ready(serial_source_ready),
        .serial_source_valid(serial_source_valid),
        .sim_trace(sim_trace),
        .sys_clk(sys_clk)
    );

    always #5 sys_clk = ~sys_clk;

    always @(posedge sys_clk) begin
        if (serial_source_valid) begin
            $write("%c", serial_source_data); 
        end
    end

    initial begin
        $fsdbDumpfile("wave.fsdb");
        $fsdbDumpvars(0, tb_soc_top);
        
        sys_clk = 0;
        serial_sink_data = 8'd0;
        serial_sink_valid = 1'b0;
        serial_source_ready = 1'b1;


        // tempo pra ele rodar
        #100000000;
        $finish;
    end

endmodule