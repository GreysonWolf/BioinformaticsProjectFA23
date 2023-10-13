#### usage: bash bioinformatics.sh

## create hmm for McrA genes
# compile all reference sequences into one file
for n in {01..18}
	do
        cat ref_sequences/mcrAgene_$n.fasta >> McrA.fasta
        done

# use muscle to align McrA reference sequences
~/Private/Biocomputing/tools/muscle -in McrA.fasta -out McrAalignment.fasta

# build a HMM for McrA
~/Private/Biocomputing/tools/hmmbuild McrA_hmm.fasta McrAalignment.fasta

## create hmm for HSP70 genes
# combine reference sequences for HSP70 genes
for n_hsp in {01..18}
        do
        cat ref_sequences/hsp70gene_$n_hsp.fasta >> hsp70.fasta
        done

# use muscle to align HSP70 reference sequences
~/Private/Biocomputing/tools/muscle -in hsp70.fasta -out hsp70alignment.fasta

# build a HMM for hsp70
~/Private/Biocomputing/tools/hmmbuild hsp70_hmm.fasta hsp70alignment.fasta

# identify the isolates that contain the McrA gene and the most HSP70 gene copies
for n in {01..50}
do
	~/Private/Biocomputing/tools/hmmsearch --tblout proteome_$n.mcra McrA_hmm.fasta proteomes/proteome_$n.fasta
	~/Private/Biocomputing/tools/hmmsearch --tblout proteome_$n.hsp70 hsp70_hmm.fasta proteomes/proteome_$n.fasta
done

# create csv file with proteome output
echo proteome_number,McrA_copies,HSP70_copies >> proteometable.csv

# count the number of genes of mcra and hsp70 for each proteome
for n in {01..50}
do

	num_mcra=$(cat proteome_$n.mcra | grep -E -v "^#" | wc -l)
	num_hsp70=$(cat proteome_$n.hsp70 | grep -E -v "^#" | wc -l)
	echo proteome_$n,$num_mcra,$num_hsp70 >> proteometable.csv
done

## proteomes to look into further
# sort proteome.csv by the number of mcra genes, then the number of hsp70 genes
cat proteometable.csv | grep -E -w -v 0 | sort -r -t , -k 3,2 > proteome_summary.csv

