# load the required packages
if (!require("dplyr", quietly = TRUE)) install.packages("dplyr")
if (!require("rstatix", quietly = TRUE)) install.packages("rstatix")
if (!require("ggpubr", quietly = TRUE)) install.packages("ggpubr")

library(dplyr)
library(rstatix)
library(ggpubr)

# Here is the stimulation data for making the example figure
set.seed(2025)
prs_first <- rnorm(200, mean = 0.01, sd = 1)
prs_second <- rnorm(200, mean = 0.2, sd = 1)
prs_third <- rnorm(200, mean = 0.4, sd = 1)
prs_forth <- rnorm(200, mean = 0.6, sd = 1)
prs <- c(prs_first, prs_second, prs_third, prs_forth)

ace <- c(rep("ACE=0", 200), rep("0<ACE<5", 200), rep("4<ACE<8", 200), rep("ACE>=8", 200))

Ec <- data.frame(PRS = prs, ACE = ace)

# Specify your data to be used
dataframe = Ec
predictor = "ACE"
PRS =  "PRS"

# This part use rstatix to perform the t test for mean comparisons.
# rstatix can run other comparisons as well, check package's the instructions.
# add_significance annotates marks for significance from (0, 1e-04, 0.001, 0.01, 0.05, 1) to ("****", "***", "**", "*", "ns").
stat.test <- dataframe %>%
  t_test(formula(paste(PRS, "~", predictor))) %>%
  add_xy_position(x = predictor) %>%
  add_significance("p")

#Here is the plotting
plot <- ggboxplot(Ec, x = predictor, y = PRS, width=0.3) +
  ggdist::stat_halfeye(adjust = .5, width = .3, .width = 0, justification = -0.7, point_colour = NA) +
  gghalves::geom_half_point(side = "l", range_scale = 0.5,  position = position_nudge(x = -0.1),   alpha = .3) +
  stat_summary(fun=mean, colour="red", geom="text", show.legend = FALSE, vjust=-0.5, aes(label=round(..y.., digits=3))) +
  stat_pvalue_manual(stat.test,  xmin = "group1", xmax = "group2", label = "p.signif", y.position = 4.1, step.increase = 0.08) 

plot
