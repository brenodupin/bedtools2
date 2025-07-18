set -e;
# t.fa
# >chr1
# aggggggggg
# cggggggggg
# tggggggggg
# aggggggggg
# cggggggggg

BT=${BT-../../bin/bedtools}

FAILURES=0;

check()
{
    if diff $1 $2; then
        echo ok
    else
        FAILURES=$(expr $FAILURES + 1);
		echo fail
    fi
}

echo -e "    getfasta.t01...\c"
LINES=$(echo $'chr1\t1\t10' | $BT getfasta -fi t.fa -bed stdin | awk 'END{ print NR }')
if [ "$LINES" != "2" ]; then
    FAILURES=$(expr $FAILURES + 1);
		echo fail
else
    echo ok
fi

echo -e "    getfasta.t02...\c"
LEN=$($BT getfasta -split -fi t.fa -bed blocks.bed | awk '(NR == 2){ print length($0) }')
if [ "$LEN" != "22" ]; then #   sizes: 2,10,10 == 22
    FAILURES=$(expr $FAILURES + 1);
		echo fail $LEN
else
    echo ok
fi

echo -e "    getfasta.t03...\c"
SEQ=$($BT getfasta -split -fi t.fa -bed blocks.bed | awk '(NR == 4){ print $0 }')
if [ "$SEQ" != "cta" ]; then
    FAILURES=$(expr $FAILURES + 1);
		echo fail "got $SEQ"
else
    echo ok
fi


# test -fo -
echo -e "    getfasta.t04...\c"
SEQ=$($BT getfasta -split -fi t.fa -bed blocks.bed | awk '(NR == 4){ print $0 }')
if [ "$SEQ" != "cta" ]; then
    FAILURES=$(expr $FAILURES + 1);
		echo fail
else
    echo ok
fi


# test -split with -s -
echo -e "    getfasta.t05...\c"
SEQ=$($BT getfasta -split -s -fi t.fa -bed blocks.bed | awk '(NR == 4){ print $0 }')
if [ "$SEQ" != "tag" ]; then
    FAILURES=$(expr $FAILURES + 1);
		echo fail
else
    echo ok
fi

# test -fullHeader
echo -e "    getfasta.t06...\c"
LINES=$(echo $'chr1\t1\t10' | $BT getfasta -fullHeader -fi t_fH.fa -bed stdin | awk 'END{ print NR }')
if [ "$LINES" != "2" ]; then
    FAILURES=$(expr $FAILURES + 1);
		echo fail
else
    echo ok
fi

# test without -fullHeader
echo -e "    getfasta.t07...\c"
echo "WARNING. chromosome (chr1 assembled by consortium X) was not found in the FASTA file. Skipping." > exp
echo $'chr1 assembled by consortium X\t1\t10' | $BT getfasta -fi t_fH.fa -bed - 2> obs

check obs exp
rm obs exp


# test IUPAC
echo -e "    getfasta.t08...\c"
echo \
">1:0-16
AGCTYRWSKMDVHBXN
>2:0-16
agctyrwskmdvhbxn" > exp
$BT getfasta  -fi test.iupac.fa -bed test.iupac.bed > obs
check obs exp
rm obs exp test.iupac.fa.fai


# test IUPAC revcomp
echo -e "    getfasta.t09...\c"
echo \
">1:0-16(-)
NXVDBHKMSWYRAGCT
>2:0-16(-)
nxvdbhkmswyragct" > exp
$BT getfasta  -fi test.iupac.fa -bed test.iupac.bed -s > obs
check obs exp
rm obs exp test.iupac.fa.fai

# test the warning about an outdated FASTA index file
echo -e "    getfasta.t10...\c"
echo \
">chr1
cggggggggg
>chr2
AAATTTTTTTTTT" > test.fa
# create an index file
echo -e "chr2\t2\t10" | $BT getfasta -fi test.fa -bed - > /dev/null
# modify the FASTA file in a second
sleep 1 
touch test.fa
echo -e "chr2\t2\t10" | $BT getfasta -fi test.fa -bed -  \
	> /dev/null 2> obs
echo "Warning: the index file is older than the FASTA file." > exp
check obs exp
rm obs exp test.fa test.fa.fai


echo -e "    getfasta.t11...\c"
echo ">chr1:0-40
agggggggggcgggggggggtgggggggggaggggggggg
>chr1:0-40
agggggggggcgggggggggtgggggggggaggggggggg" > exp
$BT getfasta -fi t.fa -bed blocks.bed > obs
check obs exp
rm obs exp

echo -e "    getfasta.t12a...\c"
echo ">three_blocks_match::chr1:0-40
agggggggggcgggggggggtgggggggggaggggggggg
>three_blocks_match::chr1:0-40
agggggggggcgggggggggtgggggggggaggggggggg" > exp
$BT getfasta -fi t.fa -bed blocks.bed -name > obs
check obs exp
rm obs exp

echo -e "    getfasta.t12a...\c"
echo ">three_blocks_match::chr1:0-40
agggggggggcgggggggggtgggggggggaggggggggg
>three_blocks_match::chr1:0-40
agggggggggcgggggggggtgggggggggaggggggggg" > exp
$BT getfasta -fi t.fa -bed blocks.bed -name+ > obs
check obs exp
rm obs exp

echo -e "    getfasta.t12b...\c"
echo ">three_blocks_match
agggggggggcgggggggggtgggggggggaggggggggg
>three_blocks_match
agggggggggcgggggggggtgggggggggaggggggggg" > exp
$BT getfasta -fi t.fa -bed blocks.bed -nameOnly > obs
check obs exp
rm obs exp

echo -e "    getfasta.t13a...\c"
echo ">three_blocks_match::chr1:0-40(+)
agggggggggcgggggggggtgggggggggaggggggggg
>three_blocks_match::chr1:0-40(-)
ccccccccctcccccccccacccccccccgccccccccct" > exp
$BT getfasta -fi t.fa -bed blocks.bed -name -s > obs
check obs exp
rm obs exp

echo -e "    getfasta.t13b...\c"
echo ">three_blocks_match::chr1:0-40(+)
agggggggggcgggggggggtgggggggggaggggggggg
>three_blocks_match::chr1:0-40(-)
ccccccccctcccccccccacccccccccgccccccccct" > exp
$BT getfasta -fi t.fa -bed blocks.bed -name+ -s > obs
check obs exp
rm obs exp

echo -e "    getfasta.t13c...\c"
echo ">three_blocks_match(+)
agggggggggcgggggggggtgggggggggaggggggggg
>three_blocks_match(-)
ccccccccctcccccccccacccccccccgccccccccct" > exp
$BT getfasta -fi t.fa -bed blocks.bed -nameOnly -s > obs
check obs exp
rm obs exp


echo -e "    getfasta.t14...\c"
echo ">three_blocks_match::chr1:0-40
agggggggggcgggggggggtgggggggggaggggggggg
>three_blocks_match::chr1:0-40
agggggggggcgggggggggtgggggggggaggggggggg" > exp
$BT getfasta -fi t.fa -bed blocks.bed -name+ > obs
check obs exp
rm obs exp

echo -e "    getfasta.t15...\c"
echo ">three_blocks_match::chr1:0-40(+)
agggggggggcgggggggggtgggggggggaggggggggg
>three_blocks_match::chr1:0-40(-)
ccccccccctcccccccccacccccccccgccccccccct" > exp
$BT getfasta -fi t.fa -bed blocks.bed -name+ -s > obs
check obs exp
rm obs exp

echo -e "    getfasta.t134..\c"
echo ">chr1:0-1
a" > exp
$BT getfasta -fi t.fa -bed <(echo -e "chr1\t0\t1") > obs
check obs exp
rm obs exp
[[ $FAILURES -eq 0 ]] || exit 1;

echo -e "    getfasta.t16..\c"
echo ">candidate_1::chr1:0-10(-)
catcggtcaa
>candidate_2::chr1:0-10(+)
uugaccgaug" > exp
$BT getfasta -fi rna.fasta -bed rna.bed -s -name > obs
check obs exp
rm obs exp

echo -e "    getfasta.t17..\c"
echo ">candidate_1::chr1:0-10(-)
caucggucaa
>candidate_2::chr1:0-10(+)
uugaccgaug" > exp
$BT getfasta -fi rna.fasta -bed rna.bed -s -name -rna > obs
check obs exp
rm obs exp


echo -e "    getfasta.t18...\c"
SEQ=$($BT getfasta -split -fi t.fa.gz -bed blocks.bed | awk '(NR == 4){ print $0 }')
if [ "$SEQ" != "cta" ]; then
    FAILURES=$(expr $FAILURES + 1);
        echo fail
else
    echo ok
fi

###################################################################
# Circular genome tests
###################################################################

echo -e "    getfasta.t19...\c"
echo ">plasmid1:89-110
CGTACGTACGTACGTACGTAC" > exp
echo $'plasmid1\t89\t110' | $BT getfasta -circular -fi plasmid.fasta -bed - > obs
check obs exp
rm obs exp

echo -e "    getfasta.t20...\c"
echo ">plasmid2:90-110
CCAAAATTTTGGGGTTTTGG" > exp
echo -e "plasmid2\t90\t110" | $BT getfasta -fi plasmid.fasta -bed stdin -circular > obs
check obs exp
rm obs exp

echo -e "    getfasta.t21...\c"
echo ">plasmid3:80-120
AAAACCCCGGGGTTTTAAAACCCCAAAACCCCGGGGTTTT" > exp
echo -e "plasmid3\t80\t120" | $BT getfasta -fi plasmid.fasta -bed stdin -circular > obs
check obs exp
rm obs exp

echo -e "    getfasta.t22...\c"
echo ">plasmid4:15-25
GATCGATCGA" > exp
echo -e "plasmid4\t15\t25" | $BT getfasta -fi plasmid.fasta -bed stdin -circular > obs
check obs exp
rm obs exp

echo -e "    getfasta.t23...\c"
echo ">plasmid5:35-45
AGCTAGCGCT" > exp
echo -e "plasmid5\t35\t45" | $BT getfasta -fi plasmid.fasta -bed stdin -circular > obs
check obs exp
rm obs exp

echo -e "    getfasta.t24...\c"
echo "plasmid1:90-110	GTACGTACGTACGTACGTAC" > exp
echo -e "plasmid1\t90\t110" | $BT getfasta -fi plasmid.fasta -bed stdin -circular -tab > obs
check obs exp
rm obs exp

echo -e "    getfasta.t25...\c"
echo ">wrap_basic::plasmid1:90-110
GTACGTACGTACGTACGTAC" > exp
echo -e "plasmid1\t90\t110\twrap_basic" | $BT getfasta -fi plasmid.fasta -bed stdin -circular -name > obs
check obs exp
rm obs exp

echo -e "    getfasta.t26...\c"
echo "plasmid1	90	110	wrap_basic	GTACGTACGTACGTACGTAC" > exp
echo -e "plasmid1\t90\t110\twrap_basic" | $BT getfasta -fi plasmid.fasta -bed stdin -circular -bedOut > obs
check obs exp
rm obs exp

echo -e "    getfasta.t27...\c"
echo ">plasmid1:89-110
CGTACGTACGTACGTACGTAC
>plasmid1:104-115
ACGTACGTACG
>plasmid1:99-105
TACGTA
>plasmid1:89-100
CGTACGTACGT" > exp
$BT getfasta -fi plasmid.fasta -bed gff_test.gff3 -circular > obs
check obs exp
rm obs exp

echo -e "    getfasta.t28...\c"
LINES=$(echo -e "plasmid1\t0\t150" | $BT getfasta -fi plasmid.fasta -bed stdin -circular 2>&1 | grep -c "beyond the length")
if [ "$LINES" != "1" ]; then
    FAILURES=$(expr $FAILURES + 1);
    echo fail
else
    echo ok
fi

echo -e "    getfasta.t29...\c"
LINES=$(echo -e "plasmid7\t20\t20" | $BT getfasta -fi plasmid.fasta -bed stdin -circular 2>&1 | grep -c "length = 0")
if [ "$LINES" != "1" ]; then
    FAILURES=$(expr $FAILURES + 1);
    echo fail
else
    echo ok
fi

echo -e "    getfasta.t30...\c"
LINES=$(echo -e "nonexistent\t10\t20" | $BT getfasta -fi plasmid.fasta -bed stdin -circular 2>&1 | grep -c "was not found")
if [ "$LINES" != "1" ]; then
    FAILURES=$(expr $FAILURES + 1);
    echo fail
else
    echo ok
fi

echo -e "    getfasta.t31...\c"
CIRC_LINES=$(echo -e "plasmid1\t90\t110" | $BT getfasta -fi plasmid.fasta -bed stdin -circular 2>/dev/null | wc -l)
NORM_LINES=$(echo -e "plasmid1\t90\t110" | $BT getfasta -fi plasmid.fasta -bed stdin 2>/dev/null | wc -l)
if [ "$CIRC_LINES" -gt "$NORM_LINES" ]; then
    echo ok
else
    FAILURES=$(expr $FAILURES + 1);
    echo fail
fi

[[ $FAILURES -eq 0 ]] || exit 1;
