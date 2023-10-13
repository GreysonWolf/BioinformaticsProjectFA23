#Usage: $1 = number of proteomes

#mcrA prep
list_mcrA=$(find -name "mcrA*.fasta")

for file in $list_mcrA
do
cat $file >> mcrA_list.fasta
done

~/Private/Biocomputing/tools/muscle -align mcrA_list.fasta -output mcrA_muscle.fasta
~/Private/Biocomputing/tools/hmmbuild mcrA_aligned.hmm mcrA_muscle.fasta

#hsp70 prep
list_hsp70=$(find -name "hsp70*.fasta")

for file in $list_hsp70
do
cat $file >> hsp70_list.fasta
done

~/Private/Biocomputing/tools/muscle -align hsp70_list.fasta -output hsp70_muscle.fasta
~/Private/Biocomputing/tools/hmmbuild hsp70_aligned.hmm hsp70_muscle.fasta

#hmm search for each proteome

for N in {01..50}
do
~/Private/Biocomputing/tools/hmmsearch --tblout proteome_output_mcrA_$N.txt mcrA_aligned.hmm ~/Private/Biocomputing/BioinformaticsProjectFA23/proteomes/proteome_$N.fasta
~/Private/Biocomputing/tools/hmmsearch --tblout proteome_output_hsp70_$N.txt hsp70_aligned.hmm ~/Private/Biocomputing/BioinformaticsProjectFA23/proteomes/proteome_$N.fasta
done

#make output table
for N in {01..50}
do
mcrA_matches=$(cat proteome_output_mcrA_$N.txt | grep -v "^#" |wc -l) 
hsp70_matches=$(cat proteome_output_hsp70_$N.txt | grep -v "^#" | wc -l)
echo "Proteome $N, $mcrA_matches, $hsp70_matches" >> completed_output.csv 
done

#sort output
echo "Proteome name, mcrA gene count, hsp70 gene count" > sorted_table.csv
cat completed_output.csv | sort -t , -k 2 -k 3 -n -r >> sorted_table.csv

#summary table
echo "The proteomes that the graduate student should pursue are:" > gene_summary.txt
cat sorted_table.csv | grep "\, [^0]\," | cut -d, -f 1 >> gene_summary.txt
