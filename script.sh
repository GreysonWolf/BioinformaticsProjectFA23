
# Combine reference sequences for a gene into one file
cat ./ref_sequences/mcrAgene* > ./ref_sequences/mcrA.refs
cat ./ref_sequences/hsp70gene* > ./ref_sequences/hsp70.refs

# Combined file goes into Muscle to align
~/Private/Biocomputing/tools/muscle -align ./ref_sequences/mcrA.refs -output ./ref_sequences/mcrA_aligned.festa
~/Private/Biocomputing/tools/muscle -align ./ref_sequences/hsp70.refs -output ./ref_sequences/hsp70_aligned.festa

# Build hmm using build from our alignment
~/Private/Biocomputing/tools/hmmbuild ./ref_sequences/mcrA_refs.hmm ./ref_sequences/mcrA_aligned.festa
~/Private/Biocomputing/tools/hmmbuild ./ref_sequences/hsp70_refs.hmm ./ref_sequences/hsp70_aligned.festa


#Use hmmsearch with an hmm we created and proteome
path_to_outcomes="./outcomes"
mkdir -p "$path_to_outcomes"

for file in ./proteomes/proteome*; do

    base_name=$(echo "$file" | grep -o 'proteome_[0-9][0-9]*')
    
    output_file_mcrA="$path_to_outcomes/${base_name}_mcrA.outcome"
    output_file_hsp70="$path_to_outcomes/${base_name}_hsp70.outcome"
    ~/Private/Biocomputing/tools/hmmsearch ./ref_sequences/mcrA_refs.hmm "$file" > "$output_file_mcrA"
    ~/Private/Biocomputing/tools/hmmsearch ./ref_sequences/hsp70_refs.hmm "$file" > "$output_file_hsp70"

done