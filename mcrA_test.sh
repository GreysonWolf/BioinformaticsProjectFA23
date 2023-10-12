cat ref_sequences/mcrAgene_*.fasta > combined_mcrA_refsequences.txt
~/Private/Biocomputing/tools/muscle -align combined_mcrA_refsequences.txt -output aligned_mcrA_refsequences.txt
~/Private/Biocomputing/tools/hmmbuild ref_mcrAgene.hmm aligned_mcrA_refsequences.txt

cat ref_sequences/hsp70gene_*.fasta > combined_hsp70_refsequences.txt
~/Private/Biocomputing/tools/muscle -align combined_hsp70_refsequences.txt -output aligned_hsp70_refsequences.txt
~/Private/Biocomputing/tools/hmmbuild ref_hsp70gene.hmm aligned_hsp70_refsequences.txt

for genome in proteomes/proteome*.fasta
do
	echo -n "$genome " >> mcrA_test.txt
	~/Private/Biocomputing/tools/hmmsearch --tblout $genome.moutput ref_mcrAgene.hmm $genome
	cat $genome.moutput | grep -v "^#" | wc -l | tr -d '\n' >> mcrA_test.txt
	rm $genome.moutput
	~/Private/Biocomputing/tools/hmmsearch --tblout $genome.houtput ref_hsp70gene.hmm $genome
	cat $genome.houtput | grep -v "^#" | wc -l >> mcrA_test.txt
	rm $genome.houtput
done
