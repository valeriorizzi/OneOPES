LIBTORCH=~/programs/plumed2-2.9/libtorch
source ${LIBTORCH}/sourceme.sh;source /home/rizziv@farma.unige.ch/programs/plumed2-2.9/sourceme.sh;source /home/rizziv@farma.unige.ch/programs/gromacs-2022.3/install_single_cpu/bin/GMXRC
export OMP_NUM_THREADS=1

create_tpr() {
  cd $i
  gmx_mpi grompp -f ../md.mdp -c ../config.gro -p ../topol.top -o topol2.tpr
}

array=(`seq 0 7`)

for i in ${array[@]}
do
  create_tpr &
  #echo $i
done
wait

#for 50 ns simulation
mpirun -n 8 gmx_mpi mdrun -s topol2.tpr -plumed plumed.dat -pin on -pinoffset 0 -nsteps 25000000 -multidir 0 1 2 3 4 5 6 7 -hrex -replex 10000 &
wait

./run_fes_OneOPES_parallel.sh
