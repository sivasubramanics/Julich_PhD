#! /usr/bin/env bash
# title           :getRBH.sh
# description     :This script will process two genes fasta file and find the Reciprocal Blast Hits.
# author          :c.s.sivasubramani@gmail.com
# date            :11042021
# version         :0.1
# usage           :bash getRBH.sh <GenesA.fasta> <GenesB.sh>
# notes           :
# ==============================================================================

### Set Environment for shell
set -e # Abort script at first error, when a command exits with non-zero status
set -u # Forces exit when a variable is undefined
# set -x # xtrace: Set High Verbosity

YELLOW='\033[1;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo_cmd(){
	echo -e ${YELLOW}CMD: $*${NC} 
	eval $*
}

echo_log(){
    text=$*
    size=${#text}
    line=$(printf "%0.s-" $(seq 1 $size))
    echo
    echo -e ${GREEN}$line${NC}
    echo -e ${GREEN}$*${NC}
    echo -e ${GREEN}$line${NC}
    echo
}

echo_error(){
	echo -e ${RED}ERROR: $*${NC} 
}

echo_warning(){
	echo -e ${YELLOW}WARNING: $*${NC} 
}

# Check the availability of blastn
BLASTN_PATH=$(which blastn || echo blastn)
if [ -z "$BLASTN_PATH" ];
then
	echo_error -e "blastn is not found in the system environment PATH. Please add the BLAST PATH under environment PATH variable or install blastn by using the command \"sudo apt install ncbi-blast+\""
	exit
fi

### verify proper arguments are passed
if [ $# -lt 3 ];
  then
    echo_error "No arguments supplied."
    echo_error "Usage: bash getRBH.sh <GenesA.fasta> <GenesB.sh> <output_prefix>"
    exit 1
fi

### Declare vairables
inA=$1
inB=$2
inFaA=${inA%.fasta}
inFaB=${inB%.fasta}
outPrefix=$3
blastOut="${outPrefix}_${inFaA}_vs_${inFaB}.blastout"
reciprocalBlastOut="${outPrefix}_${inFaB}_vs_${inFaA}.blastout"
rbhOutput="${outPrefix}_RBH.out"

### Checking if blastDB are avvailable
if [[ ! -f ${inA}.nhr || ! -f ${inA}.nin || ! -f ${inA}.nsq ]];
then
	echo_log "Creating blastDB for $inA.."
	echo_cmd "makeblastdb -in $inA -dbtype nucl"
fi

if [[ ! -f ${inB}.nhr || ! -f ${inB}.nin || ! -f ${inB}.nsq ]];
then
	echo_log "Creating blastDB for $inB.."
	echo_cmd "makeblastdb -in $inB -dbtype nucl"
fi

### Performing blast
echo_log "Performing blast of DB=$inA QUERY=$inB..."
echo_cmd "blastn -db $inA -query $inB -out ${blastOut} -outfmt 6 -evalue 0.0005"

### Performing reciprocal blast
echo_log "Performing reciprocal blast of DB=$inB QUERY=$inA..."
echo_cmd "blastn -db $inB -query $inA -out ${reciprocalBlastOut} -outfmt 6 -evalue 0.0005"

### Determining RBH between query and subject blast outputs
echo_log "Determining RBH between QUERY=${inB} and DB=${inB}. Output File=${rbhOutput}"
echo -e "${inFaA}\t${inFaB}" > ${rbhOutput}
while IFS=$'\t' read -r col1 col2 col3 col4 col5 col6 col7 col8 col9 col10 col11 col12
do
	if grep -q "$col2"$'\t'"$col1"$'\t' ${blastOut}; then #RBH
		echo -e "$col1\t$col2" >> ${rbhOutput}
	fi
done < ${reciprocalBlastOut}


### Generating summary
noQueryHits=$(wc -l "${blastOut}" | cut -d ' ' -f 1)
noDbHits=$(wc -l "${reciprocalBlastOut}" | cut -d ' ' -f 1)
noRBH=$(($(wc -l "$rbhOutput" | cut -d ' ' -f 1)-1))
echo "Total number of blast hits [ db=${inA} vs query=${inB} ]:${noQueryHits}"
echo "Total number of blast hits [ db=${inB} vs query=${inA} ]:${noDbHits}"
echo "Total number of RBH :${noRBH}"
echo "Output RBH File: ${rbhOutput}"
echo_log "Finished processing RBH! Thank You!!!\ncontact: c.s.sivasubramani@gmail.com"


