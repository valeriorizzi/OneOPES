gmx_mpi grompp -f md.mdp -c folded.pdb -p topol.top -o prd.tpr -maxwarn 1
mpirun -n 8 gmx_mpi mdrun -deffnm prd -multidir 0 1 2 3 4 5 6 7 -replex 10000 -hrex -plumed plumed.dat -nsteps 100000000 &
