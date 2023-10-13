#USAGE: bash TableScript.sh 
cd ~/Private/BioinformaticsProjectFA23/ref_sequences

#STEP 1. Combine refseq files into one file (two files for each genes)
cat mcrAgene_**.fasta > mcrA_refseq.fasta
cat hsp70gene_**.fasta > hsp70_refseq.fasta

#STEP 2. Use MUSCLE command to align the fasta file (two hmm files for each genes)
~/Private/Biocomputing/tools/muscle -align mcrA_refseq.fasta -output mcrA_alignment.fasta
~/Private/Biocomputing/tools/muscle -align hsp70_refseq.fasta -output hsp70_alignment.fasta

#STEP 3. Use hmmbuild output to HMM file
~/Private/Biocomputing/tools/hmmbuild mcrA_build.hmm mcrA_alignment.fasta
~/Private/Biocomputing/tools/hmmbuild hsp70_build.hmm hsp70_alignment.fasta

#STEP 4. Use hmmsearch to look for both genes into proteomes file
mv hsp70_build.hmm ~/Private/BioinformaticsProjectFA23/proteomes
mv mcrA_build.hmm ~/Private/BioinformaticsProjectFA23/proteomes

cd ~/Private/BioinformaticsProjectFA23/proteomes

for gene in {01..50}
do 
~/Private/Biocomputing/tools/hmmsearch --tblout proteome_mcrAgene$gene.output mcrA_build.hmm proteome_$gene.fasta
done

for gene in {01..50}
do 
~/Private/Biocomputing/tools/hmmsearch --tblout proteome_hsp70gene$gene.output hsp70_build.hmm proteome_$gene.fasta
done

#STEP 5. Making the table

cat proteome_mcrAgene**.output > proteome_mcrAgene.output
cat proteome_mcrAgene.output | grep -v "#" > proteome_mcrAResult.output

cat proteome_hsp70gene**.output > proteome_hsp70gene.output
cat proteome_hsp70gene.output | grep -v "#" > proteome_hsp70Result.output

cut -d " " -f 1 proteome_mcrAResult.output | sort -u  > proteome_mcrAMatches.output
cut -d " " -f 1 proteome_hsp70Result.output | sort -u > proteome_hsp70Matches.output

#creating column 1 with proteome names
for gene in proteome_{01..50}
do
echo $gene >> Col1.txt
done
echo Proteome_Number >> Col1.txt

#creating column 2 with mcrA matches
for gene in proteome_{01..50}.fasta
do
grep -c  -f proteome_mcrAMatches.output $gene >> mcrAMatches.txt
done
echo mcrA_Matches >> mcrAMatches.txt

#creating column 3 with hsp70 matches
for gene in proteome_{01..50}.fasta
do
grep -c  -f proteome_hsp70Matches.output $gene >> hsp70Matches.txt
done
echo hsp70_Matches >> hsp70Matches.txt

#combining columns to produce the final table
paste Col1.txt mcrAMatches.txt hsp70Matches.txt > FinalTable.txt
sort -r -k 1 FinalTable.txt > SortedFinalTable.txt

