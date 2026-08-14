set_property PACKAGE_PIN H16 [get_ports clock]
set_property IOSTANDARD LVCMOS33 [get_ports clock]
create_clock -period 10.0 -name sys_clk -waveform {0 5} [get_ports clock]
set_property PACKAGE_PIN D19 [get_ports reset]
set_property IOSTANDARD LVCMOS33 [get_ports reset]

set_property PACKAGE_PIN R14 [get_ports D]
set_property IOSTANDARD LVCMOS33 [get_ports D]

set_property PACKAGE_PIN P14 [get_ports Q]
set_property IOSTANDARD LVCMOS33 [get_ports Q]