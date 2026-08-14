# FDBench: A Paired Golden-Buggy Benchmark for FPGA Debugging


##  Citation

If you use this benchmark in your research, please cite our paper:

FDBench: A Paired Golden-Buggy Benchmark for FPGA Debugging

---

##  Overview

This project provides a **verification framework** for multiple DUTs (Design Under Test) using:

- Python 3.13.5  
- TCL  
- Vivado 2025.2 / Vivado 2022.2  

Unlike basic testbenches, this framework focuses on categorisation of  **real-world hardware bug detection**.

---


The complete structure which is divided into different section will be as follows

## Circuit Types

```
Circuit Types
│
├── Sequential Logic
│   ├── Storage Elements
│   │   ├── Flip-Flops → (D-FF, JK-FF, T-FF)
│   │   └── Latch
│   │
│   ├── Registers & Counters
│   │   ├── Counter
│   │   └── Shift Registers → (SIPO, PISO)
│   │
│   └── Buffer Structures
│       ├── FIFO
│       └── LIFO
│
├── UART Controller
│   ├── UART TX
│   ├── UART RX
│   └── FIFO→UART
│
├── Control Logic
│   ├── FSM
│   │   ├── Moore FSM
│   │   └── Mealy FSM
│   ├── UART TX/RX (simple)
│   ├── FSM Controller
│   └── FSM_Controller→Counter
│
└── DSP Processing Modules
    ├── FIR Filter
    ├── Gaussian Filter
    └── FIFO→FIR
```

##  Key Objectives

Detect critical hardware issues such as:

- FIFO overflow / underflow  
- Clock Domain Crossing (CDC) issues  
- FSM deadlocks / illegal states  
- Timing violations and metastability effects  

---

##  Features

- Stress condition injection (timing, CDC, random toggling)
- Assertion-based verification (no manual waveform debugging)
- Fault injection support (test buggy RTL)
- Robustness validation (not just functionality)

---

##  Project Structure

```
BugBench/
└── Control_logic/
    └── FSM/
        └── Mealy_fsm/
            ├── mealy_fsm_clock_gating/
            │   ├── build.tcl
            │   ├── run_case.bat
            │   ├── rtl/
            │   │   └── mealy_fsm_cgat.vhd
            │   ├── tb/
            │   │   └── mealy_fsm_cgat_tb.vhd
            │   └── mealy_fsm_cgat_D/
            │       ├── build/
            │       │   ├── meta.json
            │       │   ├── timing_summary.rpt
            │       │   └── utilization.rpt
            │
            └── mealy_fsm_golden/
                ├── rtl/
                │   ├── fsm_pkg.vhd
                │   └── mealy_fsm.vhd
                ├── tb/
                │   └── mealy_fsm_tb.vhd
                └── mealy_fsm_g/
```

---

##  How to Use

###  Add our Design

Add our rtl/f_uart_cdc.vhd in your own design.

Ensure the interface matches:
- clk, rst
- write, data_write
- tx_serial
- fifo_full, fifo_empty

---

##  Running on Windows

1. Modify the build.tcl according your design
2. Modify DUT and board name in `.bat` file  
3. Double-click the `.bat` file  

### What to change in `build.tcl`:
```
set main_project_name "fsm_uart_wfsm_D"
set proj_name         "fsm_uart_wfsm_bug"
set proj_dir          "./$main_project_name/fsm_uart_wfsm_"

set rtl_top_e         "fsm_uart_wfsm"
set tb_top_e          "fsm_uart_wfsm_tb"
```

### Update in `runme.bat`:
- Set correct Vivado environment path   

1. replace the "call "C:\Xilinx\Vivado\2022.2\settings64.bat"" environment with your system vivado environment.

- Update DUT name, board, and Python script path 

2. change the path of tools/write_meta.py, device board, and dut name same as 
module name 

python "C:/Users/narsi/Desktop/projects/Project_BUG/tools/write_meta.py" ^
       "%cd%" ^
       "%build_dir%" ^
       "xc7z020clg484-1" ^
       "Vivado 2022.2" ^
       "%rtl_dir%" ^
       "UART_tx_meta"



##  Output

Simulation automatically generates:

```
build/meta.json
timing_summary.rpt
utilization.rpt
```

---

##  Testbench Capabilities

The testbench includes:

1. Reset validation  
2. FIFO overflow stress  
3. FIFO underflow  
4. Timing violation checks  
5. Metastability simulation  
6. CDC asynchronous stimulus  
7. FSM stress patterns  
8. Clock gating disturbance  
9. Stuck-state scenarios  

---

##  Fault Injection Examples

You can validate your verification strength by introducing bugs:

- Remove FIFO full check → expect overflow failure  
- Remove synchronizer → expect CDC issues  
- Break FSM transition → expect illegal state detection  

---

##  Expected Results

| Design Type | Result |
|------------|--------|
| Good Design | No assertion failures |
| Buggy Design | Assertion failures with exact issue |

---

##  Extensibility

You can extend this framework by:

- Adding new assertions  
- Increasing stress intensity  
- Plugging different DUTs (FIFO, UART, AXI, etc.)  

---

##  Future Improvements

- SystemVerilog Assertions (SVA)  
- UVM-based environment  
- Coverage-driven verification  
- Formal verification integration  

---

## 👨‍💻 Author

Ms. Yanjun Lu and Mr. Narasingh Prasad Joshi

---

## Acknowledgments

This work was supported by the China Scholarship Council program (Project ID: 202108640001), the Federal Ministry of Research, Technology and Space of Germany and the Sächsische Staatsministerium für Wissenschaft, Kultur und Tourismus in the programme Center of Excellence for AI research "Center for Scalable Data Analytics and Artificial Intelligence Dresden/Leipzig" , and the German Research Foundation (Deutsche Forschungsgemeinschaft, DFG) under Project-ID 287022738 TRR 196 for Project S05.





