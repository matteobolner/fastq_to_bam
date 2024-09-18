import os
import sys
import pandas as pd

def get_fastq_pairs(base_dir):
    data = []

    # Iterate through each sample folder in the base directory
    for sample in os.listdir(base_dir):
        sample_path = os.path.join(base_dir, sample)
        if os.path.isdir(sample_path):
            # Get all fastq files in the current sample folder
            fastq_files = [f for f in os.listdir(sample_path) if f.endswith('.fq') or f.endswith('.fq.gz')]
            # Sort fastq files to ensure fq1 and fq2 pairing
            fastq_files.sort()
            # Process fastq files in pairs (assuming fq1 is R1 and fq2 is R2)
            for i in range(0, len(fastq_files), 2):
                fq1 = fastq_files[i]
                fq2 = fastq_files[i+1] if i+1 < len(fastq_files) else None
                if fq2 and '_1.fq' in fq1 and '_2.fq' in fq2:
                    fq1_abs = os.path.abspath(os.path.join(sample_path, fq1))
                    fq2_abs = os.path.abspath(os.path.join(sample_path, fq2))

                    unit = os.path.splitext(fq1)[0].rstrip("_1.fq")
                    data.append([sample, unit, fq1_abs, fq2_abs])

    # Create a DataFrame for output
    df = pd.DataFrame(data, columns=['sample', 'unit', 'fq1', 'fq2'])
    return df

def main():
    input_dir = sys.argv[1]
    output_file = sys.argv[2]

    fastq_df = get_fastq_pairs(input_dir)

    # Save to the specified output file
    fastq_df.to_csv(output_file, sep='\t', index=False)

if __name__ == "__main__":
    main()

