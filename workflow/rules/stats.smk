rule samtools_stats:
    input:
        bam=bam_folder_path("{sample}{raw_or_rmdup}.bam"),
    output:
        "stats/samtools_flagstat/{sample}{raw_or_rmdup}.flagstat",
    log:
        "logs/samtools_flagstat/{sample}{raw_or_rmdup}.log",
    wrapper:
        "v5.2.1/bio/samtools/flagstat"


rule multiqc_samtools_flagstat:
    input:
        expand(
            "stats/samtools_flagstat/{sample}{{raw_or_rmdup}}.flagstat",
            sample=samples.index,
        ),
    output:
        "reports/multiqc/samtools/flagstat{raw_or_rmdup}/report.html",
        directory("reports/multiqc/samtools/flagstat{raw_or_rmdup}/report_data"),
    params:
        extra="--verbose",
    log:
        "logs/multiqc/markduplicates{raw_or_rmdup}.log",
    wrapper:
        "v5.2.1/bio/multiqc"


rule multiqc_markduplicates:
    input:
        expand(bam_folder_path("{sample}.metrics.txt"), sample=samples.index),
    output:
        "reports/multiqc/markduplicates/report.html",
        directory("reports/multiqc/markduplicates/report_data"),
    params:
        extra="--verbose",
    log:
        "logs/multiqc/markduplicates.log",
    wrapper:
        "v5.2.1/bio/multiqc"


rule mosdepth:
    input:
        bam=bam_folder_path("{sample}.rmdup.bam"),
        bai=bam_folder_path("{sample}.rmdup.bam.bai"),
    output:
        "stats/mosdepth/{sample}.mosdepth.global.dist.txt",
        summary="stats/mosdepth/{sample}.mosdepth.summary.txt",  # this named output is required for prefix parsing
        #"stats/mosdepth/{sample}.per-base.bed.gz",  # produced unless --no-per-base specified
    log:
        "logs/mosdepth/{sample}.log",
    params:
        extra="--fast-mode --no-per-base",  # optional
    # additional decompression threads through `--threads`
    threads: 4  # This value - 1 will be sent to `--threads`
    wrapper:
        "v5.2.1/bio/mosdepth"


rule multiqc_mosdepth:
    input:
        expand("stats/mosdepth/{sample}.mosdepth.global.dist.txt", sample=samples.index),
    output:
        "reports/multiqc/mosdepth/report.html",
        directory("reports/multiqc/mosdepth/report_data"),
    params:
        extra="--verbose",
    log:
        "logs/multiqc/mosdepth.log",
    wrapper:
        "v5.2.1/bio/multiqc"
