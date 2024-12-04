# Introduction

The goal of this assignment is to take the US Armed Forces dataset and tidy it in two main ways. One is where each individual soldier is a case (uncounted), while the other is a unique combination of characteristics making up a group of soldiers. 

In this assignment, I created my template GitHub repository, and cloned it onto my device. The three biggest things I did were upload my R file and .csv dataset, move the data to .gitignore, and add a metadata file. 

The dataset contains unstructured information about soldiers in the Armed Forces, including Pay Grade, count, totals, and branch, among others. 

# Implementation

In this file, I essentially used one super long dplyr pipeline to slowly make changes to the raw file that I was processing. 

The first section (up to the first `pivot_longer()`) aimed to get rid of the unnecessary parts of the graph, such as redundant "total" columns and rows. I mainly did this using `select()`, `slice()`, and `mutate()`. I also used `rename()` and `setNames()` to make the column names nicer. 

Then, in the second section, I used a series of `pivot_longer()` and one `separate_wider_delim()` commands in order to actually begin to develop the columns I would want in my final, tidied dataset. This mainly includes separating out each branch by gender. 

In the third section, I created five different dataframes (`ArmedForcesArmy`, `ArmedForcesNavy`, etc.), one for each branch. The reason I did this is because the way the tidied dataset is at this point, the branches are still in a "wide" format, and I need them to be in a longer format. Additionally, there is a huge amount of redundancy, but calling `distinct()` on the entire dataset at the time wouldn't have worked. After extracting out each individual dataframe using `select()`, I called `distinct()` to remove redundancy, and used `rename()` to make the column names generic again (`Count`, `Branch`, and `Sex`). 

Then, in the fourth section, I began by using `bind_rows()` to combine these dataframes into one. At this point, the data is "tidy" in the sense that the case is correct (it is a group of soldiers that are uniquely identified by their Branch and Sex). However, the bulk of this section was a huge `mutate()` function that individually renamed each Pay Grade using the below format:

```
Pay.Grade = case_when(
      Pay.Grade == [PAY GRADE] ~ case_when(
        Branch == [BRANCH] ~ [NAME],
        ..
        ..
        .default = Pay.Grade 
      ),
      .default = Pay.Grade
    )
```

At this point, the dataframe `ArmedForcesGroup` is tidy. However, the dataframe where each case is an individual soldier still needs to be created.

In the fifth and final section, I make this individual soldier dataframe in three main steps. 
1. First, I cut off all of the NA values from the dataframe, which conveniently were all at the end. Then, I used `parse_number()` to reduce commas and `uncount()` to actually uncount.
2. Then, I extract only the NA values from the dataframe, and use `select()` to get rid of the Count column.
3. Finally, I bind them together using `bind_rows()`.

# Results / Conclusion

After completing this assignment, I mainly learned that wrangling data can be really difficult, especially when it comes from a government source that is not very tidy to begin with. When I first started the assignment, I assumed it would be easy to tidy, since it looked like it already had most of the work done, but it took much more code, and much more time. In the future, when working with bigger datasets, especially ones that I know need to be uncounted, I should probably select ones that are much more tidy (which I can more accurately gauge now that I actually know what a tidy dataset looks like). 

These two images show before and after pictures of the dataset - if we were to just look at the `before` dataset, it would seem pretty tidy, but not when compared to the `after` dataset:

`Before:` 
<img width="300" alt="Screenshot 2024-12-04 at 6 43 12 PM" src="https://github.com/user-attachments/assets/dbd8440b-1e90-4d5f-ac15-84bcd0afea90">
`After:` 
<img width="300" alt="Screenshot 2024-12-04 at 6 45 26 PM" src="https://github.com/user-attachments/assets/cd1b3cc2-f029-4546-92f8-2730d5c6e85f">

# Contact

Email: dxl5670@psu.edu



