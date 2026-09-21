# -----------------------------------------------------------------------------
# 1) Para configurar o ambiente e listar as ferramentas disponíveis:
# -----------------------------------------------------------------------------
# ~$ module load vcs verdi
# -----------------------------------------------------------------------------

# Analyze
vlogan -full64 -kdb --debug_access -verilog -f filelist.f -top tb_soc_top

# Elaborate
vcs -full64 -kdb -debug_access+all -timescale=10ns/1ps -f filelist.f -top tb_soc_top

# Run simulation
./simv -l vcs_run.log

# --> não consegue gerar o fsdb
#./simv -l vcs_run.log -dump tb_soc_top.fsdb --type fsdb
# ~$ ./simv -l simv.log -gui=verdi

# Abrir o Verdi e carrega a forma de ondas

verdi -dbdir simv.daidir -ssf test.fsdb

# debug:
verdi -nologo -ssf robot_model.fsdb &

# report_cov:
verdi -cov -covdir simv.vdb

