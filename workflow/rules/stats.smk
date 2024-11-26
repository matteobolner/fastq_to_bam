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