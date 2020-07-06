
#!/bin/tcsh
#BSUB -n 4
#BSUB -W 10
#BSUB -J TestCostDistance
#BSUB -o stdout.%J
#BSUB -e stderr.%J
Rscript singletimestepHPC_firsthalf.R i=20
