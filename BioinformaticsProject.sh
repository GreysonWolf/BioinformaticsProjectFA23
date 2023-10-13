#Bioinformatics Project Shell Script: Emily Rao and Allie Wu

#Usage: bash BioinformaticsProject.sh

#Start by combining mcrA sequences into a single file
cat ./BioinformaticsProject/ref_sequences/mcrAgene* > mcrAcombined.fasta

#Repeat with hsp70 files
cat ./BioinformaticsProject/ref_sequences/hsp70gene* > hspcombined.fasta

#Use muscle to align combined mcrA file data
./muscle -align mcrAcombined.fasta -output mcrA_aligned.fasta

#Use hmmbuild to build HMM file for mcrA genes
./hmmbuild mcrAgene.hmm mcrA_aligned.fasta

#Repeat muscle and hmmbuild steps with hsp70 files
./muscle -align hspcombined.fasta -output hsp_aligned.fasta
./hmmbuild hspgene.hmm hsp_aligned.fasta

#Combine mcrA and hsp70 proteome matches into a single 50x3 table
##Create csv file for table and include title of each column using echo
echo "Proteome Name, Number Matched mcrA, Number Matched hsp70" > combinedtable.csv

#Use for loop to run through all proteome names and each proteome's number of matched mcrA and hsp70 genes
##Use hmmsearch to search for gene matches in each proteome
##We wrote the code in order of (1) hmmsearch and number of matches for mcrA, then (2) hmmsearch and number of matches for hsp70 to avoid overwriting the previous proteome's matches
for i in ./BioinformaticsProject/proteomes/*.fasta
do
proteomes=$(echo "$i" | grep -o "proteome_[0-9][0-9]*")
./hmmsearch --tblout mcrAmatch.csv mcrAgene.hmm $i
mcrAmatch=$(cat mcrAmatch.csv | grep -v "#" | wc -l)
##grep -v removes all lines that have # characters (the lines that we don't want), and wc -l then returns the number of lines that do not have # characters
./hmmsearch --tblout hspmatch.csv hspgene.hmm $i
hsp70match=$(cat hspmatch.csv | grep -v "#" | wc -l)
##Combine these variables into the three columns in the table we made
echo "$proteomes, $mcrAmatch, $hsp70match" >> combinedtable.csv
done

#Create text file with a list of the candidate pH-resistant methanogens (does not include number of matched mcrA and hsp70 genes, only the proteome names)
echo "List of candidate pH-resistant methanogens" > proteomecandidates.txt
cat combinedtable.csv | tail -n +2 | grep -v ", 0" | cut -d , -f 1 >> proteomecandidates.txt
##tail -n +2 gets rid of the column name, grep -v removes all lines that have a zero after a comma (non-matched mcrA or hsp70), cut -f 1 returns only the first column (proteome names)

