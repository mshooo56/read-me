# read-me
# Thesis project

Multi-Exchange Rate Systems and Import Misallocation: Evidence from Iran

# Mobina Shojaei
# M.S. in Economics
# Sharif University of technology
2025/10/07

 Step 1: Import customs data from Excel into Stata
 
    - If a good is imported through multiple customs points or is registered multiple times, calculate the total to avoid duplication.
    - If a good is not imported in a given month and thus missing from customs data, assign a value of zero.

 Step 2: Merge customs data with the product group classification data (indicating the type of exchange rate used)

 Step 3: Merge the data with the exchange rate and CPI data
   - Use Iran's CPI to calculate real values in rial
   - Use US CPI to calculate real values in USD

 Step 4: Define the exchange rate gap
 - Some goods received a special preferential rate; compute the exchange rate gap specifically for these cases.

 Step 5: Convert HS codes to BEC classification
   - This step is used to categorize goods into intermediate, capital, and consumer goods.
   - However, the main analysis is conducted based on HS codes, not BEC categories.

 Step 6: Calculate the total value (in USD and rial) and weight of imports by exchange rate type: 
 - preferential, NIMA, NIMA-negotiated, and personal rate

 Step 7: Calculate the share of each exchange rate type in total imports

 Step 8: Calculate the share of intermediate, capital, and consumer goods under the Preferential and NIMA rates

 Step 9: Generate descriptive graphs and statistics
   - Compare the trend of prices and exchange rates (Preferential vs market rate)
   - For similar goods within HS3, compare the trends in their import shares and the exchange rate gap

 Step 10: Estimate regressions to assess the impact of the exchange rate gap on real dollar values (USD).
  - Run regressions separately for Preferential and NIMA gaps
  - Perform separate regressions for intermediate, capital, and consumer goods

 Step 11: Group the data by HS1 codes
  - Run the Generalized Synthetic Control Model for each group
  - Compute group-specific weights
  - Calculate the weighted average of the estimated coefficients
