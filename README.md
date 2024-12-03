# Introduction

The goal of this assignment is to take the US Armed Forces dataset and tidy it in two main ways. One is where each individual soldier is a case (uncounted), while the other is a unique combination of characteristics making up a group of soldiers. 

In this assignment, I created my template GitHub repository, and cloned it onto my device. The three biggest things I did were upload my R file and .csv dataset, move the data to .gitignore, and add a metadata file. 

The dataset contains unstructured information about soldiers in the Armed Forces, including Pay Grade, count, totals, and branch, among others. 

# Implementation

In this file, I essentially used one super long dplyr pipeline to slowly make changes to the raw file that I was processing. 

The first section (up to the first `pivot_longer()`) aimed to get rid of the unnecessary parts of the graph, such as redundant "total" columns and rows. I mainly did this using `select()`, `slice()`, and `mutate()`. I also used `rename()` and `setNames()` to make the column names nicer. 

Then, in the second section, I used a series of `pivot_longer()` and one `separate_wider_delim()` commands in order to actually begin to develop the columns I would want in my final, tidied dataset. This mainly includes separating out each branch by gender. 

In the third section, I created five different dataframes (`ArmedForcesArmy`, `ArmedForcesNavy`, etc.), one for each branch. 
