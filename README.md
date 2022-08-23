# simNanoUTI
## methods for pathogens identification
### requirments
**R and R packages**  
R>=3.6.0   
data.table>=1.14.2   
dplyr>=1.0.9 
### installation
install.packages(PATH_to_zip_file, repos = NULL, type = "win.binary")
### test data  
data("demoblast")  
### usage
getabc(  
  alignfile,  
  outdir = ".",  
  cutoff_by_ratio_of_topbit = 0.95,  
  pathogens = NULL,  
  alter_ratio_cutoff = 0.18,  
  abundance_cutoff = 0.001,  
  readcount_cutoff = 200  
)  
**Arguments**  
alignfile: MegaBLAST output file which should match 12 column tabular format: qseqid, qlen, qstart, qend, saccver, slen, sstart, send, bitscore, length, pident, staxid, ssciname, sskingdom.It can be file name in working directory or a data table.  

outdir: The output directory of filtered blast result.  

cutoff_by_ratio_of_topbit: Return the top hits per query with a bitscore threshold of 95% of highest bitscore value.

pathogens: If given, filtered abundance output only include the results of species in the pathogens list.

alter_ratio_cutoff: Fraction of reads of a species that map to related taxa with the same family or genus，higher than the cutoff will be filtered.

abundance_cutoff: Cutoff value of abundance.

readcount_cutoff: Cutoff value of readcount.

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
install.packages(PATH_to_zip_file, repos = NULL, type = "win.binary")
###  test data  
rmhost.403.fasta: sequencing data in fasta format  
403.ALIGN.txt: pathogens identification results  
### usage
Rscript allscript/amr_determine_3.R \
-f rmhost.403.fasta \
-a 403.ALIGN.txt \
-o outdir \     #output directory
-k seqtk   #path for seqtk
### output  
**outdir/allsample.AMR.filter.tsv**   
explanation for each column:  
ARO_name: ARO(Antibiotic Resistance Ontology) name  
Reads: Number of Reads mapped to the ARO  
ARO_length: length of the ARO  
ARO_gene_family: Gene family of the ARO  
Coverage_ratio: Coverage of the ARO, Covered length/total length of the ARO  
AMR_species: species information of the sample  
Drug_class_list: Related drug class  
Pass: Pass or not, results of integrating Inlist_or_not, Reads_pass and coverage pass  
Inlist_or_not: if the ARO is in the credible ARO list  
Reads_pass: if the number of reads is above the thresholds   
Coverage_pass: if the coverage is above the thresholds  




