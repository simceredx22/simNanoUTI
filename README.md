# simNanoUTI
## methods for pathogens identification
## methods for AMR genes detection
### requirments
**R and R packages**  
R>=3.6.0   
getopt>=1.20.3  
magrittr>=1.5  
data.table>=1.12.2  
**python 3.6.5 and python libraries**  
os,sys.codecs,collections,subprocess,datetime,multiprocessing  
re>=2.2.1  
argparse>=1.1  
json>=2.0.9  
**softwares**  
blastn  
minimap2  
samtools
seqtk
### installation
unzip rmh2amr_0.1.0.zip
install.packages("rmh2amr",repos=NULL)
###  test data
rmhost.403.fasta: sequencing data in fasta format
403.ALIGN.txt: pathogens identification results
### get started
Rscript allscript/amr_determine_3.R \
-f rmhost.403.fasta \
-a 403.ALIGN.txt \
-o outdir \     #output directory
-k seqtk   #path for seqtk
### output  
outdir/allsample.AMR.filter.tsv 
explanation for each column:
ARO_name
Reads
ARO_length 为此ARO的长度
ARO_gene_family 此ARO所属的gene family
Coverage_ratio 对此ARO的覆盖度
AMR_species 对应的物种
Drug_class_list 此ARO对应的耐药的药物
Pass 是否通过过滤，综合以下3种过滤指标，均通过为1
Inlist_or_not 是否在ARO可信列表中，1为通过
Reads_pass reads支持数过滤，大于2条reads支持为通过，数值为1
Coverage_pass 覆盖度过滤，1为通过





