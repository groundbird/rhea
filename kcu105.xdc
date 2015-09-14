#
# SiTCP timing constrainsts
# ref., http://openit.kek.jp/tips/member/fpga-pcb/fpga/741101568
#
set_false_path -through [get_nets SiTCP_inst/Wrapper_SiTCP/SiTCP/SiTCP_INT/SiTCP_INT_REG/regX10Data*]
set_false_path -through [get_nets SiTCP_inst/Wrapper_SiTCP/SiTCP/SiTCP_INT/SiTCP_INT_REG/regX11Data*]
set_false_path -through [get_nets SiTCP_inst/Wrapper_SiTCP/SiTCP/SiTCP_INT/SiTCP_INT_REG/regX12Data*]
set_false_path -through [get_nets SiTCP_inst/Wrapper_SiTCP/SiTCP/SiTCP_INT/SiTCP_INT_REG/regX13Data*]
set_false_path -through [get_nets SiTCP_inst/Wrapper_SiTCP/SiTCP/SiTCP_INT/SiTCP_INT_REG/regX14Data*]
set_false_path -through [get_nets SiTCP_inst/Wrapper_SiTCP/SiTCP/SiTCP_INT/SiTCP_INT_REG/regX15Data*]
set_false_path -through [get_nets SiTCP_inst/Wrapper_SiTCP/SiTCP/SiTCP_INT/SiTCP_INT_REG/regX16Data*]
set_false_path -through [get_nets SiTCP_inst/Wrapper_SiTCP/SiTCP/SiTCP_INT/SiTCP_INT_REG/regX17Data*]
set_false_path -through [get_nets SiTCP_inst/Wrapper_SiTCP/SiTCP/SiTCP_INT/SiTCP_INT_REG/regX18Data*]
set_false_path -through [get_nets SiTCP_inst/Wrapper_SiTCP/SiTCP/SiTCP_INT/SiTCP_INT_REG/regX19Data*]
set_false_path -through [get_nets SiTCP_inst/Wrapper_SiTCP/SiTCP/SiTCP_INT/SiTCP_INT_REG/regX1AData*]
set_false_path -through [get_nets SiTCP_inst/Wrapper_SiTCP/SiTCP/SiTCP_INT/SiTCP_INT_REG/regX1BData*]
set_false_path -through [get_nets SiTCP_inst/Wrapper_SiTCP/SiTCP/BBT_SiTCP_RST/resetReq*]
set_false_path -through [get_nets SiTCP_inst/Wrapper_SiTCP/SiTCP/GMII/GMII_TXBUF/memRdReq*]
set_false_path -through [get_nets SiTCP_inst/Wrapper_SiTCP/SiTCP/GMII/GMII_TXBUF/orRdAct*]
set_false_path -through [get_nets SiTCP_inst/Wrapper_SiTCP/SiTCP/GMII/GMII_TXBUF/dlyBank0LastWrAddr*]
set_false_path -through [get_nets SiTCP_inst/Wrapper_SiTCP/SiTCP/GMII/GMII_TXBUF/dlyBank1LastWrAddr*]
set_false_path -through [get_nets SiTCP_inst/Wrapper_SiTCP/SiTCP/GMII/GMII_TXBUF/muxEndTgl]
set_false_path -through [get_nets SiTCP_inst/Wrapper_SiTCP/SiTCP/GMII/GMII_RXBUF/cmpWrAddr*]

