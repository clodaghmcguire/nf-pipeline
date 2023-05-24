nextflow.enable.dsl=2

process FASTQC {
   input:
   path fastq
   
   script:
   """
   mkdir fastqc_out
   /usr/local/pipeline/FastQC/fastqc -o fastqc_out $fastq
   """
}

process trim {
    input: 
    path fastq
    path adapters
    
    script:
    """
    /usr/bin/java -XX:ParallelGCThreads=4 -Xmx4g -jar /usr/local/pipeline/Trimmomatic-0.32/trimmomatic-0.32.jar PE -trimlog /dev/stdout -threads 4 $fastq L19-00353_1.filtered.fastq.gz L19-00353_1.filtered.unpaired.fastq.gz L19-00353_2.filtered.fastq.gz L19-00353_2.filtered.unpaired.fastq.gz ILLUMINACLIP:$adapters:2:30:10:1:true SLIDINGWINDOW:4:15 LEADING:3 TRAILING:3 MINLEN:36
    """
}

params.fastq = files( '*.fastq.gz' )
adapters_ch = Channel.fromPath( 'adapters/SureSelectQXT.fa')


workflow {
  FASTQC(params.fastq) 
  trim(params.fastq, adapters_ch)
}