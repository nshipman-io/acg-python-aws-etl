import awswrangler as wr
import logging
from decimal import Decimal

def batch_load_data(df):
    logging.log("Loading dataframes into DynamoDB...")
    df['date'] = df['date'].dt.strftime('%Y-%m-%d')
    df['recovered'] = df['recovered'].apply(lambda x: Decimal(x))
    df.info()
    wr.dynamodb.put_df(
        df=df,
        table_name='CovidData'
    )
    logging.log("COMPLETED: BATCH DATA FINISHED")