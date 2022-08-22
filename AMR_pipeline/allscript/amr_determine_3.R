suppressMessages(library(getopt));
suppressMessages(library(magrittr));
suppressMessages(library(data.table));
library("rmh2amr");
options(scipen=1000);options(warn=-1);


if(sys.nframe()==0){
    spec    <-  matrix(c(
                    "infa"    , "f", 1, "character", "<path> where input fasta",
                    "otdir"    , "o", 1, "character", "<path> this dir is to be the result dir",
                    "algn"  , "a", 1, "character", "[path] where ALIGN.txt in",
                    "thread"   , "T", 1, "integer"  , "[integer] thread set [16]",
					"S_extractFq"  , "k", 1, "character", "<path> where seqtk",
                    "help"     , "h", 0, "logical"  , "help message"
                    ), byrow = TRUE, ncol = 5); 

    opt     <-  getopt(spec,opt = commandArgs(T));
    script  <-  normalizePath(get_Rscript_filename());

    ## help message 
    if((!is.null(opt$help))|length(opt)==1){
        help_message    <-  gsub("\\[.*-help\\|h\\]\\]","<options> <argument> [...]",
                                 getopt(spec, usage=TRUE, command = normalizePath(get_Rscript_filename())));
        help_message    <-  gsub("^Usage: ","\nUsage:\t  Rscript ", help_message);
        cat(help_message);
        cat("\nExample:  Rscript ",script, " \\\n    -f rmhost.fa",
            " \\\n    -a algn.txt"," \\\n    -o AMR_outdir",
            " \\\n    -S_extractFq path \n", sep = "");
        q(status=1)
    }   
    SUBDIR  <-  normalizePath(file.path(dirname(script)));

	## parse arguments
    if(is.null(opt$infa))      {cat("\n[ERROR] Fa is to be provided!");q(status=1);}
	if(is.null(opt$algn))      {cat("\n[ERROR] algn is to be provided!");q(status=1);}
    if(is.null(opt$otdir))      {cat("\n[ERROR] Otdir is to be provided!");q(status=1);}
    if(is.null(opt$thread))     {opt$thread   <- 16    };  	

    infa           <-  opt$infa;
    otdir           <-  normalizePath(opt$otdir);
    thread          <-  as.integer(opt$thread);
	algnrds			<-	opt$algn
	
	S_extractFq <-	opt$S_extractFq
	S_ABR_PROG          <-  file.path(SUBDIR, "amr_3/caramal/AMR_Profiling.py");
	S_TVIEW_PROG        <-  file.path(SUBDIR, "amr_3/samtools_tview_3.sh");
	
	AMR_INFO_dir            <-  file.path(SUBDIR, "amr_3/amr_gene_info");
	S_ARO_CREDIBLE      <-  file.path(AMR_INFO_dir, "aro_credible.tsv");
	AMR_INFO            <-  fread(file.path(AMR_INFO_dir,"card_PHM_0.95.R"),sep="\t");
	AMR_INFO[,`:=`(ARO_REF_FA=file.path(AMR_INFO_dir,"card_PHM_0.95_variants",ARO_REF,paste(ARO_REF,"fasta",sep="."))),]
	AMR_INFO[,`:=`(ARO_VAR_TXT=file.path(AMR_INFO_dir,"card_PHM_0.95_variants",ARO_REF,paste(ARO_REF,"family.sites.tsv",sep="."))),]
	#print(head(AMR_INFO))
	
	D_ABR_ANNOTATION    <-  file.path(SUBDIR, "amr_3/database/card.json");
	AMR_INFO_2          <-  fread(file.path(SUBDIR, "amr_3/database/aro_taxonomy.tsv"), sep="\t")

    if(!file.exists(otdir)){dir.create(otdir, recursive=T);}
	print("start step_rmh2amr")
	
	step_rmh2amr_all(algnrds,infa,otdir,thread)
}
			
