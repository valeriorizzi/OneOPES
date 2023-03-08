mpirun -n 8 gmx_mpi mdrun -deffnm prd -multidir 0 1 2 3 4 5 6 7 -replex 10000 -hrex -nsteps 125000000  -plumed plumed.dat
