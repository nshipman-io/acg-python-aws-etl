import awswrangler as wr
from decimal import Decimal

def batch_load_data(df):
    print("RUNNING: LOADING BATCH DATA")
    df['date'] = df['date'].dt.strftime('%Y-%m-%d')
    df['recovered'] = df['recovered'].apply(lambda x: Decimal(x))
    df.info()
    wr.dynamodb.put_df(
        df=df,
        table_name='CovidData'
    )
    print("COMPLETED: BATCH DATA FINISHED")