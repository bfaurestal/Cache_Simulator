# Cache Simulator
## Split L1 Cache
## How to Run in Questasim/Modelsim
### Compilation
```console
vlog +lint parameters.sv address_parse.sv File_Handler.sv cache.sv mesi_protocol_i.sv
```
### Simulation
#### Debug Mode
```console
vsim +lint +f=testfile.txt +d File_Handler
run -all
```
#### Silent Mode
```console
vsim +lint +f=testfile.txt +s File_Handler
run -all
```
### Print Statistics
#### While in Simulation
```console
vsim quit
```
