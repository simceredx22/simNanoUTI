infa=/gpfsdata/users/daiyan/database/08.functional_genes/01.card/card_20210423/nucleotide_fasta_protein_homolog_model.fasta;
otpx=/gpfsdata/users/daiyan/projects/11.blood_culture/00.scripts/amr_3/amr_gene_info/card_PHM_0.95;
## version 4.8.1
## cd-hit-est=/gpfsdata/apps/bin/cd-hit-est
## version 1219
## lastal=/gpfsdata/users/daiyan/software/bin/lastal

## cluster
cd-hit-est -i ${infa} \
	-o ${otpx} \
	-c 0.95 -n 10 -d 0 -M 16000 -T 8 -g 0

## ref & var table
awk '{if($1~/^>/){if(count>2){print mem;};mem=$0;count=1;}else{mem=mem"\n"$0;count+=1;}}' ${otpx}.clstr > ${otpx}.multi;
awk -F "\t" '{if($1~/^>/){if(NR>1){gsub("\n","\n"clst"\t"ref"\t",mem);print mem;};gsub("^>","",$1);clst=$0;mem=NULL;}
else{if($0~/\*$/){ref=$2;}else{mem=mem"\n"$2;}}}' ${otpx}.multi| \
     awk 'BEGIN{OFS=FS="\t"}
     function get_len(field){
     split(field,a," ");gsub(",","",a[1]);return(a[1])
     };
     function get_seqid(field){
     split(field,a," ");gsub("\\.\\.\\.","",a[2]);return(a[2])
     };
     function get_aro(field){
     split(field,a," ");split(a[2],b,"|");return(b[5])
     };
     {if(NF>0){print $1,get_seqid($2),get_aro($2),get_len($2),get_seqid($3),get_aro($3),get_len($3);}}' > ${otpx}.tsv0;

## extract fasta of ref & var
rm -rf ${otpx}_variants/*;
aro2="";
cat ${otpx}.tsv0|while read -r i;do \
	aro1=`echo "$i"|awk -F "\t" '{gsub(":","_",$3);print $3;}'`;
	ot=${otpx}_variants/${aro1};
	ot1=${otpx}_variants/${aro1}/${aro1}.fasta;
	ot2=${otpx}_variants/${aro1}/${aro1}_variants.fasta;
	if [[ $aro2 = $aro1 ]];then
		echo "$i"|awk -F "\t" '{gsub("^>","",$5);print $5}'|seqtk subseq ${infa} - >> ${ot2};
	else
		mkdir -p ${ot};
		echo "$i"|awk -F "\t" '{gsub("^>","",$2);print $2}'|seqtk subseq ${infa} - > ${ot1};
		echo "$i"|awk -F "\t" '{gsub("^>","",$5);print $5}'|seqtk subseq ${infa} - > ${ot2};
		aro2=$aro1;
	fi
done

## minimap2  and samtools to get variant list
for i in `ls -d ${otpx}_variants/*`;do
	j=`basename ${i}`;
	qryfa=${i}/${j}_variants.fasta;
	reffa=${i}/${j}.fasta;
	tviewaln=${i}/${j}.aln;
	ottmp=${i}/${j}.var.tmp;
	otvar=${i}/${j}.family.sites.tsv;
	
	/gpfsdata/users/daiyan/projects/11.blood_culture/00.scripts/amr_3/samtools_tview_3.sh $qryfa $reffa $tviewaln;

	awk 'BEGIN{OFS=FS="\t";base="";}{
		if(NR==1){lena=split(toupper($2),aa,"");ref=$1;print "ref","qry","ori","alt","pos";}
		else{split(toupper($2),bb,"");qry=$1;pos=0;
			for(i=1;i<=lena;i++){
				if(aa[i]~/[ATCG]/){
					pos=pos+1;
			        base=aa[i];
					if(bb[i]~/\.|,/){
						alt=aa[i];
		            }else if(bb[i]~/\*/){
						alt="/";
					}else if(bb[i]~/ /){
						alt="-";
					}else if(bb[i]~/[ATCG]/){
						alt=bb[i];
					}
				}
				if(aa[i]~/\*/){
					pos=pos;
	                base=base;
		            if(bb[i]~/[ATCG]/){
	                    alt=(alt)(bb[i]);
		            }else if(bb[i]~/ |\*/){
			            alt=alt;
				    }
	            };
		        if(alt!=base){print ref,qry,base,alt,pos;}
			}
	    }}' $tviewaln	>	$ottmp;


	awk 'BEGIN{OFS=FS="\t"}{
	    if(NR==1){mem="SeqID\tPos\tRef\tAlt\tGenes\tGeneLen";qp="";}
		else{if($2":"$5!=qp){print mem;qp=$2":"$5;}
			split($1,aa,"|");gsub(":","_",aa[5]);
	        split($2,bb,"|");gsub(":","_",bb[5]);split(bb[4],cc,"-");
		    mem=aa[5]"\t"$5"\t"$3"\t"$4"\t"bb[5]"\t"sqrt((cc[2]-cc[1])*(cc[2]-cc[1]));
	    }}END{print mem}' $ottmp	>	$otvar;
		
done


awk -v dir=${otpx}_variants 'BEGIN{OFS=FS="\t"}{gsub(":","_",$3);gsub(":","_",$6);
if(NR==1){print "ARO_REF\tARO_QRY\tARO_REF_FA\tARO_VAR_TXT\n"$3,$6,dir"/"$3"/"$3".fasta",dir"/"$3"/"$3".family.sites.tsv";}else{print $3,$6,dir"/"$3"/"$3".fasta",dir"/"$3"/"$3".family.sites.tsv"}}' ${otpx}.tsv0 > ${otpx}.R
