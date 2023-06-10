# Code-challenge-wdl-vep-annotation

## Info
The pipeline uses two docker containers:   
<code>garcianacho/lb_base</code>   
<code>garcianacho/lb_vep_full</code>   
These containers contain all dependencies and scripts necesary to run the pipeline.  
The <code>Dockerfile</code> for the containers is stored in the DockerBASE and DockerVEP respectively.
Note that to prepare the final <code>lb_vep</code> container the container produced by the Dockerfile (i.e. <code>garcianacho/lb_vep</code>) was edited by running the following command:   
<code>/opt/vep/src/ensembl-vep/INSTALL.pl --AUTO ap --ASSEMBLY GRCh38 --CACHEDIR /opt/vep/CommonFiles --PLUGINS all</code>   
The edited container was then committed and sent to *Dockerhub* as <code>garcianacho/lb_vep_full</code> 
The container garcianacho/lb_base uses a different scatter script to deal with the way WDL parses the paths to the R script.  
   
## Run
To run the pipeline you must clone this repo 

<code>git clone garcia-nacho code-challenge-nextflow-wdl-annotation</code>

and run the following command inside the *code-challenge-nextflow-wdl-annotation* folder

You must have <code>miniwdl</code> installed on your system, you can get it via <code>pip install miniwdl</code>.  

<code> miniwdl run ./lb_challenge.wdl InputVcf=./VCFsubset.vcf </code>

Interestingly, the same code doesn't work when using cromwell (v.85). The input files for the last process are located inside subfolders and the R script can't find them. This behaviour is different from miniwdl where all the files are located together inside the same folder, which is what the R script expects (Miniwdl's behaviour is the same as in NextFlow).
  
## Input
As input I have subsampled a vcf file from the 1000 genomes project: 1000Genomes/trio/HG00702_SH089_CHS. To speed up the process of testing I have just gathered a few variants from each chromosome as required. 
   
## Under the hood   
The command runs a script that splits the vcf file used as input in several parts. Given the size of the vcf used as input the size is just 10 variants per file, but this can be easily adjusted.
Next all the chunks are sent to the vep command. Vep runs the following plugins:
   
BLOSUM62   
CSN   
DownstreamProtein   
ProteinLengthChange   
HGVS_IntronEndOffset   
HGVS_IntronStartOffset   
LOVD   
NearestExonJB   
ReferenceQuality   
SpliceRegion   
TSSDistance   
FlagLRG   
   
On the last step, the pipeline gathers all results and generate an unique vcf file inside the Results folder that is generated by the pipeline 
