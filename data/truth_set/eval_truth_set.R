DESeq2 = read.table("DESeq2_results.dat", header=T)
edgeR = read.table("edgeR_results.dat", header=T)

DESeq2_df = DESeq2[,c('log2FoldChange', 'padj')]
options(stringsAsFactors=F)
edgeR_df = edgeR[,c('logFC', 'FDR')]
colnames(edgeR_df) = c('log2FoldChange', 'padj') # make consistent

genes = rownames(edgeR)
DESeq2_df = DESeq2_df[genes,]  # for consistent ordering of genes


joint_info = data.frame('DESeq2_logFC' = DESeq2_df$log2FoldChange, 'DESeq2_padj' = DESeq2_df$padj,
                        'edgeR_logFC' = edgeR_df$log2FoldChange, 'edgeR_padj' = edgeR_df$padj)

joint_info$maxPadj = pmax(joint_info$DESeq2_padj, joint_info$edgeR_padj)

joint_info$minPadj = pmin(joint_info$DESeq2_padj, joint_info$edgeR_padj)

rownames(joint_info) = genes

write.table(joint_info, file="edgeR_n_DESeq2_combined.joint_info.dat", quote=F, sep="\t")


