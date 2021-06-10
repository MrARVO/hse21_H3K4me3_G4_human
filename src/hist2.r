library(ggplot2)
library(dplyr)
# library(tidyr)   # replace_na
# library(tibble)  # column_to_rownames

###

#NAME <- 'H3K4me3_H1.ENCFF041HYH.hg19'
NAME <- 'H3K4me3_H1.ENCFF883IEF.hg19'
OUT_DIR <- '../images/'

###

bed_df <- read.delim(paste0('../data/', NAME, '.bed'), as.is = TRUE, header = FALSE)
colnames(bed_df) <- c('chrom', 'start', 'end', 'name', 'score')
bed_df$len <- bed_df$end - bed_df$start
head(bed_df)

#1
#bed_df <- bed_df %>%
#  arrange(-len) %>%
# filter(len < 5500)

#2
bed_df <- bed_df %>%
  arrange(-len) %>%
  filter(len < 8000)
  
ggplot(bed_df) +
  aes(x = len) +
  geom_histogram() +
  ggtitle(NAME, subtitle = sprintf('Number of peaks = %s', nrow(bed_df))) +
  theme_bw()
ggsave(paste0('len_hist.', NAME, '.filtered.pdf'), path = OUT_DIR)

bed_df %>%
  select(-len) %>%
  write.table(file='H3K4me3_H1.ENCFF883IEF.hg19.filtered.bed',
            col.names = FALSE, row.names = FALSE, sep = '\t', quote = FALSE)

