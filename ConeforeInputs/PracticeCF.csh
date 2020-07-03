
#!/bin/tcsh
#BSUB -n 4
#BSUB -W 60
#BSUB -J TestCostDistance
#BSUB -o stdout.%J
#BSUB -e stderr.%J
#BSUB -R span[hosts=1] 
#BSUB -R "rusage[mem=64000]"
R CMD BATCH ConeforHPC.R
