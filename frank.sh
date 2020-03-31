#!/bin/bash
#set -x

#clean the old shit
rm -f final.txt

grep 'PNAINAR_' fidtocas_20191207_0446.sav | tr -d '[:blank:]' > pnainar.txt
grep -E 'COLIN.+PNAAR' fidtocas_20191207_0446.sav | tr -d '[:blank:]' > colin_pnaar.txt

#for each line extract the VAXXXX, do the match and if it finds domething, append the line
for line in $(cat pnainar.txt); do
    artcode=$(echo $line |grep -oP 'PNAINAR_\K(VA[\d]{5})(?=[\d]*)')
    match=$(grep $artcode colin_pnaar.txt | tail -n1)
    [[ -z "$match" ]] && echo ${line} >> final.txt || echo -n "${line}${match}" | sed 's/\r//' >> final.txt
done

#add the colin-art to the file
grep -E 'COLIN.+ART' fidtocas_20191207_0446.sav | tr -d '[:blank:]' >> final.txt
grep -E 'COLIN.+SCO' fidtocas_20191207_0446.sav | tr -d '[:blank:]' >> final.txt
