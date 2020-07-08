
#!/bin/tcsh
#BSUB -n 4
#BSUB -W 48:00
#BSUB -J TestCostDistance
#BSUB -o stdout.%J
#BSUB -e stderr.%J
#BSUB -R "rusage[mem=128000]"
R CMD BATCH singletimestepHPCgen.R
