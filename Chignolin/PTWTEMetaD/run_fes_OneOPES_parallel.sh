
#folders with the replicas
array=(`seq 0 0`)
#echo "${array[2]}"
rm */delta*

compute_fes() {
  cd $i
  rm fes-* fes_*
  cp ../../..//FES_from_Reweighting.py .
  #Chignolin
  ./FES_from_Reweighting.py --skip 40000 --bias metad.rbias --sigma 0.01 --colvar COLVAR.* --cv rmsd_ca --bin 120 --temp 340 --deltaFat 0.2 --blocks 3 --out fes_blocks.dat;
  ./FES_from_Reweighting.py --skip 40000 --bias metad.rbias --sigma 0.01 --colvar COLVAR.* --cv rmsd_ca --bin 120 --temp 340 --deltaFat 0.2 --out fes_skip40k.dat;
  ./FES_from_Reweighting.py --skip 40000 --bias metad.rbias --sigma 0.01 --colvar COLVAR.* --cv rmsd_ca --bin 120 --temp 340 --deltaFat 0.2 --stride 5000 ; cd .. ; grep 'DeltaF' $i/fes-* | awk '{print -$4}' > $i/deltaF.dat
}

for i in ${array[@]}
do
  compute_fes &
done
wait

#append all the deltaF in one file
paste */delta* > deleteme;

#calculate average and stdev of all replicas in time
#Chignolin
awk '{sum = 0; for (i = 1; i <= NF; i++) sum += $i; sum /= NF; print NR*5000+40000, sum}' deleteme > temp1;
awk '{sum = 0; sum2 = 0; for (i = 1; i <= NF; i++) sum += $i; sum /= NF; for (i = 1; i <= NF; i++) sum2 += ($i-sum)^2; sum2 /= NF; print sum2}' deleteme > temp2;

paste temp1 temp2 > deltaFall.dat;
rm temp* deleteme 
