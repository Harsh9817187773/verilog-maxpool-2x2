import numpy as np
import os

# --- 1. Load the data directly from the input.txt file ---

# Check if the file exists before trying to load it
file_name = "input.txt"

if not os.path.exists(file_name):
    print(f"## ❌ ERROR: File '{file_name}' not found!")
    print("Please make sure 'input.txt' is in the same directory as 'verify_input.py'.")
    exit()

try:
    # Use numpy.loadtxt to read the data from the file
    # If the first line is pure numbers, no need for skiprows.
    # If you re-introduce a non-numeric header, you will need to add skiprows=1.
    data_array = np.loadtxt(file_name, dtype=int)
    
    print("## 1. Input Array Loaded from File")
    print(data_array)
    print(f"Shape: {data_array.shape}")
    print("-" * 30)

except Exception as e:
    print(f"## ❌ ERROR loading data from {file_name}: {e}")
    print("Check if all lines in input.txt contain only space-separated integers.")
    exit()

# --- 2. 2x2 MAX POOLING CALCULATION (Verification) ---

# The 4x4 input is partitioned into 2x2 non-overlapping blocks.
# Reshape (4, 4) -> (2, 2, 2, 2) and find the max over the last two dimensions.
if data_array.shape == (4, 4):
    reshaped_array = data_array.reshape(2, 2, 2, 2)
    expected_output = reshaped_array.max(axis=(2, 3))

    print("## 2. Expected 2x2 Max-Pooling Output")
    print(expected_output)
    print(f"Shape: {expected_output.shape}")
    print("-" * 30)

    # Optional: Print values sequentially
    print("## 3. Expected Output Values (Sequential)")
    for val in expected_output.flatten():
        print(val)
else:
    print(f"Verification skipped: Input array shape is not (4, 4), but {data_array.shape}.")