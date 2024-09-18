rule bwa_mem2_mem:
    input:
        reads=get_all_fastqs_per_unit,
        idx=f"{config['ref_genome']}.0123",
    output:
        temp(f"{config['bam_folder']}/{{sample}}-{{unit}}.bam"),
    log:
        "logs/bwa_mem2/{sample}_{unit}.log",
    params:
        extra=r"-R '@RG\tID:{sample}\tSM:{sample}\tPL:unknown\tLB:{sample}'",
        sort="samtools",  # Can be 'none', 'samtools', or 'picard'.
        sort_order="coordinate",  # Can be 'coordinate' (default) or 'queryname'.
        sort_extra="",  # Extra args for samtools/picard sorts.
    threads: 5
    wrapper:
        "v3.14.1/bio/bwa-mem2/mem"

rule samtools_merge:
    input:
        get_sample_bams,
    output:
        f"{config['bam_folder']}/{{sample}}.bam",
    log:
        "logs/samtools_merge/{sample}.log",
    params:
        extra="",  # optional additional parameters as string
    threads: 5
    wrapper:
        "v3.14.1/bio/samtools/merge"


rule samtools_index:
    input:
        f"{config['bam_folder']}/{{sample}}.bam",
    output:
        f"{config['bam_folder']}/{{sample}}.bam.bai",
    log:
        "logs/samtools_index/{sample}.log",
    params:
        extra="",  # optional params string
    threads: 1
    priority: 1
    wrapper:
        "v3.14.1/bio/samtools/index"

rule send_mail:
    input:
        log=f"{config['bam_folder']}/{{sample}}.bam.bai",
    output:
        log="logs/mail_confirmations/{sample}.log",
    params:
        mail_address=config["mail_address"],
    shell:
        " echo {input.log} | mail -s '{wildcards.sample} finished mapping' {params.mail_address} && echo 'DONE' > {output.log}"
