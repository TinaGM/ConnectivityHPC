
#!/bin/tcsh
#BSUB -n 4
#BSUB -W 20
#BSUB -J TestRLandscape
#BSUB -o stdout.%J
#BSUB -e stderr.%J
#BSUB -R "rusage[mem=16000]"
R CMD BATCH singletimestepHPC_firsthalf.R
