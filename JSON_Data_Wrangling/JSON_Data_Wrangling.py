import pandas as pd
import json
from pandas.io.json import json_normalize

json_filepath = 'data/world_bank_projects.json'


# 1) Find top 10 countries with most projects

## Read JSON file into Pandas DataFrame
json_df = pd.read_json(json_filepath)

## Count the values in the 'countryname' column as it will represent
## how many projects each country as had approved and take the top 10

top_countries = json_df['countryname'].value_counts()
print(top_countries.head(10))



# 2) Find the top 10 major project themes
#    (using column 'mjtheme_namecode')

## Read the JSON file as a string
json_string = json.load((open(json_filepath)))

## Extract the 'mjtheme_namecode' column using json_normalize
theme_namecode = json_normalize(json_string, 'mjtheme_namecode')

## Explore the newly created Data Frame
print(theme_namecode.head(10))
print(theme_namecode.info())

## What are the empty entries in the 'name' column?
print(theme_namecode['name'][1])

## Disregarding the entries with empty strings, groupby and count number
## of code/name
theme_namecode_f = theme_namecode[theme_namecode['name'] != ""]
by_name = theme_namecode_f.groupby(['code','name'])['name'].count()

top_projects = by_name.sort_values(ascending=False)

## Select the top 10 project names
print(top_projects.head(10))



# 3) In 2. above you will notice that some entries have only the code 
# and the name is missing. Create a dataframe with the missing names
# filled in.

## Use top_projects DataFrame to create dictionary with code# and name
## as key-value pairs
name_code = {(key):(value) for key, value in top_projects.sort_index().
             keys()}

## Replace values in 'name' based on their 'code' value by using the
## dictionary 'name_code' of names for corresponding code
theme_namecode['name'] = [name_code[entry] for entry in theme_namecode.
               code.values]

print(theme_namecode.head())
