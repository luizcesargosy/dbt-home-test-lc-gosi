# oaknorthbank-lcgosi
OakNorth DBT Home Test

## Description

This DBT project focuses on monthly transaction analysis, calculating totals, percentage amount changes between months, and top customers for each month over the last 12 months.

# Initial Considerations:

- Data Source: Data is sourced through seeds. Two csv files: transactions.csv and customers.csv.

- Data Inconsistencies: It's important to note that the data may contain inconsistencies, which have been addressed to ensure the quality of the analysis:
- - Customer Records: The Customer table may not include all customers who have conducted transactions. For example, records like "CUST_011" may be missing.
- - Transaction Records: In some cases, transaction records might lack the "customer_id" field, making them unusable for customer-specific analysis. Additionally, a few records may contain incorrect year values in the transaction date. 

- Data Cleaning: To maintain data integrity, the query excludes records with anomalies. This is done to normalize the data and ensure its consistency for analysis.
- - To maintain data integrity and consistency, specific criteria have been implemented in the queries to filter out records with anomalies. 
- - By incorporating these criteria, the queries ensure that the data used for analysis is free from inconsistencies and adheres to expected standards.

- Quality Check Using PostgreSQL Adapter: To ensure the quality and reliability of the output, we leverage the PostgreSQL adapter for quality checks. The .env file contains essential configurations that can be customized if necessary. This setup assists in verifying data accuracy and consistency, contributing to the overall reliability of the project.

These considerations highlight the data source, potential inconsistencies, and the data cleaning steps taken to address them before analysis.

# Tables Results
- Three schemas are established: 'oaknorth' serves as the source for the initial data (seeds), 'oaknorth_data_cleaned' represents the cleaned data derived from seeds for use in analytical models, while 'oaknorth_analytics' acts as the destination for the results of the models generated when running the 'dbt run' command.

# Query Considerations:
- The data sources used for creating analytical models have been processed and separated into distinct files to enhance maintenance, usability, and query performance.
- Queries utilize Common Table Expressions (CTE) to temporarily store the result set of a specified query, making it accessible for subsequent queries, also to enhance maintenance, usability, and query performance.
- Some functions have been employed for equations to yield the expected results. Some functions, such as Window Functions, may be adjusted based on data volume and execution frequency to optimize performance. Currently, they are employed to eliminate the need for additional CTE blocks, as these functions inherently handle the required operations.

# For Connection DBMS PostgreSQL - if necessary -
- Run on terminal if necessary to set up connection for dbt debug
```python
POSTGRES_USER=postgres
export POSTGRES_PASSWORD=root
POSTGRES_DB=postgres 
```

# DBT
- Check the .env with the settings if necessary:
- - To check if the connection was successfully established:
```python
dbt debug
```

- - To use the csv files from seeds folder:
```python
dbt seed
```

- - To compile the models:
```python
dbt compile
```
- - Executing this, it creates the tables with the normalized data and creates the treated view for Analytics:
```python
dbt run
```


# Docker
- Additionally, it is also possible to run through Docker:
You can do that using docker too.
```python
docker-compose up -d
```


# Output
## Models

### Model: `data_cleaning`
- The Data Cleaning model allows the preparation and validation of raw data received, ensuring that they comply with the necessary standards before being used in analyses or other models.
- - This model includes transformations that validate and clean customer and transaction data, ensuring that fields such as dates and IDs are correct and in a consistent format for use.
- Path: models/data_cleaning

### Model: `monthly_transaction_summary`
- This model calculates the total transactions for each month in the last 12 months. It also ranks the top customers for each month based on the total transaction amount. Percentage changes in transaction totals are also calculated.
- - This table provides monthly insights, including the top user, transaction amounts, and the percentage change relative to the subsequent months. 
- - It's important to note that the ranking is used to identify the top user, and when an event for percentage_change is null for the top user, it indicates that despite being the top user for the month, there was no transaction history.
- Path: models/transactions_amount/monthly_transaction_summary.sql

#### Output
| transaction_month | customer_id | customer_name    | amount_spending_top_ranked_customer | amount_spending_all_customers | monthly_percent_diff_spending_top_and_all_customers |
|------------------ |------------ |------------------ |---------------------------------- |----------------------------- |---------------------------------------------------- |
| 2023-11-01        | CUST_006    | Emily Brown      | 220.80                           | 426.10                      | -0.58                                              |
| 2023-10-01        | CUST_003    | Michael Johnson  | 321.55                           | 1013.90                     | 0.34                                               |
| 2023-09-01        | CUST_008    | Olivia Garcia    | 150.60                           | 758.95                      | -0.26                                              |
| 2023-08-01        | CUST_004    | Sarah Lee        | 225.80                           | 1029.35                     | -0.43                                              |
| 2023-07-01        | CUST_011    |                  | 500.00                           | 1819.10                     |                                                    |


### Model: `customer_transaction_summary`
- This model analyzes customer transaction histories, calculating the total monthly transactions and the average spending interval between transactions.
- - This table provides insights into customer spending, transaction counts, and other relevant information. 
- - It's worth noting that when multiple transactions occur in a single month, the amount is summed to calculate accurate monthly averages.
- Path: models/customers_transactions/customer_transaction_summary.sql

#### Output
| customer_id | customer_name     | total_transactions | avg_monthly_amount_spending | avg_days_interval_transactions |
|------------ |------------------- |------------------- |--------------------------- |------------------------------ |
| CUST_001    | John Doe          | 6                 | 113.54                    | 23.60                        |
| CUST_006    | Emily Brown       | 6                 | 102.52                    | 26.20                        |
| CUST_004    | Sarah Lee         | 5                 | 149.03                    | 32.75                        |
| CUST_002    | Jane Smith        | 5                 | 98.09                     | 25.75                        |
| CUST_003    | Michael Johnson   | 4                 | 164.38                    | 26.33                        |
| CUST_008    | Olivia Garcia     | 4                 | 132.20                    | 36.00                        |
| CUST_005    | Robert Williams   | 4                 | 131.83                    | 33.33                        |
| CUST_010    | Ava Rodriguez     | 4                 | 124.25                    | 26.00                        |
| CUST_009    | Liam Martinez     | 4                 | 93.84                     | 27.00                        |
| CUST_007    | William Jones     | 4                 | 80.26                     | 34.00                        |

## Documentation and Comments:
The SQL files in this project are documented with comments to provide detailed explanations of the logic and reasoning behind each query.
