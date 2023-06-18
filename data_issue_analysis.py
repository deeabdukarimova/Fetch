import pandas as pd

#Check dataset for missing values issue
# Load the dataset into a pandas DataFrame
df = pd.read_csv('/Users/deeabdukarimova/Downloads/json/brands.csv')

# Check for missing values
missing_values = df.isnull().sum()

# Identify columns with missing values
columns_with_missing_values = missing_values[missing_values > 0].index

# Print the columns with missing values
print("Columns with missing values:")
for column in columns_with_missing_values:
    print(column)


#Check dataset for duplicate records issue
# Load the dataset
dataset = pd.read_csv('/Users/deeabdukarimova/Downloads/json/users.csv')

# Check for duplicate rows
duplicate_rows = dataset.duplicated()
duplicate_count = duplicate_rows.sum()

if duplicate_count > 0:
    print(f"Found {duplicate_count} duplicate rows in the dataset.")
    # Display the duplicate rows
    duplicate_data = dataset[duplicate_rows]
    print(duplicate_data)
else:
    print("No duplicate rows found in the dataset.")