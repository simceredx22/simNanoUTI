#!/bin/bash
usage="\nUsage:\n\tsamtools_tview.sh <query.fa> <ref.fa> <tviewaln>\n"


#if [ -n str1 ]　　　　　　 当串的长度大于0时为真(串非空) 
#if [ -z str1 ]　　　　　　　 当串的长度为0时为真(空串) zero

if [ -z "$1" ]; then  
	echo -e $usage 1>&2; exit 1;
elif [[ $1 =~ ^- ]]; then 
	echo -e $usage 1>&2; exit 1;
else 
	query=$1;
	prefix1=$(basename ${query%.*});
fi;

if [ -z "$2" ]; then 
	echo -e $usage 1>&2; exit 1; 
elif [[ $2 =~ ^- ]]; then 
	echo -e $usage 1>&2; exit 1;
else 
	ref=$2;
	prefix2=$(basename ${ref%.*});
fi;

if [ -z "$3" ]; then 
	echo -e $usage 1>&2; exit 1; 
else 
	tviewaln=$3;
	tview=`echo $tviewaln|awk '{gsub(".aln$",".tview",$0);print $0}'`;
	outdir=$(dirname $tviewaln);
fi;


if [ ! -f $outdir/align ];then mkdir -p $outdir/align;fi;
minimap2 -ax map-ont $ref $query > $outdir/align/$prefix1.$prefix2.sam;
if [ ! -f "$ref.fai" ]; then samtools faidx $ref;fi;
samtools view -b -S -t $ref.fai $outdir/align/$prefix1.$prefix2.sam > $outdir/align/$prefix1.$prefix2.bam;
samtools sort -T $outdir/tmp -o $outdir/align/$prefix1.$prefix2.sorted.bam $outdir/align/$prefix1.$prefix2.bam;
samtools index $outdir/align/$prefix1.$prefix2.sorted.bam;

export COLUMNS=32768;
samtools tview -d T $outdir/align/$prefix1.$prefix2.sorted.bam $ref > $tview;
samtools view $outdir/align/$prefix1.$prefix2.sorted.bam| \
	awk 'NR==FNR{if(NR==2){split($0,ee,"");for(i=1; ee[i]!="N"; i++);a[NR-1]=substr($0,1,i-1)}
					if(NR>3){a[NR-2]=substr($0,1,i-1)}}
			NR>FNR{if(FNR==1){print $3"\t"a[FNR]"\n"$1"\t"a[FNR+1]}
					else{print $1"\t"a[FNR+1]}}' $tview - > $tviewaln;
