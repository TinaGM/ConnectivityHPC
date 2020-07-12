#!/bin/csh
echo "Job1"
bsub -n 4 -W 540 -J "Test1" -o stdout.%J -e stderr.%J -R "rusage[mem=33000]" "HPCgeos500_r1_0.R"
echo "Job2"
bsub -n 4 -W 540 -J "Test1" -o stdout.%J -e stderr.%J -R "rusage[mem=33000]" "HPCgeos500_r1_10.R"
echo "Job3"
bsub -n 4 -W 540 -J "Test1" -o stdout.%J -e stderr.%J -R "rusage[mem=33000]" "HPCgeos500_r1_20.R"
echo "Job4"
bsub -n 4 -W 540 -J "Test1" -o stdout.%J -e stderr.%J -R "rusage[mem=33000]" "HPCgeos500_r1_30.R"