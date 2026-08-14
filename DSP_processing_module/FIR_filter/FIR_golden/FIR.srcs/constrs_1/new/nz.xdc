set_property IOSTANDARD LVCMOS33 [get_ports {data_in[*]}]
set_property IOSTANDARD LVCMOS33 [get_ports {data_out[*]}]
set_property DRIVE 8 [get_ports {data_out[*]}]
###############################################################
## CLOCK
###############################################################
set_property PACKAGE_PIN H16 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -period 50.000 -name clk -waveform {0.000 25.000} -add [get_ports clk]

set_clock_uncertainty 0.500 [::get_clocks_ren clk]

###############################################################
## RESET
###############################################################
set_property PACKAGE_PIN V17 [get_ports reset]
set_property IOSTANDARD LVCMOS33 [get_ports reset]

set_false_path -from [get_ports reset]

set_multicycle_path 6 -setup
set_multicycle_path 5 -hold

###############################################################
## INPUTS
###############################################################
set_input_delay -clock clk 3.000 [get_ports {data_in[*]}]

###############################################################
## OUTPUTS
###############################################################
set_output_delay -clock clk 5.000 [get_ports {data_out[*]}]


###############################################################
## END
###############################################################

