#------------------------------------------------------------------------------
# Smoothing and Sobel Filters
#   - pipelined fully parallel implementation
#   - CSR bus interface
#
#   v0 - initial
#   v1 - delay line sinc output data; start flag merged into data register
#
#   Alexsandro Bonatto (2026-08-10)
#------------------------------------------------------------------------------

from migen import *
from litex.soc.interconnect.csr     import *

# -----------------------------------------------------------------------------
# Filtro de Suavização (Blur)
#  - retorna 'gb' em formato signed 20-bits
# -----------------------------------------------------------------------------
class FiltroSuavCompleto(Module):
    def __init__(self, width=512):
        
        self.sink_data = Signal(8)    # Entrada de pixels (0-255)
        self.sink_valid = Signal()    # Entrada válida
        self.pixel_out = Signal(8)    # Saída
        self.pixel_valid = Signal()   # Saída válida
        self.gb_k = [[Signal((8, True)) for a in range(3)] for b in range(3)]

        line_mem1 = Memory(8, width)
        line_mem2 = Memory(8, width)
        
        p1 = line_mem1.get_port(write_capable=True, mode=READ_FIRST)
        p2_rd = line_mem2.get_port(write_capable=False, mode=READ_FIRST)
        p2_wr = line_mem2.get_port(write_capable=True, mode=READ_FIRST)        
        self.specials += line_mem1, line_mem2, p1, p2_rd, p2_wr

        col = Signal(max=width)
        col_dly = Signal(max=width)
        
        p = [[Signal((9, True)) for a in range(3)] for b in range(3)]
        
        self.gb = Signal((20, True))
        self.gb_out = Signal(8)

        self.comb += [
            p1.adr.eq(col),
            p2_rd.adr.eq(col),
            p2_wr.adr.eq(col_dly)
        ]
        
        self.comb += [
            If(self.sink_valid,
                p1.we.eq(1),
                p1.dat_w.eq(self.sink_data),
                p2_wr.we.eq(1),
                p2_wr.dat_w.eq(p1.dat_r)
            ).Else(
                p1.we.eq(0),
                p2_wr.we.eq(0)
            )
        ]
        
        sum_kp_0 = Signal((17,True))
        sum_kp_1 = Signal((17,True))
        sum_kp_2 = Signal((17,True))
        sum_kp_3 = Signal((17,True))
        sum_kp_4 = Signal((18,True))
        sum_kp_5 = Signal((18,True))
        sum_kp_6 = Signal((19,True))
        
        self.sync += [
        
            ## Árvore de somadores
            # Primeiro nível (17-bits)
            sum_kp_0.eq( self.gb_k[0][0] * p[2][2] + self.gb_k[0][1] * p[2][1] ),
            sum_kp_1.eq( self.gb_k[0][2] * p[2][0] + self.gb_k[1][0] * p[1][2] ),
            sum_kp_2.eq( self.gb_k[1][1] * p[1][1] + self.gb_k[1][2] * p[1][0] ),
            sum_kp_3.eq( self.gb_k[2][0] * p[0][2] + self.gb_k[2][1] * p[0][1] ),
            # Segundo nível (18-bits)
            sum_kp_4.eq( sum_kp_0 + sum_kp_1 ),
            sum_kp_5.eq( sum_kp_2 + sum_kp_3 ),
            # Terceiro nível (19-bits)
            sum_kp_6.eq( sum_kp_4 + sum_kp_5 ),
            # Quarto nível (20-bits)
            self.gb.eq( sum_kp_6 + self.gb_k[2][2] * p[0][0] ),
            # O somatório não permite implementar o pipeline            
            #self.gb.eq(sum(self.gb_k[i][j] * p[2-i][2-j] for i in range(3) for j in range(3))),            
        ]
        
        # Saída com divisão por 16
        self.comb += self.pixel_out.eq(self.gb >> 4)  

        reg_sink_data1 = Signal(8)        
       
        self.sync += [
            If(self.sink_valid,
                If(col == width - 1,
                    col.eq(0)
                ).Else(
                    col.eq(col + 1)
                ),
                col_dly.eq(col),
                reg_sink_data1.eq(self.sink_data),
                
                p[2][0].eq(p[2][1]), p[2][1].eq(p[2][2]), p[2][2].eq(reg_sink_data1),
                p[1][0].eq(p[1][1]), p[1][1].eq(p[1][2]), p[1][2].eq(p1.dat_r),
                p[0][0].eq(p[0][1]), p[0][1].eq(p[0][2]), p[0][2].eq(p2_rd.dat_r),
            )
        ]

        # Linha de atraso para gerar o sinal 'pixel_valid'
        sink_valid_dly0 = Signal();
        sink_valid_dly1 = Signal();
        sink_valid_dly2 = Signal();
        sink_valid_dly3 = Signal();
        
        self.sync += [
            sink_valid_dly0.eq(self.sink_valid),
            sink_valid_dly1.eq(sink_valid_dly0),
            sink_valid_dly2.eq(sink_valid_dly1),
            sink_valid_dly3.eq(sink_valid_dly2),
            self.pixel_valid.eq(sink_valid_dly3)         
        ]

# -----------------------------------------------------------------------------
# Filtro Sobel
# -----------------------------------------------------------------------------
class FiltroCompletodeSobel(Module):
    def __init__(self, width=512):
        
        self.sink_data = Signal(8)    # Entrada de pixels (0-255)
        self.sink_valid = Signal()    # Entrada válida
        self.source_data = Signal(16) # Saída
        self.source_valid = Signal()  # Saída válida
        self.gx_k = [[Signal((8, True)) for a in range(3)] for b in range(3)]
        self.gy_k = [[Signal((8, True)) for a in range(3)] for b in range(3)]

        line_mem1 = Memory(8, width)
        line_mem2 = Memory(8, width)
        
        p1 = line_mem1.get_port(write_capable=True, mode=READ_FIRST)
        p2_rd = line_mem2.get_port(write_capable=False, mode=READ_FIRST)
        p2_wr = line_mem2.get_port(write_capable=True, mode=READ_FIRST)        
        self.specials += line_mem1, line_mem2, p1, p2_rd, p2_wr

        col = Signal(max=width)
        col_dly = Signal(max=width)
        
        p = [[Signal((9, True)) for a in range(3)] for b in range(3)]
      
        self.gx = Signal((20, True))
        self.gy = Signal((20, True))
        abs_gx = Signal(21)
        abs_gy = Signal(21)

        self.comb += [
            p1.adr.eq(col),
            p2_rd.adr.eq(col),
            p2_wr.adr.eq(col_dly)
        ]
        
        self.comb += [
            If(self.sink_valid,
                p1.we.eq(1),
                p1.dat_w.eq(self.sink_data),
                p2_wr.we.eq(1),
                p2_wr.dat_w.eq(p1.dat_r)
            ).Else(
                p1.we.eq(0),
                p2_wr.we.eq(0)
            )
        ]
        
        sum_gx_kp_0 = Signal((17,True))
        sum_gx_kp_1 = Signal((17,True))
        sum_gx_kp_2 = Signal((17,True))
        sum_gx_kp_3 = Signal((17,True))
        sum_gx_kp_4 = Signal((18,True))
        sum_gx_kp_5 = Signal((18,True))
        sum_gx_kp_6 = Signal((19,True))
        sum_gy_kp_0 = Signal((17,True))
        sum_gy_kp_1 = Signal((17,True))
        sum_gy_kp_2 = Signal((17,True))
        sum_gy_kp_3 = Signal((17,True))
        sum_gy_kp_4 = Signal((18,True))
        sum_gy_kp_5 = Signal((18,True))
        sum_gy_kp_6 = Signal((19,True))
        
        self.sync += [
        
            ## Árvore de somadores
            # Primeiro nível (17-bits)
            sum_gx_kp_0.eq( self.gx_k[0][0] * p[2][2] + self.gx_k[0][1] * p[2][1] ),
            sum_gy_kp_0.eq( self.gy_k[0][0] * p[2][2] + self.gy_k[0][1] * p[2][1] ),
            sum_gx_kp_1.eq( self.gx_k[0][2] * p[2][0] + self.gx_k[1][0] * p[1][2] ),
            sum_gy_kp_1.eq( self.gy_k[0][2] * p[2][0] + self.gy_k[1][0] * p[1][2] ),
            sum_gx_kp_2.eq( self.gx_k[1][1] * p[1][1] + self.gx_k[1][2] * p[1][0] ),
            sum_gy_kp_2.eq( self.gy_k[1][1] * p[1][1] + self.gy_k[1][2] * p[1][0] ),
            sum_gx_kp_3.eq( self.gx_k[2][0] * p[0][2] + self.gx_k[2][1] * p[0][1] ),
            sum_gy_kp_3.eq( self.gy_k[2][0] * p[0][2] + self.gy_k[2][1] * p[0][1] ),
            # Segundo nível (18-bits)
            sum_gx_kp_4.eq( sum_gx_kp_0 + sum_gx_kp_1 ),
            sum_gy_kp_4.eq( sum_gy_kp_0 + sum_gy_kp_1 ),
            sum_gx_kp_5.eq( sum_gx_kp_2 + sum_gx_kp_3 ),
            sum_gy_kp_5.eq( sum_gy_kp_2 + sum_gy_kp_3 ),
            # Terceiro nível (19-bits)
            sum_gx_kp_6.eq( sum_gx_kp_4 + sum_gx_kp_5 ),
            sum_gy_kp_6.eq( sum_gy_kp_4 + sum_gy_kp_5 ),
            # Quarto nível (20-bits)
            self.gx.eq( sum_gx_kp_6 + self.gx_k[2][2] * p[0][0] ),
            self.gy.eq( sum_gy_kp_6 + self.gy_k[2][2] * p[0][0] )
            
            # O somatório não permite implementar o pipeline
            #self.gx.eq(sum(self.gx_k[i][j] * p[2-i][2-j] for i in range(3) for j in range(3))),
            #self.gy.eq(sum(self.gy_k[i][j] * p[2-i][2-j] for i in range(3) for j in range(3)))
        ]
               
        self.comb += [
            If(self.gx < 0, abs_gx.eq(-self.gx)).Else(abs_gx.eq(self.gx)),
            If(self.gy < 0, abs_gy.eq(-self.gy)).Else(abs_gy.eq(self.gy)),
            
            If((abs_gx + abs_gy) > 255,
               self.source_data.eq(255)
            ).Else(
               self.source_data.eq(abs_gx + abs_gy)
            )
        ]

        reg_sink_data1 = Signal(8)        
       
        self.sync += [
            If(self.sink_valid,
                If(col == width - 1,
                    col.eq(0)
                ).Else(
                    col.eq(col + 1)
                ),
                col_dly.eq(col),
                reg_sink_data1.eq(self.sink_data),
                
                p[2][0].eq(p[2][1]), p[2][1].eq(p[2][2]), p[2][2].eq(reg_sink_data1),
                p[1][0].eq(p[1][1]), p[1][1].eq(p[1][2]), p[1][2].eq(p1.dat_r),
                p[0][0].eq(p[0][1]), p[0][1].eq(p[0][2]), p[0][2].eq(p2_rd.dat_r),

            )
        ]
        
        # Linha de atraso para gerar o sinal 'source_valid'
        sink_valid_dly0 = Signal();
        sink_valid_dly1 = Signal();
        sink_valid_dly2 = Signal();
        sink_valid_dly3 = Signal();
        
        self.sync += [
            sink_valid_dly0.eq(self.sink_valid),
            sink_valid_dly1.eq(sink_valid_dly0),
            sink_valid_dly2.eq(sink_valid_dly1),
            sink_valid_dly3.eq(sink_valid_dly2),
            self.source_valid.eq(sink_valid_dly3)
        ]


# -----------------------------------------------------------------------------
# Wrapper dos Filtros de Suavização e de Bordas
#   - CSR -> Blur -> Sobel -> CSR
# -----------------------------------------------------------------------------
class FiltroSobelWrapper(Module, AutoCSR):
    def __init__(self, img_width=512):
        # Instancia os kernels de filtragem para suavização e bordas
        self.submodules.sobel = FiltroCompletodeSobel(width=img_width)
        self.submodules.blur = FiltroSuavCompleto(width=img_width)

        # Registradores de Controle/Status (Acessíveis pelo código em C da CPU)
        self.data_in   = CSRStorage(32, description="Pixel de entrada (0-255) e flag")
        #self.start     = CSRStorage(1, description="Transição de 0->1 gera pulso de entrada")
        self.data_out  = CSRStatus(32, description="Pixel resultante processado e flag")
        #self.valid_out = CSRStatus(1, description="1 quando o processamento produz uma saída válida")

        # Configura os Kernels (Hardcoded no wrapper para simplificar o controle via CPU)
        const_gx_k = [[-1, 0, 1], [-2, 0, 2], [-1, 0, 1]]
        const_gy_k = [[-1, -2, -1], [0, 0, 0], [1, 2, 1]]
        const_gb_k = [[1, 2, 1], [2, 4, 2], [1, 2, 1]]

        for i in range(3):
            for j in range(3):
                self.comb += [
                    self.sobel.gx_k[i][j].eq(const_gx_k[i][j]),
                    self.sobel.gy_k[i][j].eq(const_gy_k[i][j]),
                    self.blur.gb_k[i][j].eq(const_gb_k[i][j])
                ]

        start = Signal()
        start_dly = Signal()
        
        self.comb += start.eq(self.data_in.storage[24])
        self.sync += start_dly.eq(start)

        sink_valid_pulse = Signal()
        self.comb += sink_valid_pulse.eq(start & ~start_dly)
        
        # Conecta entradas e saídas para o filtro de suavização
        self.blur_pixel_out = Signal(8)
        self.blur_pixel_valid = Signal()
        
        self.comb += [
            # Entradas
            self.blur.sink_data.eq(self.data_in.storage[0:8]),
            self.blur.sink_valid.eq(sink_valid_pulse),
            # Saídas
            self.blur_pixel_out.eq(self.blur.pixel_out),
            self.blur_pixel_valid.eq(self.blur.pixel_valid)            
        ]
        
        # Conecta entradas e saídas para o filtro de bordas       
        self.comb += [
            # Entradas
            self.sobel.sink_data.eq(self.blur_pixel_out),
            self.sobel.sink_valid.eq(self.blur_pixel_valid),
        ]
        
        self.sync += [
            # Saídas
            self.data_out.status[0:8].eq(self.sobel.source_data),
            # Gera flag de longa duração para sincronizar com barramento
            If(self.sobel.source_valid,
                self.data_out.status[24].eq(1)
            ).Elif(sink_valid_pulse,
                self.data_out.status[24].eq(0)
            ).Else(
                self.data_out.status[24].eq(self.data_out.status[24])
            )
        ]

        # teste para ver a saída do filtro de suavização
        # self.sync += [
        #     # Saídas
        #     self.data_out.status[0:8].eq(self.blur_pixel_out),  
        #     # Gera flag de longa duração para sincronizar com barramento
        #     If(self.blur_pixel_valid,   # teste para ver a saída do filtro
        #         self.data_out.status[24].eq(1)
        #     ).Elif(sink_valid_pulse,
        #         self.data_out.status[24].eq(0)
        #     ).Else(
        #         self.data_out.status[24].eq(self.data_out.status[24])
        #     )
        # ]

