Script to proccess and plot results of slurm profiling output file (.h5), produces the following:

Add: #SBATCH --profile=task to slurm script to monitor resource use.
On completion of the job, collate the data into an HDF5 (.h5) file using the command sh5util -j <jobid>
See [NeSI](https://support.nesi.org.nz/hc/en-gb/articles/360000810616-How-can-I-profile-a-SLURM-job-) for details.

![](/plot.jpeg)

