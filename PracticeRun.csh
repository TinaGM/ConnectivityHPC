
#!/bin/tcsh
#BSUB -n 4
#BSUB -W 600
#BSUB -J TestCostDistance
#BSUB -o stdout.%J
#BSUB -e stderr.%J
#BSUB -R "rusage[mem=32000]"
R CMD BATCH singletimestepHPC.R
