In this project, my objective was to analyse a raw data set using Python for data interpretation and organization. The provided file was in Excel format. 

Here's an overview of the approach I followed for data analysis: 

- Comprehensive understanding and experimentation with the data. 
- Establishing a data pipeline to process the data effectively. 
- Investigating the data for potential issues, such as data quality problems. 
- Attempting to create a data model that adheres to the third normal form (3NF) principles. 
- Identifying trends within the data that could provide valuable business insights. 

# Stage 1: Understanding the data 

Before delving into data analysis, it is crucial to gain a comprehensive understanding of the data and its underlying representation. I dedicated time to thoroughly examine the data, comprehending its meaning and the relationships among its components. Upon reviewing the data, I realized it could be suitably structured using a relational database, enabling table normalization. Since the data was initially provided in an Excel file, my next step was to create a data pipeline that could ingest the data from the Excel file into a **Postgres** table. This allowed me to conveniently access the data through **PGAdmin**. I aimed to develop a data model using SQL queries and normalize the table. Additionally, I leveraged SQL queries to identify potential data quality issues. 

Considering the requirement to utilize Python, I saw an opportunity to showcase my proficiency by incorporating Python scripts within my pipeline. Furthermore, I performed data analysis using Python, expanding upon my use of the language. 

To initiate the process, I embarked on a "first sprint" using a Python notebook named **"upload_data.ipynb."** This notebook served as an experimentation ground, facilitating a deeper understanding of the task at hand. I utilized Docker to spin up multiple containers, granting access to Postgres and PGAdmin. 

Below is an example of the command I executed in the terminal to achieve the desired outcome: 

*pt 1 Docker commands to spin up database *
```
winpty docker run -it \  

  -e POSTGRES_USER="root" \  

  -e POSTGRES_PASSWORD="root" \  

  -e POSTGRES_DB="Lloyds" \  

  -v /C/Users/owned/Documents/Lloyds/Data:/var/lib/postgresql/data \  

  -p 5431:5432 \  

  postgres:13 
```

This command initiates the spinning up of the database using Docker. It sets up a Postgres container with specific environment variables for the user, password, and database name. Additionally, it mounts a volume from the local file system to the container's /var/lib/postgresql/data directory, ensuring data persistence. Port forwarding is also configured, mapping port 5431 of the host machine to port 5432 of the Postgres container. The specified image used is postgres:13. 

I would like to share an example of my work from the Python notebook. As part of the task, I created a DataFrame called 'Lloyds_data' using the provided financial data sample. 

Within this context, I utilized the pd.io.sql.get_schema() function, which accepts two parameters: 

- **df**: This parameter represents the DataFrame for which the SQL schema needs to be generated. It captures the structure and data types of the DataFrame. 
- **name**='Lloyds_data': This parameter specifies the desired name for the SQL table or schema. In this case, the name is set to 'Lloyds_data'. 

The **pd.io.sql.get_schema()** function examines the DataFrame's structure and data types, producing an appropriate SQL schema. This schema defines the table structure, including column names and data types, necessary for creating a corresponding table in a SQL database. 

Moreover, I encountered data issues while using the to_sql command, which I will elaborate on during the interview. These issues will be discussed further, providing additional insights into the situation. 

![Image 1](/1.png) 

After conducting extensive data exploration and gaining a deeper understanding of the data pipeline requirements, I reached the conclusion that spinning up multiple Docker containers would be an inefficient approach. Consequently, I devised a refined and definitive solution for my data pipeline. This solution aims to optimize the process and streamline the data handling procedures effectively. 

# Stage 2: Data Pipeline 

I developed a data pipeline solution that utilized a **docker-compose.yaml** file to efficiently deploy Docker containers for Postgres and PGAdmin. By incorporating volume mounting, I ensured that data persisted even when the containers were terminated, preventing data loss. 

The docker-compose.yaml file sets up two containers: one for a PostgreSQL database (pgdatabase) and another for pgAdmin (pgadmin). The PostgreSQL container is configured with a specific user, password, and database name, and it persists its data in the ./Data directory on the host machine. The pgAdmin container provides a web-based interface for managing the PostgreSQL database and is accessible through localhost:8080 on the host machine. 

I created a script **ingest_data.py**, which performs the ingestion of CSV data into a PostgreSQL database. 

This script establishes a connection to a PostgreSQL database and ingests data from a CSV file in chunks, appending it to a specified table. It uses pandas and SQLAlchemy to handle the data and provides flexibility by accepting user-defined command-line arguments for database connection details and table names. 

# Stage 3: Investigating issues with the data  

With the table successfully imported into a PostgreSQL database, I proceeded to run SQL queries to investigate any potential issues with the data quality. One particular concern was the absence of a discernible primary key or natural key for the dataset. To determine a potential primary key, I initially considered the combination of the "Segment," "Country," "Product," and "Date" columns. Thus, I executed the following SQL query: 

```
SELECT DISTINCT "Lloyds_data"."Segment", 

    "Lloyds_data"."Country", 

    "Lloyds_data"."Product", 

    "Lloyds_data"."Date" 

   FROM "Lloyds_data"; 
```

However, this query did not yield a definitive primary key. Through further experimentation, it became evident that none of the columns could serve as a unique identifier for the data rows. This raises concerns regarding the data quality, prompting me to revisit the data source and investigate the possibility of missing columns that could have acted as a natural primary key. 

In the absence of a natural primary key, a surrogate key was employed. Nevertheless, this solution is less than ideal, as it does not fully prevent the occurrence of duplicate data. A natural key, serving as a primary key, would be more preferable as it ensures data integrity by effectively preventing duplicate entries. This is particularly relevant if multiple versions of the source data have to be loaded to a target table.  

Another significant issue I encountered while analysing the data was the presence of redundant columns. It is generally not recommended to have columns that contain data that can be derived or inferred from other columns within the same table. Upon careful examination, I identified three such redundant columns: "Gross Sales," "Sales," and "Profit." To illustrate the redundancy, I constructed a SQL query that clearly demonstrated how the information in these columns could be obtained from other existing columns. Based on this analysis, I would advocate for the removal of these redundant columns from the table. 

I performed additional queries that can be elaborated on and demonstrated during the interview. 

# Stage 4: Data model  

I proceeded to develop a data model based on the given data and determined how to normalize the table. During this process, I identified that the "Discount Band" could be separated from the main table and placed in a separate table where "Discount Band" would serve as the primary key. To achieve this, I created a SQL query that extracted the range limits for each discount band, which could then be used to populate the separate table. 

Within the main table, there existed a "Date" column along with three additional columns: "Month Number," "Month Name," and "Year." It was determined that these three columns were not necessary in the main table. To address this, I devised a SQL query that extracted the month number, month name, and year values from the "Date" column. Subsequently, I performed an additional SQL query to verify that the combination of these four columns matched the corresponding columns in the main table. Based on this analysis, I propose separating the "Date" column into a separate table dedicated to dates, with the three additional columns included in this separate table. In this scenario, the "Date" column would serve as the primary key for the date table, while the main table would reference the date table using the "Date" column. 

An additional table that could be considered is a product table, where product-related information such as Manufacturing Price would reside. In this setup, the product column would serve as the primary key. The following SQL query accomplishes this: 

```
SELECT DISTINCT "Lloyds_data"."Product", 

    "Lloyds_data"."Manufacturing Price" 

   FROM "Lloyds_data"; 
```

# Stage 5: Data analysis 

Using Python, I performed data analysis on the dataset utilizing various Python packages, including pandas, matplotlib, and seaborn. 

One of the analyses involved visualizing sales trends over time. I plotted the total sales data against monthly incremental periods to create a graph. This visualization provides valuable insights into the correlation between sales and time. Furthermore, it opens up possibilities for further investigation, such as exploring the impact of specific time periods, like periods of high inflation, on business sales. 

Here is the graph generated by my Python script: 

![Graph of Sales Trend Over Time plotting Month against Total Sales](/2.png)

Using Python, I generated a bar chart to visualize the Sales by Product. The Total Sales data was plotted against the respective products. This analysis provides valuable business insights by identifying the top-selling and least-selling products. With this information, further actions can be taken. For instance, for the least popular products, we can explore strategies to improve their sales through targeted advertising or assess the viability of discontinuing those products from our product line. 

The bar chart below illustrates the Sales by Product: 

![Graph of Sales by Product plotting Product against Total Sales](/3.png)

I have produced a bar plot showcasing the sales distribution across different countries. The plot represents the total sales for each country, with the height of each bar indicating the average sales value. This visualization provides valuable business insights by identifying countries where our performance is below expectations as well as countries where we excel. 

For countries with lower sales figures, we can strategize ways to enhance our business presence, such as considering partnerships with influential figures from those regions to act as brand ambassadors. 

Below is the bar plot representing the data: 

![Graph of Sales by Country plotting Country against Total Sales](/4.png)
