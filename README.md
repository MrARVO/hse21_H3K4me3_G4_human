# hse21_H3K4me3_G4_human

## Майнор "Биоинформатика", 2021

#### Выполнил

Войтецкий Артем

Группа 1

Исходные файлы: human (hg19), DNA structure - 
[G4_seq_Li_K](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSM3003539), 
гистоновая метка - [H3K4me3](https://www.encodeproject.org/chip-seq-matrix/?type=Experiment&replicates.library.biosample.donor.organism.scientific_name=Homo%20sapiens&assay_title=Histone%20ChIP-seq&assay_title=Mint-ChIP-seq&status=released),
тип клеток - Н1, исходные BED-файлы - 
[ENCFF041HYH](https://www.encodeproject.org/files/ENCFF041HYH/) 
и [ENCFF883IEF](https://www.encodeproject.org/files/ENCFF883IEF/).

Загружаем bed-файлы и оставляем в каждом только первые 5 столбцов. 
```bash
wget https://www.encodeproject.org/files/ENCFF041HYH/@@download/ENCFF041HYH.bed.gz
wget https://www.encodeproject.org/files/ENCFF883IEF/@@download/ENCFF883IEF.bed.gz
zcat ENCFF041HYH.bed.gz  |  cut -f1-5 > H3K4me3_H1.ENCFF041HYH.hg38.bed
zcat ENCFF883IEF.bed.gz  |  cut -f1-5 > H3K4me3_H1.ENCFF883IEF.hg38.bed
```

Так как файлы взяты в Hg38, то надо их перевести в Hg19. Делается это командой, которую выполнял на сервере:
```bash
liftOver H3K4me3_H1.ENCFF041HYH.hg38.bed hg38ToHg19.over.chain.gz   H3K4me3_H1.ENCFF041HYH.hg19.bed   H3K4me3_H1.ENCFF041HYH.unmapped.bed
liftOver H3K4me3_H1.ENCFF883IEF.hg38.bed hg38ToHg19.over.chain.gz   H3K4me3_H1.ENCFF883IEF.hg19.bed   H3K4me3_H1.ENCFF883IEF.unmapped.bed
```

Далее, с помощью [скрипта](https://github.com/MrARVO/hse21_H3K4me3_G4_human/blob/main/src/hist.r)
построим гистограммы длин участков для каждого эксперимента. 
Также на графике есть информация о количестве пиков в каждом файле (поможет нам отсечь лишнее).

![len_hist.H3K4me3_H1.ENCFF041HYH.hg19](https://github.com/MrARVO/hse21_H3K4me3_G4_human/blob/main/images/len_hist.H3K4me3_H1.ENCFF041HYH.hg19-1.png)

![len_hist.H3K4me3_H1.ENCFF883IEF.hg19](https://github.com/MrARVO/hse21_H3K4me3_G4_human/blob/main/images/len_hist.H3K4me3_H1.ENCFF883IEF.hg19-1.png)

Теперь, из двух файлов с ChIP-seq пиками выкидываем слишком длинные. 
С помощью [скрипта](https://github.com/MrARVO/hse21_H3K4me3_G4_human/blob/main/src/hist2.r)
оставим в файле H3K4me3_H1.ENCFF041HYH.hg19 все пики короче 8000, 
а в файле H3K4me3_H1.ENCFF883IEF.hg19 - короче 5500. В определении этих констант нам помогли предыдущие графики. 
Теперь пики выглядят так:

![len_hist.H3K4me3_H1.ENCFF041HYH.hg19](https://github.com/MrARVO/hse21_H3K4me3_G4_human/blob/main/images/len_hist.H3K4me3_H1.ENCFF041HYH.hg19.filtered-1.png)

![len_hist.H3K4me3_H1.ENCFF883IEF.hg19](https://github.com/MrARVO/hse21_H3K4me3_G4_human/blob/main/images/len_hist.H3K4me3_H1.ENCFF883IEF.hg19.filtered-1.png)