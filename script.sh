# usage: bash script.sh

# Combine reference sequences for a gene into one file
cat ./ref_sequences/mcrAgene* > ./ref_sequences/mcrA.refs
cat ./ref_sequences/hsp70gene* > ./ref_sequences/hsp70.refs

# Combined file goes into Muscle to align
~/Private/Biocomputing/tools/muscle -align ./ref_sequences/mcrA.refs -output ./ref_sequences/mcrA_aligned.festa
~/Private/Biocomputing/tools/muscle -align ./ref_sequences/hsp70.refs -output ./ref_sequences/hsp70_aligned.festa

# Build hmm using build from our alignment
~/Private/Biocomputing/tools/hmmbuild ./ref_sequences/mcrA_refs.hmm ./ref_sequences/mcrA_aligned.festa
~/Private/Biocomputing/tools/hmmbuild ./ref_sequences/hsp70_refs.hmm ./ref_sequences/hsp70_aligned.festa


# Use hmmsearch with an hmm we created and proteome
path_to_outcomes="./outcomes"
mkdir -p "$path_to_outcomes"

for file in ./proteomes/proteome*
do
    base_name=$(echo "$file" | grep -o 'proteome_[0-9][0-9]*')
    
    output_file_mcrA="$path_to_outcomes/${base_name}_mcrA.outcome"
    output_file_hsp70="$path_to_outcomes/${base_name}_hsp70.outcome"
    ~/Private/Biocomputing/tools/hmmsearch ./ref_sequences/mcrA_refs.hmm "$file" > "$output_file_mcrA"
    ~/Private/Biocomputing/tools/hmmsearch ./ref_sequences/hsp70_refs.hmm "$file" > "$output_file_hsp70"

done


# Produce a summary table collating the results of all searches
echo "proteome,num of mcrA genes,num of hsp70 genes" > sum_table.csv
for file in ./proteomes/proteome*
do
    proteome=$(echo "$file" | grep -o 'proteome_[0-9][0-9]*')
    mcrA=$(cat "./outcomes/${proteome}_mcrA.outcome" | grep ">>" | wc -l )
    hsp70=$(cat "./outcomes/${proteome}_hsp70.outcome" | grep ">>" | wc -l )
    echo "$proteome, $mcrA, $hsp70" >> sum_table.csv
done


# Generate a text file with the names of the candidate pH-resistant methanogens
# top 15
cat sum_table.csv | tail -n +2 | grep -v "0$" | grep -v " 0," | sort -t , -k 3 -k 2 -r | head -n 15 | cut -d, -f1 >> candidates.txt
