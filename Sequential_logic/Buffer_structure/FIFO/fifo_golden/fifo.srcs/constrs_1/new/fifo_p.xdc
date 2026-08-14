## Clock
set_property PACKAGE_PIN H16 [get_ports syn_clock]
set_property IOSTANDARD LVCMOS33 [get_ports syn_clock]
create_clock -period 8.0 -name sys_clk -waveform {0 4} [get_ports syn_clock]

## Reset button
set_property PACKAGE_PIN D19 [get_ports syn_reset]
set_property IOSTANDARD LVCMOS33 [get_ports syn_reset]


## write switch
set_property PACKAGE_PIN R17 [get_ports write]
set_property IOSTANDARD LVCMOS33 [get_ports write]

## read switch
set_property PACKAGE_PIN T19 [get_ports read]
set_property IOSTANDARD LVCMOS33 [get_ports read]


## FIFO empty
set_property PACKAGE_PIN R14 [get_ports empty]
set_property IOSTANDARD LVCMOS33 [get_ports empty]

## FIFO full
set_property PACKAGE_PIN P14 [get_ports full]
set_property IOSTANDARD LVCMOS33 [get_ports full]


set_property PACKAGE_PIN F17 [get_ports {data_write[0]}]
set_property PACKAGE_PIN M17 [get_ports {data_write[1]}]
set_property PACKAGE_PIN F16 [get_ports {data_write[2]}]
set_property PACKAGE_PIN G17 [get_ports {data_write[3]}]
set_property PACKAGE_PIN G18 [get_ports {data_write[4]}]
set_property PACKAGE_PIN G19 [get_ports {data_write[5]}]
set_property PACKAGE_PIN N17 [get_ports {data_write[6]}]
set_property PACKAGE_PIN K16 [get_ports {data_write[7]}]
set_property PACKAGE_PIN K17 [get_ports {data_write[8]}]
set_property PACKAGE_PIN W11 [get_ports {data_write[9]}]
set_property PACKAGE_PIN V10 [get_ports {data_write[10]}]
set_property PACKAGE_PIN W8  [get_ports {data_write[11]}]
set_property PACKAGE_PIN V5 [get_ports {data_write[12]}]
set_property PACKAGE_PIN V11 [get_ports {data_write[13]}]
set_property PACKAGE_PIN U10 [get_ports {data_write[14]}]
set_property PACKAGE_PIN V8  [get_ports {data_write[15]}]



set_property PACKAGE_PIN U12 [get_ports {data_read[0]}]
set_property PACKAGE_PIN M18 [get_ports {data_read[1]}]
set_property PACKAGE_PIN V13 [get_ports {data_read[2]}]
set_property PACKAGE_PIN U13 [get_ports {data_read[3]}]
set_property PACKAGE_PIN T10 [get_ports {data_read[4]}]
set_property PACKAGE_PIN T11 [get_ports {data_read[5]}]


set_property PACKAGE_PIN K18 [get_ports {data_read[6]}]
set_property PACKAGE_PIN K19  [get_ports {data_read[7]}]
set_property PACKAGE_PIN Y13 [get_ports {data_read[8]}]
set_property PACKAGE_PIN Y14 [get_ports {data_read[9]}]
set_property PACKAGE_PIN W14 [get_ports {data_read[10]}]
set_property PACKAGE_PIN W13 [get_ports {data_read[11]}]
set_property PACKAGE_PIN V15 [get_ports {data_read[12]}]
set_property PACKAGE_PIN W15 [get_ports {data_read[13]}]
set_property PACKAGE_PIN U15 [get_ports {data_read[14]}]
set_property PACKAGE_PIN V16 [get_ports {data_read[15]}]

set_property IOSTANDARD LVCMOS33 [get_ports {data_write[*]}]
set_property IOSTANDARD LVCMOS33 [get_ports {data_read[*]}]