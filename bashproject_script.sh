# This script will identify the number of matches for the mcrA gene and hsp70 gene in proteome genomes
# The output is two tables: finalOutput.tbl, which shows the numnber of matches for both genes for all proteomes, and 
# sortedcandidates.tbl, which shows the proteomes containing both genes sorted by number of hsp70 genes (high to low)
# the user inputs a directory name containing files of the format proteome#.fasta to be searched for the genes (argument 1)
# User also inputs the absolute path to the tools directory, which should contain muscle, hmmbuild and hmmsearch (argument 2)
#usage: bash bashproject_script.sh directoryName absPathToTools

#create search image for the mcrA gene
# script assumes that the ref sequnces are stored in the directory ref_sequences with file names in the format mcrAgene_*.fasta

#combine all reference sequences for mcrA gene into one file
cat ref_sequences/mcrAgene_*.fasta > combined_mcrA_refsequences.txt

#align the mcrA reference sequences using muscle
$2/muscle -align combined_mcrA_refsequences.txt -output aligned_mcrA_refsequences.txt

#build search image using hmmbuild
$2/hmmbuild ref_mcrAgene.hmm aligned_mcrA_refsequences.txt


#create search image for the hsp70 gene
#script assumes that the ref ref sequences are stored in the directory ref_sequences with the file names in the format hsp70gene_*.fasta

#combine all reference sequences for hsp70 into one file
cat ref_sequences/hsp70gene_*.fasta > combined_hsp70_refsequences.txt

#align the hsp70 reference sequences using muscle
$2/muscle -align combined_hsp70_refsequences.txt -output aligned_hsp70_refsequences.txt

#build search image using hmmbuild
$2/hmmbuild ref_hsp70gene.hmm aligned_hsp70_refsequences.txt

#build table with proteome number, number of mcrA genes, and number of hsp70 genes

#establish variable for the proteome being analyzed
let protNum=0

#print column titles for table
echo "Proteome Number, mcrA Matches, hsp70 Matches" > finalOutput.csv

#loop for finding number of mcrA genes and hsp70 genes in list of proteomes

for genome in $1/proteome*.fasta
do
	#protNum will equal the number of the proteome being analyzed
	let protNum=$protNum+1
	#search proteome for mcrA matches, store number of matches in variable mcrAMatch
	$2/hmmsearch --tblout $genome.moutput ref_mcrAgene.hmm $genome
	mcrAMatch=$(cat $genome.moutput | grep -v "^#" | wc -l)
	rm $genome.moutput
	#search proteome for hsp70 matches, store number of matches in variable hsp70Match
	$2/hmmsearch --tblout $genome.houtput ref_hsp70gene.hmm $genome
	hsp70Match=$(cat $genome.houtput | grep -v "^#" | wc -l)
	rm $genome.houtput
	#add proteome number, number of mcrA matches, and number of hsp70 matches to the final output file
	echo "$protNum, $mcrAMatch, $hsp70Match" >> finalOutput.csv
done

#this takes our final output file and creates a table

column finalOutput.csv -t -s "," > outputTable.tbl


cat finalOutput.csv |tail -n +2 | grep -v -w "0" >> candidates.csv

# This is how to sort the datafile with the proteome that has the most hsp70 matches at the top
echo "ProteomeNumber,mcrAMatches,hsp70Matches" > sortedcandidates.csv
cat candidates.csv |  sort -k3 -n -r >> sortedcandidates.csv

# This will create a table of the sorted candidates

column sortedcandidates.csv -t  -s "," > sortedcandidates.tbl

# remove all unnecessary files that were created with the script

rm aligned_*_refsequences.txt
rm combined_*_refsequences.txt
rm sortedcandidates.csv
rm finalOutput.csv
rm candidates.csv
rm ref_*gene.hmm
