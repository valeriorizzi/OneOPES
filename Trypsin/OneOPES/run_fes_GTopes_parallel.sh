
#folders with the replicas
array=(`seq 0 0`)
#echo "${array[2]}"
rm */delta*

compute_fes() {
  cd $i
  rm fes*

  #Trypsin
  cp ../funnel_FES_from_Reweighting.py .
  head -n 250005 COLVAR.* > COLVAR
  #./funnel_FES_from_Reweighting.py --skiprows 25000 --sigma 0.01 --bias opes.bias --colvar COLVAR --cv d1.z --bin 300 --temp 300 --min 0.2 --max 2.0 --rfunnel 0.2 --uat 1.8 --bat 0.8 --blocks 3 --outfile fes_blocks.dat
  ./funnel_FES_from_Reweighting.py --skiprows 25000 --sigma 0.01 --bias opes.bias --colvar COLVAR --cv d1.z --bin 300 --temp 300 --min 0.2 --max 2.0 --rfunnel 0.2 --uat 1.8 --bat 0.8 --outfile fesskip25k.dat
  ./funnel_FES_from_Reweighting.py --skiprows 25000 --sigma 0.01 --bias opes.bias --colvar COLVAR --cv d1.z --bin 300 --temp 300 --min 0.2 --max 2.0 --rfunnel 0.2 --uat 1.8 --bat 0.8 --stride 5000; cd .. ; grep 'fundeltaF' $i/fes-* | awk '{print $4}' > $i/deltaF.dat
}

for i in ${array[@]}
do
  compute_fes &
done
wait

#append all the deltaF in one file
paste */delta* > deleteme;

#calculate average and stdev of all replicas in time
#Trypsin
awk '{sum = 0; for (i = 1; i <= NF; i++) sum += $i; sum /= NF; print NR*5000+25000, sum}' deleteme > temp1;
awk '{sum = 0; sum2 = 0; for (i = 1; i <= NF; i++) sum += $i; sum /= NF; for (i = 1; i <= NF; i++) sum2 += ($i-sum)^2; sum2 /= NF; print sum2}' deleteme > temp2;

paste temp1 temp2 > deltaFall.dat;
rm temp* deleteme 
