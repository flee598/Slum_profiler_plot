
# get missing packages  --------------
# rhdf5 is available from Bioconductor
pcks_needed <- c("BiocManager", "ggplot2", "patchwork")
pcks_2_install <- pcks_needed[!(pcks_needed %in% installed.packages()[,"Package"])]

if(length(pcks_2_install)) install.packages(pcks_2_install)
if (!"rhdf5" %in% installed.packages()) BiocManager::install("rhdf5")

# packages  --------------
library(rhdf5)     # read .h5 files
library(ggplot2)
library(patchwork) # combine plots

# data  --------------
tmp <- h5ls("job_11211998.h5")
tmp
# get relevant data and close file  
df1 <- h5read("job_11211998.h5", "/Steps/0/Nodes/wbn125/Tasks/0")
h5closeAll()

# data transformations (time to hrs, data to GB etc.)
df1$CPUUtilization <- df1$CPUUtilization/100
df1$hours <- df1$ElapsedTime/60/60
df1$RSS_GB <- df1$RSS/(1000000)
df1$WriteMB_Cum <- cumsum(df1$WriteMB)
df1$ReadMB_Cum <- cumsum(df1$ReadMB)
df1$Write_s <- df1$WriteMB/30
df1$ReadMB_s <- df1$ReadMB/30

df1 <- df1[c("hours", "CPUUtilization", "RSS_GB", "WriteMB", "ReadMB", 
  "WriteMB_Cum", "ReadMB_Cum", "Write_s", "ReadMB_s")]

# plots --------------
# CPU
p1 <- ggplot(df1, aes(hours, CPUUtilization)) +
  geom_line(size = 1, colour = "red") +
  theme_bw() +
  ylab("CPUs")
  
# RSS
p2 <- ggplot(df1, aes(hours, RSS_GB)) +
  geom_line(size = 1, colour = "red") +
  theme_bw() +
  ylab("RSS (GB)")

# I/O (MB)
p3 <- ggplot() +
  geom_line(data = df1, aes(hours, WriteMB_Cum), size = 1, colour = "red",
    linetype = "dotted") +
  geom_line(data = df1, aes(hours, ReadMB_Cum), size = 1, colour = "red" ) +
  theme_bw() +
  ylab("I/O (MB)")

# I/O (MB/s)
p4 <- ggplot() +
  geom_line(data = df1, aes(hours, WriteMB/30), size = 1, colour = "red",
    linetype = "dotted") +
  geom_line(data = df1, aes(hours, ReadMB/30), size = 1, colour = "red") +
  theme_bw() +
  ylab("I/O (MB/s)")

# combine plots  --------------
pAll = p1/p2/p3/p4

ggplotclean <- theme_bw()  + 
  theme(axis.text.x = element_blank(),
    axis.title.x = element_blank())

# Remove axis labels from top 3 plots 
pAll[[1]] = pAll[[1]] + ggplotclean
pAll[[2]] = pAll[[2]] + ggplotclean
pAll[[3]] = pAll[[3]] + ggplotclean

pAll

