library(ggplot2)
library(dplyr)
# library(tidyr)   # replace_na
# library(tibble)  # column_to_rownames

###

#NAME <- 'H3K4me3_H1.ENCFF041HYH.hg19'
#NAME <- 'H3K4me3_H1.ENCFF041HYH.hg38'
#NAME <- 'H3K4me3_H1.ENCFF883IEF.hg19'
#NAME <- 'H3K4me3_H1.ENCFF883IEF.hg38'
#NAME <- 'G4_seq_Li_K.merge'
OUT_DIR <- 'images/'

###

bed_df <- read.delim(paste0('', NAME, '.bed'), as.is = TRUE, header = FALSE)
colnames(bed_df) <- c('chrom', 'start', 'end', 'name', 'score')
bed_df$len <- bed_df$end - bed_df$start
head(bed_df)

# hist(bed_df$len)

ggplot(bed_df) +
  aes(x = len) +
  geom_histogram() +
  ggtitle(NAME, subtitle = sprintf('Number of peaks = %s', nrow(bed_df))) +
  theme_bw()
ggsave(paste0('len_hist.', NAME, '.pdf'), path = OUT_DIR)

