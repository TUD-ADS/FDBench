set_property IOSTANDARD LVCMOS33 [get_ports {pixel_in[*]}]
set_property IOSTANDARD LVCMOS33 [get_ports {pixel_out[*]}]
set_property DRIVE 8 [get_ports {pixel_out[*]}]
###############################################################
## CLOCK
###############################################################
set_property PACKAGE_PIN H16 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]

create_clock -period 10.000 -name clk -waveform {0.000 5.000} -add [get_ports clk]
set_clock_uncertainty 0.500 [::get_clocks_ren clk]

###############################################################
## RESET (ASYNC)
###############################################################
set_property PACKAGE_PIN V17 [get_ports rst]
set_property IOSTANDARD LVCMOS33 [get_ports rst]

set_false_path -from [get_ports rst]

###############################################################
## INPUTS
###############################################################

# pixel input bus
set_input_delay -clock clk 3.000 [get_ports {pixel_in[*]}]

# valid input
set_input_delay -clock clk 3.000 [get_ports valid_in]
set_property IOSTANDARD LVCMOS33 [get_ports valid_in]

###############################################################
## OUTPUTS
###############################################################

# pixel output
set_output_delay -clock clk 5.000 [get_ports {pixel_out[*]}]

# valid output
set_output_delay -clock clk 5.000 [get_ports valid_out]
set_property IOSTANDARD LVCMOS33 [get_ports valid_out]

###############################################################
## OPTIONAL (HELP DEBUG TIMING BUG DESIGN)
###############################################################

# This design has long combinational path → relax if needed
# Uncomment ONLY for debug

# set_multicycle_path 2 -setup -from [get_clocks clk] -to [get_clocks clk]
# set_multicycle_path 1 -hold  -from [get_clocks clk] -to [get_clocks clk]

###############################################################
## END
###############################################################

