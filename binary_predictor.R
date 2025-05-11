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

# This part use rstatix to perform the t test for mean comparisons.
# rstatix can run other comparisons as well, check package's the instructions.
# add_significance annotates marks for significance from (0, 1e-04, 0.001, 0.01, 0.05, 1) to ("****", "***", "**", "*", "ns").
stat.test <- dataframe %>%
  t_test(formula(paste(PRS, "~", predictor))) %>%
  add_xy_position(x = predictor) %>%
  add_significance("p")

# Here is the plotting
plot <- ggboxplot(dataframe, x = predictor, y = PRS, width=0.15) +
  ggdist::stat_halfeye(adjust = .5, width = .3, .width = 0, justification = -.5, point_colour = NA) +
  gghalves::geom_half_point(side = "l", range_scale = .3, alpha = .4) +
  stat_summary(fun=mean, colour="red", geom="text", show.legend = FALSE, vjust=-0.5, aes(label=round(..y.., digits=3))) +
  stat_pvalue_manual(stat.test, label = "p.signif", y.position = 4, step.increase = 0.1) 

plot