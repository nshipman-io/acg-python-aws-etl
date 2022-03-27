import traceback

import awswrangler as wr
import logging
import boto3
from decimal import Decimal

def batch_load_data(df, table_name):
    logging.info("Loading dataframes into DynamoDB...")
    df['date'] = df['date'].dt.strftime('%Y-%m-%d')
    df['recovered'] = df['recovered'].apply(lambda x: Decimal(x))
    try:
        updated_records = get_number_of_updated_db_records(df, table_name)
        if updated_records == 0:
            logging.info("No records to update. Ending Job")
            return updated_records
        else:
            wr.dynamodb.put_df(
                df=df,
                table_name=table_name
            )
            logging.info(f"Updated: {updated_records} records to the Table.")
            return updated_records
        logging.info("COMPLETED: BATCH DATA FINISHED")
    except Exception as e:
        logging.error(traceback.format_exc())


def get_number_of_updated_db_records(df, table_name):
    db = boto3.resource('dynamodb')
    table = db.Table(table_name)

    return df.shape[0] - table.item_count




