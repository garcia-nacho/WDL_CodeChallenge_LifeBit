version 1.0
workflow RunVep {
    input{
        File InputVcf
    }

    call scatter_vep {
        input: 
            FullVcf=InputVcf,
    }

    scatter (file in scatter_vep.output_scat) {
    call run_vep {
        input: 
            CombineVcf=file
    }

    }

    call gather_vep{
    input:
        VEPfiles=run_vep.vepvcf
    }
}

task scatter_vep {
    input{
        File FullVcf
    }
    command {
        Rscript --vanilla /home/docker/Scripts/SplitterWDL.R ${FullVcf} 
    }
        
    runtime {
        docker: "garcianacho/lb_base"
     }
    output {
        Array[File]+ output_scat = glob("*.vcf")
    }
}

task run_vep {
    input{
        File CombineVcf
        String name = basename(CombineVcf , ".vcf") 
    }
    
    command {
        
        vep -i ${CombineVcf} -o ${name}.vep.txt --vcf --plugin Blosum62 --plugin CSN --plugin Downstream --plugin HGVSIntronOffset --plugin LOVD --plugin NearestExonJB --plugin ReferenceQuality --plugin SpliceRegion --plugin TSSDistance --plugin FlagLRG,/opt/vep/CommonFiles/list_LRGs_transcripts_xrefs.txt --database
    }
    runtime {
        docker: "garcianacho/lb_vep_full"
     }
    output {
        File vepvcf = "${name}.vep.txt"
    }
}

task gather_vep {
    input{
        Array[File] VEPfiles
    }
    
    command {
        Rscript /home/docker/Scripts/MergerWDL.R && cat /home/docker/Scripts/vcfheader Results_nohead.vcf > Results.vcf && ls -lrt > outls.txt
    }
    runtime {
        docker: "garcianacho/lb_base"
    }
    output {
    File finaloutput = "Results.vcf"
    }
}
