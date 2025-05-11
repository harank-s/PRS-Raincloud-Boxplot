# load the required packages
if (!require("dplyr", quietly = TRUE)) install.packages("dplyr")
if (!require("rstatix", quietly = TRUE)) install.packages("rstatix")
if (!require("ggpubr", quietly = TRUE)) install.packages("ggpubr")

library(dplyr)
library(rstatix)
library(ggpubr)

# Specify your data to be used
dataframe = your_dataframe
predictor = "your_predictor_columnname"
PRS =  "your_PRS_columnname"
Group =  "your_grouping_columnname"

# This part uses rstatix to perform the t-test for mean comparisons.
# rstatix can run other comparisons as well, check the package's instructions.
# add_significance annotates marks for significance from (0, 1e-04, 0.001, 0.01, 0.05, 1) to ("****", "***", "**", "*", "ns").
stat.test <- dataframe %>%
  group_by(Group) %>%
  t_test(formula(paste(PRS, "~", predictor))) %>%
  add_xy_position(x = predictor) %>%
  adjust_pvalue(method = "fdr") %>%
  add_significance("p.adj") 

stat.test[which(stat.test[,"p.adj.signif"] == "ns"),"p.adj.signif"] <- NA

#Here is the plotting
plot <- ggboxplot(dataframe, x = predictor, y = PRS, color=Group, facet.by = Group, width= 0.2) +
  theme(legend.position = "none") +
  ggdist::stat_halfeye(adjust = .5, width = .3, .width = 0, justification = -0.7, point_colour = NA)+
  gghalves::geom_half_point(side = "l", range_scale = 0.5,  position = position_nudge(x = -0.13),   alpha = .3)+
  stat_summary(fun = mean, colour = "red", geom = "text", show.legend = FALSE, vjust = -6.5, aes(label = round(..y.., digits = 3)))+
  stat_pvalue_manual(stat.test,  xmin = "group1", xmax = "group2", label = "p.adj.signif", y.position = "y.position") 

plot
