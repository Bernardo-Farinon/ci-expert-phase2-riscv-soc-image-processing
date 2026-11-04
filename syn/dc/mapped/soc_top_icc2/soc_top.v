/////////////////////////////////////////////////////////////
// Created by: Synopsys DC Ultra(TM) in topographical mode
// Version   : W-2024.09-SP5-4
// Date      : Sun Nov  1 01:50:59 2026
/////////////////////////////////////////////////////////////


module soc_top ( serial_sink_data, serial_sink_ready, serial_sink_valid, 
        serial_source_data, serial_source_ready, serial_source_valid, 
        sim_trace, sys_clk );
  input [7:0] serial_sink_data;
  output [7:0] serial_source_data;
  input serial_sink_valid, serial_source_ready, sys_clk;
  output serial_sink_ready, serial_source_valid, sim_trace;
  wire   N68645, n330679, n330680, n330681, n330682, n330683, n331807, n331808,
         n331809, n331810, n331811, n331812, n331813, n331814, n331815,
         n331816, n331817, n331818, n331819, n331820, n331821, n331822,
         n331823, n331824, n331825, n331826, n331827, n331828, n331829,
         n331830, n331831, n331832;
  wire   [4:0] uart_core_rx_fifo_level0;
  assign serial_source_data[7] = 1'b0;
  assign serial_source_data[6] = 1'b0;
  assign serial_source_data[5] = 1'b0;
  assign serial_source_data[4] = 1'b0;
  assign serial_source_data[3] = 1'b0;
  assign serial_source_data[2] = 1'b0;
  assign serial_source_data[1] = 1'b0;
  assign serial_source_data[0] = 1'b0;
  assign serial_source_valid = 1'b0;
  assign serial_sink_ready = N68645;
  assign sim_trace = 1'b1;

  DFFX1_LVT \uart_core_rx_fifo_level0_reg[1]  ( .D(n330679), .CLK(sys_clk), 
        .Q(uart_core_rx_fifo_level0[1]) );
  DFFX1_LVT \uart_core_rx_fifo_level0_reg[0]  ( .D(n330683), .CLK(sys_clk), 
        .Q(uart_core_rx_fifo_level0[0]) );
  DFFX1_LVT \uart_core_rx_fifo_level0_reg[4]  ( .D(n330682), .CLK(sys_clk), 
        .Q(uart_core_rx_fifo_level0[4]) );
  DFFX1_LVT \uart_core_rx_fifo_level0_reg[3]  ( .D(n330681), .CLK(sys_clk), 
        .Q(uart_core_rx_fifo_level0[3]) );
  DFFX1_LVT \uart_core_rx_fifo_level0_reg[2]  ( .D(n330680), .CLK(sys_clk), 
        .Q(uart_core_rx_fifo_level0[2]) );
  NOR4X0_LVT U332131 ( .A1(uart_core_rx_fifo_level0[3]), .A2(
        uart_core_rx_fifo_level0[2]), .A3(uart_core_rx_fifo_level0[0]), .A4(
        uart_core_rx_fifo_level0[1]), .Y(n331807) );
  NAND2X0_LVT U332132 ( .A1(uart_core_rx_fifo_level0[4]), .A2(n331807), .Y(
        N68645) );
  NAND2X0_LVT U332133 ( .A1(serial_sink_valid), .A2(N68645), .Y(n331820) );
  INVX1_LVT U332134 ( .A(n331820), .Y(n331819) );
  INVX1_LVT U332135 ( .A(n331819), .Y(n331832) );
  NAND2X0_LVT U332136 ( .A1(uart_core_rx_fifo_level0[2]), .A2(n331832), .Y(
        n331813) );
  INVX1_LVT U332137 ( .A(n331820), .Y(n331811) );
  AND3X1_LVT U332138 ( .A1(uart_core_rx_fifo_level0[2]), .A2(
        uart_core_rx_fifo_level0[0]), .A3(uart_core_rx_fifo_level0[1]), .Y(
        n331814) );
  INVX1_LVT U332139 ( .A(n331814), .Y(n331810) );
  INVX1_LVT U332140 ( .A(uart_core_rx_fifo_level0[2]), .Y(n331808) );
  NAND2X0_LVT U332141 ( .A1(uart_core_rx_fifo_level0[0]), .A2(
        uart_core_rx_fifo_level0[1]), .Y(n331826) );
  NAND2X0_LVT U332142 ( .A1(n331808), .A2(n331826), .Y(n331809) );
  NAND3X0_LVT U332143 ( .A1(n331811), .A2(n331810), .A3(n331809), .Y(n331812)
         );
  NAND2X0_LVT U332144 ( .A1(n331813), .A2(n331812), .Y(n330680) );
  NAND4X0_LVT U332145 ( .A1(uart_core_rx_fifo_level0[3]), .A2(
        uart_core_rx_fifo_level0[2]), .A3(uart_core_rx_fifo_level0[0]), .A4(
        uart_core_rx_fifo_level0[1]), .Y(n331821) );
  INVX1_LVT U332146 ( .A(n331820), .Y(n331830) );
  AND2X1_LVT U332147 ( .A1(n331821), .A2(n331830), .Y(n331816) );
  OR2X1_LVT U332148 ( .A1(n331814), .A2(uart_core_rx_fifo_level0[3]), .Y(
        n331815) );
  AND2X1_LVT U332149 ( .A1(n331816), .A2(n331815), .Y(n331817) );
  AO21X1_LVT U332150 ( .A1(n331832), .A2(uart_core_rx_fifo_level0[3]), .A3(
        n331817), .Y(n330681) );
  INVX1_LVT U332152 ( .A(uart_core_rx_fifo_level0[0]), .Y(n331818) );
  AO22X1_LVT U332153 ( .A1(uart_core_rx_fifo_level0[0]), .A2(n331832), .A3(
        n331818), .A4(n331819), .Y(n330683) );
  INVX1_LVT U332154 ( .A(uart_core_rx_fifo_level0[4]), .Y(n331822) );
  OR2X1_LVT U332155 ( .A1(n331822), .A2(n331819), .Y(n331825) );
  INVX1_LVT U332156 ( .A(n331821), .Y(n331823) );
  AO221X1_LVT U332157 ( .A1(uart_core_rx_fifo_level0[4]), .A2(n331823), .A3(
        n331822), .A4(n331821), .A5(n331820), .Y(n331824) );
  NAND2X0_LVT U332158 ( .A1(n331825), .A2(n331824), .Y(n330682) );
  OR2X1_LVT U332159 ( .A1(uart_core_rx_fifo_level0[0]), .A2(
        uart_core_rx_fifo_level0[1]), .Y(n331827) );
  NAND2X0_LVT U332160 ( .A1(n331827), .A2(n331826), .Y(n331828) );
  INVX1_LVT U332161 ( .A(n331828), .Y(n331829) );
  AND2X1_LVT U332162 ( .A1(n331830), .A2(n331829), .Y(n331831) );
  AO21X1_LVT U332163 ( .A1(uart_core_rx_fifo_level0[1]), .A2(n331832), .A3(
        n331831), .Y(n330679) );
endmodule

