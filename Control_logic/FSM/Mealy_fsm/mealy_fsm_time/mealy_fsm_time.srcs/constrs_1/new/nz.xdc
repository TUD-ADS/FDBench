###############################################################
## CLOCK CONSTRAINT
###############################################################
create_clock -period 10.000 -name clk -add [get_ports CLK]

###############################################################
## INPUT PORT CONSTRAINTS
###############################################################

# Input delay (assume external source drives inputs)
set_input_delay -clock clk -add_delay 2.000 [get_ports A]

# Optional: define input transition (slew)

###############################################################
## OUTPUT PORT CONSTRAINTS
###############################################################

# Output delay (assume receiving device timing)
set_output_delay -clock clk -add_delay 2.000 [get_ports O]

###############################################################
## RESET CONSTRAINT (ASYNC RESET ? FALSE PATH)
###############################################################
set_false_path -reset_path -from [get_ports RESET]

###############################################################
## PORT INITIALIZATION / DEFAULT STATES
###############################################################

# Set default pull-down for inputs (avoids floating)
set_property PULLDOWN true [get_ports {A[1]}]
set_property PULLDOWN true [get_ports {A[0]}]

# Reset pin pull-up (common practice)
set_property PULLUP true [get_ports RESET]

# Drive strength (optional)
set_property DRIVE 8 [get_ports {O[1]}]
set_property DRIVE 8 [get_ports {O[0]}]

# I/O standard (important for FPGA boards)
set_property IOSTANDARD LVCMOS33 [get_ports CLK]
set_property IOSTANDARD LVCMOS33 [get_ports {A[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {A[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports RESET]
set_property IOSTANDARD LVCMOS33 [get_ports {O[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {O[0]}]

###############################################################
## OPTIONAL: FORCE TIMING VIOLATION (FOR DEBUG)
###############################################################
# Uncomment to make timing harder
# create_clock -period 5.000 [get_ports CLK]

# Add uncertainty
# set_clock_uncertainty 1.0 [get_clocks clk]

###############################################################
## DEBUG / SAFETY CHECKS
###############################################################

# Prevent optimization removal (if needed)
# set_property DONT_TOUCH true [get_cells *]

###############################################################
## END OF FILE
###############################################################

