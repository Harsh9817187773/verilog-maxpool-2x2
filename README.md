2x2 Max-Pooling Hardware Module

A Verilog implementation of a 2x2 max-pooling hardware accelerator. This project features a synchronous datapath, a finite state machine (FSM) controller, and a 2-stage parallel comparator tree. It processes 16-bit Q8.8 fixed-point inputs and outputs the maximum value as an 8-bit integer.

The repository includes an automated Verilog testbench and a Python verification script using NumPy to validate the simulation results.

⚙️ Features

FSM Controller (maxpool_controller.v): A 3-state machine managing LOAD, COMPARE, and OUTPUT cycles.

Synchronous Datapath (maxpool_datapath.v): Handles input registering and fractional truncation (Q8.8 to 8-bit integer extraction).

Parallel Comparator Tree (cmp_tree.v, cmp2.v): Efficiently computes the maximum of four inputs using cascaded unsigned comparators.

Algorithmic Verification (verify_input.py): Cross-references hardware simulation outputs against expected mathematical results.

📂 File Structure

maxpool.v - Top-level module connecting the datapath and controller.

maxpool_controller.v - FSM for scheduling operations.

maxpool_datapath.v - Registers inputs and extracts the final integer output.

cmp_tree.v / cmp2.v - Combinational logic for the 4-input comparator.

tb_maxpool.v - Testbench that reads stimulus data and simulates clock cycles.

verify_input.py - Python script to generate expected max-pooling outputs.

input.txt - Sample test vectors.

🛠️ Prerequisites

To compile and simulate this project, you will need:

Icarus Verilog (iverilog and vvp)

Python 3 (with the numpy library)

🚀 How to Run

1. Run the Python Verification:
Generates the expected pooled outputs from the input text file.

python3 verify_input.py


2. Compile the Verilog Design:
Use Icarus Verilog to compile the testbench and all dependent modules into a single simulation executable.

iverilog -o maxpool_sim tb_maxpool.v maxpool.v maxpool_controller.v maxpool_datapath.v cmp_tree.v cmp2.v


3. Run the Simulation:
Execute the compiled simulation using the vvp engine. This will read from input.txt, simulate the hardware clock cycles, and print the PASS/FAIL test results directly to your terminal.

