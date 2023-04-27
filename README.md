# PWL-Approximation-for-nth-root-of-R
In this project, we propose a methodology for performing Nth root computations on floating-point numbers based on the piecewise linear (PWL) approximation method. The proposed method divides an Nth root computation into several subtasks approximated by the PWL algorithm.

We have cretaed a python file (Main.py) to automate the generation of hardware architetcure(verilog file) based on the number of the segments given.

The python file also generates constraint_sdc for synthesising in genus flow. 

# Hardware Architecture

### The pwl_kbinputs.v, contraints_sdc has the modules designed for 10 segments.

## Schematic

### PWL Implementation 
![Image](https://github.com/Bhuvan506/PWL-Approximation-for-nth-root-of-R/blob/main/images/Schematic1.png)

### Multiplier
![Image](https://github.com/Bhuvan506/PWL-Approximation-for-nth-root-of-R/blob/main/images/Schematic2.png)


# Matlab

We have done matlab simulations for various values of n as shown below.

## R<sup>(1/2)</sup>
![Image](https://github.com/Bhuvan506/PWL-Approximation-for-nth-root-of-R/blob/main/Simulations/root2.png)

## R<sup>(1/3)</sup>
![Image](https://github.com/Bhuvan506/PWL-Approximation-for-nth-root-of-R/blob/main/Simulations/root3.png)

## R<sup>(1/5)</sup>
![Image](https://github.com/Bhuvan506/PWL-Approximation-for-nth-root-of-R/blob/main/Simulations/root5.png)

## R<sup>(1/15)</sup>
![Image](https://github.com/Bhuvan506/PWL-Approximation-for-nth-root-of-R/blob/main/Simulations/root15.png)

# Genus Flow

## Run Genus flow
```
csh
source new_cshrc_hep    #opens cadence terminal
genus -legacy_ui
source script.tcl
```

This repo contains the gpdk 45nm file. Genus sysnthesis flow can be done if the cadence is already setup in the pc by running the above commands.

The above design was synthesized using genus with gpdk 45nm tehcnology node. Genus_report folder contains the report for the same.
All_reports folder contains the genus reports generated for various clock frequencies.

The reports are sumamrized in the below table:

![Image](https://github.com/Bhuvan506/PWL-Approximation-for-nth-root-of-R/blob/main/images/table.png)


# Timing Summary

![Image](https://github.com/Bhuvan506/PWL-Approximation-for-nth-root-of-R/blob/main/images/Summary.png)




