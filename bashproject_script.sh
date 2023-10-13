# This script will identify the number of matches mcrA gene and hsp70 gene in a user inputed proteome file
#usage: bash bashproject_script.sh

#create search image for the mcrA gene

#combine all reference sequences for mcrA gene into one file
cat ref_sequences/mcrAgene_*.fasta > combined_mcrA_refsequences.txt

#align the mcrA reference sequences using muscle
~/Private/Biocomputing/tools/muscle -align combined_mcrA_refsequences.txt -output aligned_mcrA_refsequences.txt

#build search image using hmmbuild
~/Private/Biocomputing/tools/hmmbuild ref_mcrAgene.hmm aligned_mcrA_refsequences.txt


#create search image for the hsp70 gene

#combine all reference sequences for hsp70 into one file
cat ref_sequences/hsp70gene_*.fasta > combined_hsp70_refsequences.txt

#align the hsp70 reference sequences using muscle
~/Private/Biocomputing/tools/muscle -align combined_hsp70_refsequences.txt -output aligned_hsp70_refsequences.txt

#build search image using hmmbuild
~/Private/Biocomputing/tools/hmmbuild ref_hsp70gene.hmm aligned_hsp70_refsequences.txt

#build table with proteome number, number of mcrA genes, and number of hsp70 genes

#establish variable for the proteome being analyzed
let protNum=0

#print column titles for table
echo "Proteome Number, mcrA Matches, hsp70 Matches" > finalOutput.csv

#loop for finding number of mcrA genes and hsp70 genes in list of proteomes
for genome in proteomes/proteome*.fasta
do
	#protNum will equal the number of the proteome being analyzed
	let protNum=$protNum+1
	#search proteome for mcrA matches, store number of matches in variable mcrAMatch
	~/Private/Biocomputing/tools/hmmsearch --tblout $genome.moutput ref_mcrAgene.hmm $genome
	mcrAMatch=$(cat $genome.moutput | grep -v "^#" | wc -l)
	rm $genome.moutput
	#search proteome for hsp70 matches, store number of matches in variable hsp70Match
	~/Private/Biocomputing/tools/hmmsearch --tblout $genome.houtput ref_hsp70gene.hmm $genome
	hsp70Match=$(cat $genome.houtput | grep -v "^#" | wc -l)
	rm $genome.houtput
	#add proteome number, number of mcrA matches, and number of hsp70 matches to the final table
	echo "$protNum, $mcrAMatch, $hsp70Match" >> finalOutput.csv
done

#this takes our final output file and creates a table

column finalOutput.csv -t -s "," > outputTable.tbl


cat finalOutput.csv |tail -n +2 | grep -v -w "0" >> candidates.csv

# This is how to sort the data
echo "ProteomeNumber,mcrAMatches,hsp70Matches" > sortedcandidates.csv
cat candidates.csv |  sort -k3 -n -r >> sortedcandidates.csv

# This will create a table the sorted candidates

column sortedcandidates.csv -t  -s "," > sortedcandidates.tbl

# remove all unnecessary files

rm aligned_*_refsequences.txt
rm combined_*_refsequences.txt
rm sortedcandidates.csv
rm finalOutput.csv
rm candidates.csv
rm ref_*gene.hmm
