
#!/bin/tcsh
#BSUB -n 4
#BSUB -W 10
#BSUB -J TestCostDistance
#BSUB -o stdout.%J
#BSUB -e stderr.%J
#BSUB -R "rusage[mem=8000]"
R CMD BATCH singletimestepHPC_firsthalf.R
