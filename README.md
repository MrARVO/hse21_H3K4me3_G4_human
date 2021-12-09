# hse21_H3K4me3_G4_human

### Войтецкий Артем

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

Затем, с помощью [скрипта](https://github.com/MrARVO/hse21_H3K4me3_G4_human/blob/main/src/pie.r),
в котором используется библиотека ChIPseeker, проанализируем, где располагаются пики 
гистоновой метки относительно аннотированных генов. 
Получившиеся пай-чарт графики:

![len_hist.H3K4me3_H1.ENCFF041HYH.hg19](https://github.com/MrARVO/hse21_H3K4me3_G4_human/blob/main/images/chip_seeker.H3K4me3_H1.ENCFF041HYH.hg19.filtered.plotAnnoPie.png)

![len_hist.H3K4me3_H1.ENCFF883IEF.hg19](https://github.com/MrARVO/hse21_H3K4me3_G4_human/blob/main/images/chip_seeker.H3K4me3_H1.ENCFF883IEF.hg19.filtered.plotAnnoPie.png)

После этого я соединил два отфильтрованных файла командой bedtools merge, но предварительно отсортировал их
(bedtools merge принимает на вход отсортированный файл).

```bash
cat  *.filtered.bed  |   sort -k1,1 -k2,2n   |   bedtools merge   >  H3K4me3_H1.merge.hg19.bed 
```

Визуализируем исходные два набора ChIP-seq пиков и их объединение в геномном браузере.

![merge_screen](https://github.com/MrARVO/hse21_H3K4me3_G4_human/blob/main/screens/merge_screen.PNG)

Объединенный файл действительно является резльтатом объединения пиков из двух файлов.

#### Анализ участков вторичной структуры ДНК

Теперь необходимо получить и проанализировать данные вторичной структуры ДНК. Я выбрал G4_seq_Li_K, поэтому скачиваем два bed-файла со вторичной структурой ДНК. Далее, как и в файлах с гистоновыми метками, оставляем первые 5 столбцов и объединяем оба файла.

```bash
wget https://ftp.ncbi.nlm.nih.gov/geo/samples/GSM3003nnn/GSM3003539/suppl/GSM3003539_Homo_all_w15_th-1_minus.hits.max.K.w50.25.bed.gz
wget https://ftp.ncbi.nlm.nih.gov/geo/samples/GSM3003nnn/GSM3003539/suppl/GSM3003539_Homo_all_w15_th-1_plus.hits.max.K.w50.25.bed.gz
zcat GSM3003539_Homo_all_w15_th-1_plus.hits.max.K.w50.25.bed.gz | cut -f1-5 > G4.plus.bed
zcat GSM3003539_Homo_all_w15_th-1_minus.hits.max.K.w50.25.bed.gz | cut -f1-5 > G4.minus.bed
cat GSM3003539_*.bed | sort -k1,1 -k2,2n | bedtools merge > G4.merge.bed 
```

Используя те же скрипты, что и в файлах с гистоновыми метками, строим распределение длин участков вторичной структуры, считаем количества пиков и
смотрим, где располагаются участки структуры ДНК относительно аннотированных генов.

![len_hist.G4.merged](https://github.com/MrARVO/hse21_H3K4me3_G4_human/blob/main/images/len_hist.G4_seq_Li_K.merge-1.png)

![chip_seeker.G4.merged.plotAnnoPie](https://github.com/MrARVO/hse21_H3K4me3_G4_human/blob/main/images/chip_seeker.G4.merge.plotAnnoPie.png)

#### Анализ пересечений гистоновой метки и структуры ДНК

Теперь с помощью bedtools intersect найдем пересечения между гистоновой меткой и структурами ДНК.

```bash
  bedtools intersect -a G4.merge.bed -b H3K4me3_H1.merge.hg19.bed > H3K4me3_H1.intersect_with_G4.bed
```

Посмотрим на эти пересечения подробнее:
![len_hist.intersect_with_G4](https://github.com/MrARVO/hse21_H3K4me3_G4_human/blob/main/images/len_hist.H3K4me3_H1.intersect_with_G4-1.png)

Затем визуализируем все в геномном браузере. Нам интересны места, где есть 
пересечение между гистоновой меткой и структурой ДНК (желательно рядом с аннотированным геном):

![merge_screen_2](https://github.com/MrARVO/hse21_H3K4me3_G4_human/blob/main/screens/merge_screen_2.PNG)

Ссылка на [сессию](https://github.com/MrARVO/hse21_H3K4me3_G4_human/blob/main/screens/my_session.gz) в геномном браузере.
 
Чтобы найти все интересующие нас места, воспользуемся последним [скриптом](https://github.com/MrARVO/hse21_H3K4me3_G4_human/blob/main/src/peakAnno.r).
В результате его работы получаем 2 файла. 
Первый - [файл ассоциаций пиков с генами](https://github.com/MrARVO/hse21_H3K4me3_G4_human/blob/main/data/H3K4me3_H1.intersect_with_G4.genes.txt), 
а второй - [список уникальных генов](https://github.com/MrARVO/hse21_H3K4me3_G4_human/blob/main/data/H3K4me3_H1.intersect_with_G4.genes_uniq.txt). 

GO-анализ для полученных уникальных генов:
![GO_1](https://github.com/MrARVO/hse21_H3K4me3_G4_human/blob/main/screens/GO_1.png)

![GO_2](https://github.com/MrARVO/hse21_H3K4me3_G4_human/blob/main/screens/GO_2.png)