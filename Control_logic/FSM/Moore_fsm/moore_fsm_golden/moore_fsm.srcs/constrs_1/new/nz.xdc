###############################################################
## CLOCK CONSTRAINT
###############################################################
create_clock -period 10.000 -name clk [get_ports CLK]

###############################################################
## INPUT PORT CONSTRAINTS
###############################################################

# Input delay (assume external source drives inputs)
set_input_delay -clock clk 2.0 [get_ports A]

# Optional: define input transition (slew)
set_input_transition 0.5 [get_ports A]

###############################################################
## OUTPUT PORT CONSTRAINTS
###############################################################
create_clock -name virt_clk -period 10
# Output delay (assume receiving device timing)
set_output_delay -clock virt_clk -max 5.0 [get_ports O]
set_output_delay -clock virt_clk -min 1.0 [get_ports O]

###############################################################
## RESET CONSTRAINT (ASYNC RESET ? FALSE PATH)
###############################################################
set_false_path -from [get_ports RESET]

###############################################################
## PORT INITIALIZATION / DEFAULT STATES
###############################################################

# Set default pull-down for inputs (avoids floating)
set_property PULLDOWN true [get_ports A]

# Reset pin pull-up (common practice)
set_property PULLUP true [get_ports RESET]

# Drive strength (optional)
set_property DRIVE 8 [get_ports O]

# I/O standard (important for FPGA boards)
set_property IOSTANDARD LVCMOS33 [get_ports {CLK A RESET O}]

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