# downloadSRA
A collection of scripts to obtain metadata and download fastq.gz files for SRA accessions


This is a collection of scripts to download SRA fastq files to the GACRC compute systems at UGA.

This series of scripts will allow you to download metadata for accessions using ffq (https://github.com/pachterlab/ffq) and then use the retrieved url to download .fastq.gz files. r. 
Step 1 - Create a working directory
a. Create a folder in your scratch directory with an informative filename
b. Clone the 'downloadSRA' repository to a folder within your scratch director

Step 2 - create a file containing a list of accessions to download from the database. The file should contain 1 accession # per line, with no other information. Be sure to use LF line endings.

ex.
SRR5177530
SRR5177529
SRR5177528
SRR5177527

Step 3 - Use ffq.sh to download accession metadata including ftp urls. This step should be run on the batch partition on the Sapelo2 cluste
a. open the ffq script and replace the end of the last line 'Path/To/YourAccessionFile.txt' with the actual file path to your text file containing accession numbers.

b. submit to the queue using: sbatch GetMetadataWith_ffq.sh


Step 4 - Download the reads for each accession. This should be using the transfer node, xfer.gacrc.uga.edu
a. log in to xfer
b. Run the script entitled 'GetFastqFiles.sh' and include the path to your accession number file after the script call. It is good to run this using nohup so that the downloads will continue if your need to end your session.

eg. 

nohup sh GetFastqFiles.sh Path/To/YourAccessionFile.txt

***note. if the script does not run. You may need to change the file permissions by running: 
    chmod 755 GetFastqFiles.sh
    






