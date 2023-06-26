
#warning, here I assume the the energy is in column 6. If not change the REWEIGHT factor line accordingly
#also I expect the last column to be opesE3.bias. If not, change the sed so that the last column is correct
#and the constant factor shift is system dependent. Decide it according to numerical stability

deltaT=2.5
thermostat=340

kappa=0.00831441002
kT0="$(echo "$kappa*$thermostat" | bc)"
deltakT="$(echo "$kappa*$deltaT" | bc)"

#indexes
array=(`seq 0 8`)
rm Xfes* Xdel*

for i in ${array[@]}
do
  kT="$(echo "$deltakT*$i+$kT0" | bc)"
  T="$(echo "$deltaT*$i+$thermostat" | bc)"
  const="$(echo "1000*$i" | bc)"
  nameout="$(echo "Xfes$T.dat" )"
  nameout2="$(echo "Xfes$T\_*" )"

  echo "$T"
  #echo $nameout2

  #REWEIGHT factor
  head -n 1 COLVAR.* > COLVARheader
  tail -n +2 COLVAR.* > temp_COLVAR
  awk -v kTtarget="$kT" -v kTzero="$kT0" -v c="$const" '{{for(i=1;i<=NF;i++){printf "%s ", $i};{printf "%10.2f ", (-1/kTtarget+1/kTzero)*kTzero*$6+c};printf "\n"}}' temp_COLVAR > temp_COLVAR2
  cat COLVARheader temp_COLVAR2 > XCOLVAR
  sed -i "s/opesE3.bias/opesE3.bias multiT.bias/g" XCOLVAR
  ./FES_from_Reweighting.py --skip 40000 --sigma 0.01 --colvar XCOLVAR --cv rmsd_ca --bin 120 --temp 340 --deltaFat 0.2 --blocks 4 --out $nameout;
  grep 'DeltaF' $nameout2 | awk '{print -$4}' > temp;

  #average and stdev of the blocks
  awk '{ sum+=$1 } END { print sum/NR }' temp > temp_avg
  awk '{ sum+=$1; sum2+=$1^2} END {print sqrt(sum2/NR-(sum/NR)^2)}' temp > temp_stdev
  paste temp_avg temp_stdev > temp_stat

  awk -v temperature="$T" '{print temperature,$1,$2}' temp_stat > temp2
  cat XdeltaF.dat temp2 > temp3
  mv temp3 XdeltaF.dat
  rm temp*
done

