#!/bin/bash
qiime tools import --type 'SampleData[PairedEndSequencesWithQuality]' --input-path casava-18-paired-end-demultiplexed --input-format CasavaOneEightSingleLanePerSampleDirFmt --output-path demux-paired-end.qza
qiime dada2 denoise-paired --i-demultiplexed-seqs demux-paired-end.qza --p-trunc-len-f 150 --p-trunc-len-r 150 --p-trim-left-f 0 --p-trim-left-r 0 --o-representative-sequences rep-seqs-dada2.qza --o-table table-dada2.qza --o-denoising-stats stats-dada2.qza --p-n-threads 0 
qiime metadata tabulate --m-input-file stats-dada2.qza --o-visualization stats-dada2.qzv
mv rep-seqs-dada2.qza rep-seqs-march.qza
#mv table-dada2.qza table-march.qza
qiime feature-table summarize --i-table table.qza --o-visualization table.qzv --m-sample-metadata-file meta_March.txt
qiime feature-table tabulate-seqs --i-data rep-seqs.qza --o-visualization rep-seqs.qzv
qiime feature-classifier classify-sklearn --i-classifier gg-13-8-99-515-806-nb-classifier.qza --i-reads rep-seqs.qza --o-classification taxonomy-gg.qza
qiime metadata tabulate --m-input-file taxonomy-gg.qza --o-visualization taxonomy-gg.qzv
qiime feature-classifier classify-sklearn --i-classifier silva-132-99-515-806-nb-classifier.qza --i-reads rep-seqs.qza --o-classification taxonomy-silva.qza
qiime metadata tabulate --m-input-file taxonomy-silva.qza --o-visualization taxonomy-silva.qzv
qiime phylogeny align-to-tree-mafft-fasttree \
  --i-sequences rep-seqs.qza \
  --o-alignment aligned-rep-seqs.qza \
  --o-masked-alignment masked-aligned-rep-seqs.qza \
  --o-tree unrooted-tree.qza \
  --o-rooted-tree rooted-tree.qza
qiime diversity core-metrics-phylogenetic \
  --i-phylogeny rooted-tree.qza \
  --i-table table.qza \
  --p-sampling-depth 1102 \
  --m-metadata-file meta_March.txt \
  --output-dir core-metrics-results

qiime diversity alpha-group-significance \
  --i-alpha-diversity core-metrics-results/faith_pd_vector.qza \
  --m-metadata-file meta_March.txt \
  --o-visualization core-metrics-results/faith-pd-group-significance.qzv

qiime diversity alpha-group-significance \
  --i-alpha-diversity core-metrics-results/evenness_vector.qza \
  --m-metadata-file meta_March.txt \
  --o-visualization core-metrics-results/evenness-group-significance.qzv

qiime diversity beta-group-significance \
  --i-distance-matrix core-metrics-results/unweighted_unifrac_distance_matrix.qza \
  --m-metadata-file meta_March.txt \
  --m-metadata-column type \
  --o-visualization core-metrics-results/unweighted-unifrac-type-significance.qzv \
  --p-pairwise

qiime diversity beta-group-significance \
  --i-distance-matrix core-metrics-results/unweighted_unifrac_distance_matrix.qza \
  --m-metadata-file meta_March.txt \
  --m-metadata-column plant \
  --o-visualization core-metrics-results/unweighted-unifrac-plant-group-significance.qzv \
  --p-pairwise

qiime diversity alpha-rarefaction \
  --i-table table.qza \
  --i-phylogeny rooted-tree.qza \
  --p-max-depth 1102 \
  --m-metadata-file meta_March.txt \
  --o-visualization alpha-rarefaction.qzv
