"""
rule bwa_index_ref:
    input:
        genome=config["ref_genome"],
    output:
        idx=multiext(
            config["ref_genome"],
            ".0123",
            ".amb",
            ".ann",
            ".bwt.2bit.64",
            ".pac",
        ),
    resources:
        mem_mb=25000,
    threads: 8
    log:
        "logs/bwa-mem2_index/indexing.log",
    shell:
        "bwa-mem2 index {input.genome} > {log}"
"""

rule bwa_mem2_index:
    input:
        expand("{genome}", genome=config["ref_genome"]),
    output:
        "{genome}.0123",
        "{genome}.amb",
        "{genome}.ann",
        "{genome}.bwt.2bit.64",
        "{genome}.pac",
    resources:
        mem_mb=25000,
    threads: 8
    log:
        "logs/bwa-mem2_index/indexing.log",
    wrapper:
        "v5.2.1/bio/bwa-mem2/index"
