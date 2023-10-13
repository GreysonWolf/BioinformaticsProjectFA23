#Bioinformatics Project: Carmela D'Antuono and John LeSage

#determining where in the cdc we should be
cd ~/Private/Biocomputing/BioinformaticsProjectFA23/ref_sequences

#creating a for loop to combine all the hsp70 reference genes into one file
for file in hsp70gene_*.fasta
do
cat $file  >> hsp70_reference.fasta
done

#the combined hsp70 reference file goes into Muscle to align the sequences
~/Private/Biocomputing/tools/muscle -align hsp70_reference.fasta -output ALIGNED_hsp.fasta
#the aligned sequence is used with hmmbuild to buld a hmm for hsp70 genes in general
~/Private/Biocomputing/tools/hmmbuild HMM_hsp.hmm ALIGNED_hsp.fasta

#creating a for loop to combine all the mcrA reference genes into one file
for file in mcrAgene_*.fasta
do
cat $file >> mcrA_reference.fasta
done

#the combined mcrA reference file goes into Muscle to align the sequences
~/Private/Biocomputing/tools/muscle -align mcrA_reference.fasta -output ALIGNED_mcrA.fasta
#the aligned sequence is used with hmmbuild to build a hmm for mcrA genes in general
~/Private/Biocomputing/tools/hmmbuild HMM_mcrA.hmm ALIGNED_mcrA.fasta

#create a table for the proteomes while creating the first line that will label the columns
echo "proteome hsp70 mcrA" > ProteomeTable.txt

#create a for loop to compare all the proteomes to the hmm for both hsp70 and mcrA
for file in ../proteomes/proteome_*.fasta #ensures that all the proteomes are checked
do
name=$(echo $file | cut -d / -f 3 | cut -d . -f 1) #create a variable for the proteomes' names
~/Private/Biocomputing/tools/hmmsearch --tblout hsp.output HMM_hsp.hmm $file #compare each proteome to the hsp70 hmm
hsp=$(cat hsp.output | grep -E -v "\#" | wc -l) #determine the number of hsp70 matches for the proteome and assign it to a variable
~/Private/Biocomputing/tools/hmmsearch --tblout mcrA.output HMM_mcrA.hmm $file #compare each proteome to the mcrA hmm
mcrA=$(cat mcrA.output | grep -E -v "\#" | wc -l) #determine the number of mcrA matches for the proteome and assign it to a variable
echo  "$name $hsp $mcrA" >> ProteomeTable.txt #add the name of the proteome, number of hsp70 matches, and number of mcrA matches into the proteome table
done

#search the proteome table and pull out the proteomes we think the grad student should consider
cat ProteomeTable.txt | grep -E "proteome_.. 3 1" >> CandidateProteomes.txt
#we pulled out the proteomes that had a mcrA match and the most amount of hsp70 matches that were seen with at least one mcrA match
#after analyzing the data, it was found that the most hsp70 matches possible with a mcrA match was 3
#the candidate proteomes we selected (3, 42, 45, and 50) all had one mcrA match and 3 hsp70 matches
#these are the proteomes that we believe should be studied as candidate pH-resistant methanogens
