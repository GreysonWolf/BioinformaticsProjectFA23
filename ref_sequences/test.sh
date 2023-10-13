
for file in ../proteomes/proteome_*.fasta
do
name=$(echo $file | cut -d . -f 1)
~/Private/Biocomputing/tools/hmmsearch --tblout ../outputs/hsp.output HMM_hsp.hmm $file
done
