import pandas as pd
from sqlalchemy import create_engine
import psycopg2
import argparse
import os


# Main function - ingests csv data to postgres db
def main(params):
    # define parameters
    user = params.user
    password = params.password
    host = params.host
    port = params.port
    db = params.db
    table_name = params.table_name
    csv_name = 'Financial_Sample.csv'
   
    # prepare data for ingestion
    engine = create_engine(f'postgresql://{user}:{password}@{host}:{port}/{db}')

    df_iter = pd.read_csv(csv_name, iterator=True, chunksize=100_000)

    df = next(df_iter)

    df.Date = pd.to_datetime(df.Date)

    df.head(n=0).to_sql(name=table_name, con=engine, if_exists='replace')

    df.to_sql(name=table_name, con=engine, if_exists='append')

    # while loop for data ingestion
    while True:
        
        df = next(df_iter)
        
        df.Date = pd.to_datetime(df.Date)
        
        df.to_sql(name=table_name, con=engine, if_exists='append')
        
        
        print('inserted another chunk...' )

# main function
if __name__ == "__main__":
    # parse arguments - user, password, host, port, database name , table name, url of the csv
    parser = argparse.ArgumentParser()
    parser.add_argument('--user', help='username for postgres')
    parser.add_argument('--password', help='password for postgres')
    parser.add_argument('--host', help='host for postgres')
    parser.add_argument('--port', help='port for postgres')
    parser.add_argument('--db', help='database name for postgres')
    parser.add_argument('--table_name', help='name of the table where we will write the results to')

    args = parser.parse_args()

    main(args)