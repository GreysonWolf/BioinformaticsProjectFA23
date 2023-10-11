# Here we can compile all of the code so it will be easier to track
# First, we have to combine the hsp70 and mcrA ref_sequences files

cat hsp70gene_*.fasta >> combined_hsp70_refsequences.txt
cat mcrAgene_*.fasta >>  combined_mcrA_refsequences.txt

#Once we have the combined files we can align the sequences
# Not sure how we would run it for both the genes, or if that is necessary

~/Private/Biocomputing/tools/muscle -align combined_*_refsequences.txt -output algined

# With aligned sequences we used  make the markov makeup thing

~/Private/Biocomputing/tools/hmmbuild [outputfilename] [inputfilename]

#Use hmmsearch to find the matches in the genome

~/Private/Biocomputing/tools/hmmsearch --tblout [output filename] *.hmm [genome filename]
