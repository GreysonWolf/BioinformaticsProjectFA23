cat ref_sequences/mcrAgene_*.fasta > combined_mcrA_refsequences.txt
~/Private/Biocomputing/tools/muscle -align combined_mcrA_refsequences.txt -output aligned_mcrA_refsequences.txt
~/Private/Biocomputing/tools/hmmbuild ref_mcrAgene.hmm aligned_mcrA_refsequences.txt

cat ref_sequences/hsp70gene_*.fasta > combined_hsp70_refsequences.txt
~/Private/Biocomputing/tools/muscle -align combined_hsp70_refsequences.txt -output aligned_hsp70_refsequences.txt
~/Private/Biocomputing/tools/hmmbuild ref_hsp70gene.hmm aligned_hsp70_refsequences.txt

let protNum=0
echo "Proteome Number mcrA Matches hsp70 Matches" > mcrA_test.txt
for genome in proteomes/proteome*.fasta
do
	let protNum=$protNum+1
	~/Private/Biocomputing/tools/hmmsearch --tblout $genome.moutput ref_mcrAgene.hmm $genome
	mcrAMatch=$(cat $genome.moutput | grep -v "^#" | wc -l)
	rm $genome.moutput
	~/Private/Biocomputing/tools/hmmsearch --tblout $genome.houtput ref_hsp70gene.hmm $genome
	hsp70Match=$(cat $genome.houtput | grep -v "^#" | wc -l)
	rm $genome.houtput
	echo "proteome$protNum $mcrAMatch $hsp70Match" >> mcrA_test.txt
done
