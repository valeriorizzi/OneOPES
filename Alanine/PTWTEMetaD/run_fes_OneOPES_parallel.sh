
#folders with the replicas
array=(`seq 0 0`)

compute_fes() {
  cd $i
  rm fes-*
  cp ../../../FES_from_Reweighting.py .
  ./FES_from_Reweighting.py --skip 25000 --bias metad.rbias --sigma 0.05 --colvar COLVAR.* --cv phi --bin 150 --temp 300 --min -3 --max 2 --deltaFat -0.2 --stride 5000; cd .. ; grep 'DeltaF' $i/fes-* | awk '{print $4}' > $i/deltaF.dat 
}

rm */delta*
for i in ${array[@]}
do
  compute_fes &
done
wait

#append all the deltaF in one file
paste */delta* > deleteme;

#calculate average and stdev of all replicas in time
awk '{sum = 0; for (i = 1; i <= NF; i++) sum += $i; sum /= NF; print NR*1000+5000, sum}' deleteme > temp1;
awk '{sum = 0; sum2 = 0; for (i = 1; i <= NF; i++) sum += $i; sum /= NF; for (i = 1; i <= NF; i++) sum2 += ($i-sum)^2; sum2 /= NF; print sum2}' deleteme > temp2;

paste temp1 temp2 > deltaFall.dat;
rm temp* deleteme 

