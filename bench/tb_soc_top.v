//-----------------------------------------------------------------------------
// tb_soc_top.v
//-----------------------------------------------------------------------------
`timescale 1ns / 1ps

module tb_soc_top;

    reg         sys_clk;
    reg  [7:0]  serial_sink_data;
    reg         serial_sink_valid;
    reg         serial_source_ready;
    wire        sim_trace;    
    wire        serial_sink_ready;
    wire [7:0]  serial_source_data;
    wire        serial_source_valid;
    parameter   T=10;
    
    soc_top uut (
        .sys_clk(sys_clk),
        .serial_sink_data(serial_sink_data),
        .serial_sink_valid(serial_sink_valid),
        .serial_source_ready(serial_source_ready),
        .serial_sink_ready(serial_sink_ready),
        .serial_source_data(serial_source_data),
        .serial_source_valid(serial_source_valid),
        .sim_trace(sim_trace)
    );
    
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_soc_top);
    end
    
    initial begin
        sys_clk = 1'b0;
        forever #(T/2) sys_clk = ~sys_clk;
    end

endmodule
