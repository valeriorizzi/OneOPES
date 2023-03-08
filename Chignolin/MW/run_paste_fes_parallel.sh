
cp ../../FES_from_Reweighting.py .

rm fes-* fes_*
tail -n +2 0/COLVAR.0 > test0
tail -n +2 1/COLVAR.1 > test1
tail -n +2 2/COLVAR.2 > test2
tail -n +2 3/COLVAR.3 > test3
tail -n +2 4/COLVAR.4 > test4
tail -n +2 5/COLVAR.5 > test5
tail -n +2 6/COLVAR.6 > test6
tail -n +2 7/COLVAR.7 > test7
paste -d \\n test*  > testall
head -n 1 0/COLVAR.0 > COLVARheader
cat COLVARheader testall > COLVARall
rm test*

./FES_from_Reweighting.py --skip 80000 --sigma 0.01 --colvar COLVARall --cv rmsd_ca --bin 120 --temp 340 --deltaFat 0.2 --stride 40000; grep 'DeltaF' fes-* | awk '{print -$4}' > temp
awk '{print NR*40000+80000,$1}' temp > pastetimedeltaF.dat
