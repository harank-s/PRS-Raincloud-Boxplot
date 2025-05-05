library(magrittr)
library(multipanelfigure)
library(rstatix)
library(ggpubr)
library(dplyr)

combined_table7 <- read.table("data_files/combined_table7.txt", header = T)

bd_PRS <- select(combined_table7, c('Participant.ID', 'sum_12c', "bd_zscores"))
names(bd_PRS)[3] <- "ZSCORE"
bd_PRS$PRS <- "BD"

adhd_PRS <- select(combined_table7, c('Participant.ID', 'sum_12c', "adhd_zscores"))
names(adhd_PRS)[3] <- "ZSCORE"
adhd_PRS$PRS <- "ADHD"

mdd_PRS <- select(combined_table7, c('Participant.ID', 'sum_12c', "MDD_zscores.y"))
names(mdd_PRS)[3] <- "ZSCORE"
mdd_PRS$PRS <- "MDD"

scz_PRS <- select(combined_table7, c('Participant.ID', 'sum_12c', "SCZ_zscores.x"))
names(scz_PRS)[3] <- "ZSCORE"
scz_PRS$PRS <- "SCZ"

boxplot_data3 <- rbind(bd_PRS, adhd_PRS, mdd_PRS, scz_PRS)

stat.test <- boxplot_data3 %>%
  group_by(PRS) %>%
  t_test(ZSCORE ~ sum_12c) %>%
  adjust_pvalue() 

stat.test

stat.test <- stat.test %>% 
  add_xy_position(x = "sum_12c")

stat.test2 <- stat.test

stat.test2[which(stat.test2[,"p"] >= 0.05),"p"] <- NA
stat.test2[which(stat.test2[,"p.adj.signif"] == "ns"),"p.adj.signif"] <- NA
stat.test2[which(stat.test2[,"p.adj.signif"] == "**"),"p.adj.signif"] <- "*"

stat.test2$y.position <- stat.test2$y.position + 1.8
boxplot_data3$sum_12c <- as.numeric(boxplot_data3$sum_12c)

p <- ggboxplot(
  boxplot_data3, x = "sum_12c", y = "ZSCORE",
  color = "PRS",
  facet.by = "PRS", ylim = c(-3.5, 5.5), width=0.1, outlier.shape = NA) + 
  facet_grid(~factor(PRS, levels=c('ADHD','BD', "MDD", "SCZ"))) +
  scale_fill_manual(values=c("ADHD","BD", "MDD", "SCZ")) +
  scale_x_discrete(name ="ACE number (Categorical)",
                   limits = c("0", "1", "2", "3"),
                   labels=c("0" = "None", "1" = "One", "2" = "Two", "3" = "Three & more")) + 
  ggdist::stat_halfeye(adjust = .5, width = .3, .width = 0, justification = -.3, point_colour = NA) +
  gghalves::geom_half_point(side = "l", range_scale = .4, alpha = .5) +
  stat_summary(fun=mean, colour="red", geom="text", show.legend = FALSE, vjust=-11, aes(label=round(..y.., digits=2))) +
  stat_pvalue_manual(stat.test2, label = "p.adj.signif", y.position = 4, step.increase = 0.06) 

p <- ggboxplot(
  boxplot_data3, x = "sum_12c", y = "ZSCORE",
  color = "PRS",
  facet.by = "PRS", ylim = c(-3.5, 5.5), width = 0.1, outlier.shape = NA) + 
  facet_wrap(~ factor(PRS, levels = c('BD','ADHD',  'MDD', 'SCZ')), nrow = 2, ncol = 2) +
  scale_fill_manual(values = c( "BD","ADHD", "MDD", "SCZ")) +
  scale_x_discrete(name = "ACE number (Categorical)",
                   limits = c("0", "1", "2", "3"),
                   labels = c("0" = "None", "1" = "One", "2" = "Two", "3" = "Three & more")) + 
  ggdist::stat_halfeye(adjust = .5, width = .3, .width = 0, justification = -.3, point_colour = NA) +
  gghalves::geom_half_point(side = "l", range_scale = .4, alpha = .2) +
  stat_summary(fun = mean, colour = "red", geom = "text", show.legend = FALSE, vjust = -12, aes(label = round(..y.., digits = 2))) +
  stat_pvalue_manual(stat.test2, label = "p.adj.signif", y.position = 4.1, step.increase = 0.06) + 
  theme(legend.position = "none")

p
