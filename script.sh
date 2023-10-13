# This code will work as you put this script in the same directory as the bioInformatics
#AKA the only change you need to make is change the range on i if you have more proteomes or references
#I consider this very flexible

for i in {1..17} #uses muscle to align all the mcrA references
do
~/project/bioInformaticsProject/ref_sequences/muscle -align ~/project/bioInformaticsProject/ref_sequences/mcrAgene_$i.fasta -output ~/project/bioInformaticsProject/ref_sequences/mcrAgene_aligned.fasta
done
#Creates an hmm file for us to search our proteomes with for mcrA
~/project/hmmer-3.3.2/src/hmmbuild mcrA_hmm.hmm ~/project/bioInformaticsProject/ref_sequences/mcrAgene_aligned.fasta

for i in {1..22} #uses muscle to align align all the hsp70 references
do
~/project/bioInformaticsProject/ref_sequences/muscle -align ~/project/bioInformaticsProject/ref_sequences/hsp70gene_$i.fasta -output ~/project/bioInformaticsProject/ref_sequences/hsp70gene_aligned.fasta
done
#Creates an hmm file for us to search our proteomes with for hsp70
~/project/hmmer-3.3.2/src/hmmbuild hsp70gene_hmm.hmm ~/project/bioInformaticsProject/ref_sequences/hsp70gene_aligned.fasta

#searches through the proteomes with hmm, and outputs that data to a table for us. Create our output first
touch hmmsearch_output
touch hmmsearch70_output

#The for loop that searches the proteomes for mcrA and hsp70
for i in {1..50}
do
#mcrA
~/project/hmmer-3.3.2/src/hmmsearch --tblout ~/project/hmmsearch_output mcrA_hmm.hmm ~/project/bioInformaticsProject/proteomes/proteome_$i.fasta
#hsp70
~/project/hmmer-3.3.2/src/hmmsearch --tblout ~/project/hmmsearch70_output hsp70gene_hmm.hmm ~/project/bioInformaticsProject/proteomes/proteome_$i.fasta

#adds the counts for hsp70 and mcrA to a variable
mcrA_Count=$(cat ~/project/hmmsearch_output| grep -v "#" | wc  -l)
hsp70_Count=$(cat ~/project/hmmsearch70_output| grep -v "#" | wc  -l)

#Add those counts in a file in table format
echo proteome_$i, $mcrA_Count, $hsp70_Count >> summary_table
done
