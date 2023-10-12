cat ref_sequences/mcrAgene_*.fasta > combined_mcrA_refsequences.txt
~/Private/Biocomputing/tools/muscle -align combined_mcrA_refsequences.txt -output aligned_mcrA_refsequences.txt
~/Private/Biocomputing/tools/hmmbuild ref_mcrAgene.hmm aligned_mcrA-refsequences.txt
for genome in proteomes/proteome*.fasta
do
	echo "$genome , " | tr -d '\n' >> mcrA_test.txt
	~/Private/Biocomputing/tools/hmmsearch --tblout $genome.moutput ref_mcrAgene.hmm $genome
	cat $genome.moutput | grep -v "^#" | wc -l >> mcrA_test.txt
done
