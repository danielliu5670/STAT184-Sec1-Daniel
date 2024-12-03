library(tidyverse)

ArmedForcesRaw <- read.csv("~/Downloads/US Armed Forces (6_2024) - Sheet1.csv")

ArmedForcesGroupStep1 <- ArmedForcesRaw %>%
  rename("temp" = "Active.Duty.Personnel.by.Service.Branch..Sex..and.Pay.Grade") %>% # Renaming this long column name just for convenience
  select(-X.2, -X.5, -X.8, -X.11, -X.14, -X.15, -X.16, -X.17) %>% # Getting rid of all the "total" columns
  slice(-12, -18, -29, -30, -31) %>% # Getting rid of all the "total" rows
  mutate( # } Filling in "missing" values, and combining branch and sex as one class
    temp = ifelse(temp == "", "Pay.Grade", temp),
    X.1 = ifelse(X.1 == "", "Army_Female", X.1),
    X = ifelse(X == "Army", "Army_Male", X),
    X.4 = ifelse(X.4 == "", "Navy_Female", X.4),
    X.3 = ifelse(X.3 == "Navy", "Navy_Male", X.3),                   
    X.7 = ifelse(X.7 == "", "Marine.Corps_Female", X.7),
    X.6 = ifelse(X.6 == "Marine Corps", "Marine.Corps_Male", X.6),
    X.10 = ifelse(X.10 == "", "Air.Force_Female", X.10),
    X.9 = ifelse(X.9 == "Air Force", "Air.Force_Male", X.9),
    X.13 = ifelse(X.13 == "", "Space.Force_Female", X.13),
    X.12 = ifelse(X.12 == "Space Force", "Space.Force_Male", X.12)
  ) %>%
  setNames(.[1, ]) %>% # Using these branch/sex combinations to make new column names
  slice(-1, -2) %>% # Getting rid of the row that stored these combination names
  pivot_longer( # Pivoting so the branch and sex become values in a column, so they can later be split - same for all 5 branches
    cols = c("Army_Male", "Army_Female"),
    names_to = "Army_Gender",
    values_to = "Army_Count"
  ) %>%
  pivot_longer(
    cols = c("Navy_Male", "Navy_Female"),
    names_to = "Navy_Gender",
    values_to = "Navy_Count"
  ) %>%
  pivot_longer(
    cols = c("Marine.Corps_Male", "Marine.Corps_Female"),
    names_to = "Marine.Corps_Gender",
    values_to = "Marine.Corps_Count"
  ) %>%
  pivot_longer(
    cols = c("Air.Force_Male", "Air.Force_Female"),
    names_to = "Air.Force_Gender",
    values_to = "Air.Force_Count"
  ) %>%
  pivot_longer(
    cols = c("Space.Force_Male", "Space.Force_Female"),
    names_to = "Space.Force_Gender",
    values_to = "Space.Force_Count"
  ) %>%
  separate_wider_delim( # Separating the branch and sex into two separate columns - finally solving the "hierarchy" of branch and sex problem in the original dataset
    cols = c(Army_Gender, Navy_Gender, Marine.Corps_Gender, Air.Force_Gender, Space.Force_Gender),
    delim = "_", # because the format right now is "Army_Male", for example, so it splits it into two columns with values "Army" and "Male"
    names = c("Branch", "Sex"),
    names_sep = "_" # Just for visual appeal purposes
  ) 

ArmedForcesArmy <- ArmedForcesGroupStep1 %>% # Splitting up this big dataframe into smaller ones, one for each branch
  select(4, 1, 2, 3) %>%
  distinct() %>% # Deleting all duplicate values from having all the values in one big wide dataset
  rename("Count" = "Army_Count", "Branch" = "Army_Gender_Branch", "Sex" = "Army_Gender_Sex") # Renaming columns so they can eventually be bound together into one long dataframe

ArmedForcesNavy <- ArmedForcesGroupStep1 %>%
  select(7, 1, 5, 6) %>%
  distinct() %>%
  rename("Count" = "Navy_Count", "Branch" = "Navy_Gender_Branch", "Sex" = "Navy_Gender_Sex")

ArmedForcesMarineCorps <- ArmedForcesGroupStep1 %>%
  select(10, 1, 8, 9) %>%
  distinct() %>%
  rename("Count" = "Marine.Corps_Count", "Branch" = "Marine.Corps_Gender_Branch", "Sex" = "Marine.Corps_Gender_Sex")

ArmedForcesAirForce <- ArmedForcesGroupStep1 %>%
  select(13, 1, 11, 12) %>%
  distinct() %>%
  rename("Count" = "Air.Force_Count", "Branch" = "Air.Force_Gender_Branch", "Sex" = "Air.Force_Gender_Sex")

ArmedForcesSpaceForce <- ArmedForcesGroupStep1 %>%
  select(16, 1, 14, 15) %>%
  distinct() %>%
  rename("Count" = "Space.Force_Count", "Branch" = "Space.Force_Gender_Branch", "Sex" = "Space.Force_Gender_Sex")

ArmedForcesGroup <- bind_rows(ArmedForcesArmy, ArmedForcesNavy, ArmedForcesMarineCorps, ArmedForcesAirForce, ArmedForcesSpaceForce) %>% # Binding all the dataframes together
  mutate( # Actually changing the pay grades to be accurate to their real names
    Pay.Grade = case_when(
      Pay.Grade == "E1" ~ case_when(
        Branch == "Army" | Branch == "Marine.Corps" ~ "Private",
        Branch == "Navy" ~ "Seaman Recruit",
        Branch == "Air.Force" ~ "Airman Basic",
        Branch == "Space.Force" ~ "Specialist 1",
        .default = Pay.Grade # Important - without this, all the pay grades that don't satisfy this condition become "NA"
      ),
      .default = Pay.Grade
    ),
    Pay.Grade = case_when(
      Pay.Grade == "E2" ~ case_when(
        Branch == "Army" ~ "Private",
        Branch == "Navy" ~ "Seaman Apprentice",
        Branch == "Marine.Corps" ~ "Private First Class",
        Branch == "Air.Force" ~ "Airman",
        Branch == "Space.Force" ~ "Specialist 2",
        .default = Pay.Grade
      ),
      .default = Pay.Grade
    ),
    Pay.Grade = case_when(
      Pay.Grade == "E3" ~ case_when(
        Branch == "Army" ~ "Private First Class",
        Branch == "Navy" ~ "Seaman",
        Branch == "Marine.Corps" ~ "Lance Corporal",
        Branch == "Air.Force" ~ "Airman First Class",
        Branch == "Space.Force" ~ "Specialist 3",
        .default = Pay.Grade
      ),
      .default = Pay.Grade
    ),
    Pay.Grade = case_when(
      Pay.Grade == "E4" ~ case_when(
        Branch == "Army" ~ "Corporal OR Specialist",
        Branch == "Navy" ~ "Petty Officer Third Class",
        Branch == "Marine.Corps" ~ "Corporal",
        Branch == "Air.Force" ~ "Senior Airman",
        Branch == "Space.Force" ~ "Specialist 4",
        .default = Pay.Grade
      ),
      .default = Pay.Grade
    ),
    Pay.Grade = case_when(
      Pay.Grade == "E5" ~ case_when(
        Branch == "Army" | Branch == "Marine.Corps" | Branch == "Space.Force" ~ "Sergeant",
        Branch == "Navy" ~ "Petty Officer Second Class",
        Branch == "Air.Force" ~ "Staff Sergeant",
        .default = Pay.Grade
      ),
      .default = Pay.Grade
    ),
    Pay.Grade = case_when(
      Pay.Grade == "E6" ~ case_when(
        Branch == "Army" ~ "Staff Sergeant",
        Branch == "Navy" ~ "Petty Officer First Class",
        Branch == "Marine.Corps" ~ "Staff Sergeant",
        Branch == "Air.Force" | Branch == "Space.Force" ~ "Technical Sergeant",
        .default = Pay.Grade
      ),
      .default = Pay.Grade
    ),
    Pay.Grade = case_when(
      Pay.Grade == "E7" ~ case_when(
        Branch == "Army" ~ "Sergeant First Class",
        Branch == "Navy" ~ "Chief Petty Officer",
        Branch == "Marine.Corps" ~ "Gunnery Sergeant",
        Branch == "Air.Force" ~ "Master Sergeant OR First Sergeant",
        Branch == "Space.Force" ~ "Master Sergeant",
        .default = Pay.Grade
      ),
      .default = Pay.Grade
    ),
    Pay.Grade = case_when(
      Pay.Grade == "E8" ~ case_when(
        Branch == "Army" ~ "First Sergeant OR Master Sergeant",
        Branch == "Marine.Corps" ~ "First Sergeant OR Master Sergeant",
        Branch == "Navy" ~ "Senior Chief Petty Officer",
        Branch == "Air.Force" ~ "Senior Master Sergeant OR First Sergeant",
        Branch == "Space.Force" ~ "Senior Master Sergeant	",
        .default = Pay.Grade
      ),
      .default = Pay.Grade
    ),
    Pay.Grade = case_when(
      Pay.Grade == "E9" ~ case_when(
        Branch == "Army" ~ "Sergeant Major OR Command Sergeant Major",
        Branch == "Navy" ~ "Master Chief Petty Officer OR Fleet/Command Master Chief Petty Officer",
        Branch == "Marine.Corps" ~ "Sergent Major OR Master Gunnery Sergeant",
        Branch == "Air.Force" ~ "Chief Master Sergeant OR First Sergeant",
        Branch == "Space.Force" ~ "Chief Master Sergeant",
        .default = Pay.Grade
      ),
      .default = Pay.Grade
    ),
    Pay.Grade = case_when(
      Pay.Grade == "W1" ~ case_when(
        Branch == "Army" | Branch == "Navy" | Branch == "Marine.Corps" ~ "Warrant Officer",
        .default = "N/A*"
      ),
      .default = Pay.Grade
    ),
    Pay.Grade = case_when(
      Pay.Grade == "W2" | Pay.Grade == "W3" | Pay.Grade == "W4" | Pay.Grade == "W5" ~ case_when(
        Branch == "Army" | Branch == "Navy" | Branch == "Marine.Corps" ~ "Chief Warrant Officer",
        .default = "N/A*"
      ),
      .default = Pay.Grade
    ),
    Pay.Grade = case_when(
      Pay.Grade == "O1" ~ case_when(
        Branch == "Navy" ~ "Ensign",
        Branch != "Navy" ~ "Second Lieutenant"
      ),
      .default = Pay.Grade
    ),
    Pay.Grade = case_when(
      Pay.Grade == "O2" ~ case_when(
        Branch == "Navy" ~ "Lieutenant Junior Grade	",
        Branch != "Navy" ~ "First Lieutenant"
      ),
      .default = Pay.Grade
    ),
    Pay.Grade = case_when(
      Pay.Grade == "O3" ~ case_when(
        Branch == "Navy" ~ "Lieutenant",
        Branch != "Navy" ~ "Captain"
      ),
      .default = Pay.Grade
    ),
    Pay.Grade = case_when(
      Pay.Grade == "O4" ~ case_when(
        Branch == "Navy" ~ "Lieutenant Commander",
        Branch != "Navy" ~ "Major"
      ),
      .default = Pay.Grade
    ),
    Pay.Grade = case_when(
      Pay.Grade == "O5" ~ case_when(
        Branch == "Navy" ~ "Commander",
        Branch != "Navy" ~ "Lieutenant Colonel"
      ),
      .default = Pay.Grade
    ),
    Pay.Grade = case_when(
      Pay.Grade == "O6" ~ case_when(
        Branch == "Navy" ~ "Captain",
        Branch != "Navy" ~ "Colonel"
      ),
      .default = Pay.Grade
    ),
    Pay.Grade = case_when(
      Pay.Grade == "O7" ~ case_when(
        Branch == "Navy" ~ "Rear Admiral (Lower)",
        Branch != "Navy" ~ "Brigadier General"
      ),
      .default = Pay.Grade
    ),
    Pay.Grade = case_when(
      Pay.Grade == "O8" ~ case_when(
        Branch == "Navy" ~ "Rear Admiral (Upper)",
        Branch != "Navy" ~ "Major General"
      ),
      .default = Pay.Grade
    ),
    Pay.Grade = case_when(
      Pay.Grade == "O9" ~ case_when(
        Branch == "Navy" ~ "Vice Admiral",
        Branch != "Navy" ~ "Lieutenant General"
      ),
      .default = Pay.Grade
    ),
    Pay.Grade = case_when(
      Pay.Grade == "O10" ~ case_when(
        Branch == "Navy" ~ "Admiral",
        Branch != "Navy" ~ "General"
      ),
      .default = Pay.Grade
    )
  ) # this ends up creating the dataframe where the group of counts is a case. 

ArmedForcesGroup <- ArmedForcesGroup %>% # Changing the dots in the branch row values to spaces again, since the splitting has been done, mainly for visual appeal
  mutate(
    Branch = case_when(
      Branch == "Marine.Corps" ~ "Marine Corps",
      Branch == "Air.Force" ~ "Air Force",
      Branch == "Space.Force" ~ "Space Force",
      .default = Branch
    ),
  )

ArmedForcesWithValuesUncounted <- ArmedForcesGroup %>% # Creating an uncounted dataframe from rows that have counts
  arrange(Count) %>% # Arranging by count so the N/As are all at the end
  slice((n() - 20:n())) %>% # slicing away only the first 220, could be adjusted based on number of N/As
  mutate(
    Count = readr::parse_number(Count) # Extracts numbers from those with commas, like "1,234"
  ) %>%
  uncount(Count) # Actually uncounts

ArmedForcesNA <- ArmedForcesGroup %>% # Creating a dataframe of only the N/A values (since trying to uncount these would result in an error)
  arrange(Count) %>%
  slice_tail(n = 20) %>% # Last 20 are all N/As
  select(-Count) # Getting rid of the count column, since it wasn't uncounted. Otherwise, the entire dataframe would have 240 NAs for count

ArmedForcesIndividual <- bind_rows(ArmedForcesWithValuesUncounted, ArmedForcesNA) %>% # Combining the two to make the individual case set
  arrange("Pay.Grade") # Arranging by pay grade for convenience / visual appeal
  
View(ArmedForcesGroup)
View(ArmedForcesIndividual) # Viewing the two dataframes for verification
write.csv(ArmedForcesIndividual, file = "ArmedForcesIndividual.csv")