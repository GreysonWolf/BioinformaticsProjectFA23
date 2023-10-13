# Bioinformatics Project: Thomas Joyce and Patrick Kuebler 
# Script to create table and list of proteomes of interest
# Usage: bash project_script.sh

# Combine all of the reference sequences for hsp70 into a single file called hsp70.refs
for filename in ~/Private/Biocomputing/BioinformaticsProjectFA23/ref_sequences/hsp70gene*
do  
	cat $filename >> hsp70.refs
done

# Combine all of the reference sequences for mcrA into a single file called mcrA.refs
for filename in ~/Private/Biocomputing/BioinformaticsProjectFA23/ref_sequences/mcrAgene*
do
	cat $filename >> mcrA.refs
done

# Sequence alignment with muscle for hsp70.refs
~/Private/Biocomputing/tools/muscle -align ~/Private/Biocomputing/BioinformaticsProjectFA23/hsp70.refs -output hsp70_alignment.fasta

# Sequence alignment with muscle for mcrA.refs
~/Private/Biocomputing/tools/muscle -align ~/Private/Biocomputing/BioinformaticsProjectFA23/mcrA.refs -output mcrA_alignment.fasta

# hmmbuild for hsp70_alignment.fasta
 ~/Private/Biocomputing/tools/hmmbuild hsp70.hmm hsp70_alignment.fasta

# hmmbuild for mcrA_alignment.fasta
 ~/Private/Biocomputing/tools/hmmbuild mcrA.hmm mcrA_alignment.fasta

# Create a 50 by 3 table with proteome name, mcrA gene copies, and hsp70 gene copies
echo "proteome_name,mcrA_copies,hsp70_copies" > 50by3_table

# hmmsearch for each of the 50 proteomes
for filename in  ~/Private/Biocomputing/BioinformaticsProjectFA23/proteomes/*
do
	name=$(echo "$filename" | grep -E -o "proteome_[0-9]{2}")

	~/Private/Biocomputing/tools/hmmsearch --tblout mcrA.output mcrA.hmm $filename
	mcrA_copies=$(grep "WP" mcrA.output | wc -l)

	~/Private/Biocomputing/tools/hmmsearch --tblout hsp70.output hsp70.hmm $filename
	hsp70_copies=$(grep "WP" hsp70.output | wc -l)

	echo "$name,$mcrA_copies,$hsp70_copies" >> 50by3_table
done

# Create text file with the names of the candidate pH-resistant methanogens
# Select proteomes with 1 or more copies of mcrA and 3 or more copies of hsp70
cat 50by3_table | grep -E "proteome_[0-9]{2},[^0],[^0-2]" | cut -d , -f 1 > candidate_proteomes

# Change the formatting of the 50by3_table into discrete columns and write this to a file called final_table
column 50by3_table -t -s "," > final_table

# Remove files that are no longer needed
rm 50by3_table mcrA.output hsp70.output
