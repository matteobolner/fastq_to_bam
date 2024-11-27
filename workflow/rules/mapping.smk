rule bwa_mem2_mem:
    input:
        reads=get_all_fastqs_per_unit,
        idx=rules.bwa_mem2_index.output,
    output:
        temp(bam_folder_path("{sample}-{unit}.bam")),
    log:
        "logs/bwa_mem2/{sample}_{unit}.log",
    params:
        extra=r"-R '@RG\tID:{sample}\tSM:{sample}\tPL:unknown\tLB:{sample}'",
        sort="samtools",  # Can be 'none', 'samtools', or 'picard'.
        sort_order="coordinate",  # Can be 'coordinate' (default) or 'queryname'.
        sort_extra="",  # Extra args for samtools/picard sorts.
    threads: 5
    wrapper:
        "v5.2.1/bio/bwa-mem2/mem"


rule samtools_merge:
    input:
        get_all_sample_bams,
    output:
        temp(bam_folder_path("{sample}.bam")),
    log:
        "logs/samtools_merge/{sample}.log",
    params:
        extra="",  # optional additional parameters as string
    threads: 5
    wrapper:
        "v5.2.1/bio/samtools/merge"


rule mark_duplicates_spark:
    input:
        bam_folder_path("{sample}.bam"),
    output:
        bam=bam_folder_path("{sample}.rmdup.bam"),
        metrics=bam_folder_path("{sample}.metrics.txt"),
    log:
        "logs/markduplicates/{sample}.log",
    params:
        extra="--remove-all-duplicates",  # optional
        java_opts="",  # optional
        #spark_runner="",  # optional, local by default
        #spark_v5.2.1="",  # optional
        #spark_extra="", # optional
    resources:
        # Memory needs to be at least 471859200 for Spark, so 589824000 when
        # accounting for default JVM overhead of 20%. We round round to 650M.
        mem_mb=lambda wildcards, input: max([input.size_mb * 0.25, 650]),
    threads: 10
    wrapper:
        "v5.2.1/bio/gatk/markduplicatesspark"


rule samtools_index:
    input:
        bam_folder_path("{sample}.rmdup.bam"),
    output:
        bam_folder_path("{sample}.rmdup.bam.bai"),
    log:
        "logs/samtools_index/{sample}.log",
    params:
        extra="",  # optional params string
    threads: 1
    priority: 1
    wrapper:
        "v5.2.1/bio/samtools/index"




rule send_mail:
    input:
        log=bam_folder_path("{sample}.bam.bai"),
    output:
        log="logs/mail_confirmations/{sample}.log",
    params:
        mail_address=config["mail_address"],
    shell:
        " echo {input.log} | mail -s '{wildcards.sample} finished mapping' {params.mail_address} && echo 'DONE' > {output.log}"
