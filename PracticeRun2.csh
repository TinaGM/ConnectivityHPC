
#!/bin/tcsh
#BSUB -n 4
#BSUB -W 10
#BSUB -J TestCostDistance
#BSUB -o stdout.%J
#BSUB -e stderr.%J
R CMD BATCH --no-save --no-restore  singletimestepHPC_firsthalf.R '--args i=20' 
