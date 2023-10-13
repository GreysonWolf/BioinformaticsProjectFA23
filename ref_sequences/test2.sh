echo "proteome hsp70 mcrA" > FINAL.txt

for file in ../proteomes/proteome_*.fasta
do
name=$(echo $file | cut -d / -f 3 | cut -d . -f 1)
~/Private/Biocomputing/tools/hmmsearch --tblout hsp.output HMM_hsp.hmm $file
hsp=$(cat hsp.output | grep -E -v "\#" | wc -l)
~/Private/Biocomputing/tools/hmmsearch --tblout mcrA.output HMM_mcrA.hmm $file
mcrA=$(cat mcrA.output | grep -E -v "\#" | wc -l)
echo  "$name $hsp $mcrA" >> FINAL.txt
done
