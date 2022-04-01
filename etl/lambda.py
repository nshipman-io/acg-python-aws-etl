import os

import logging

import notifications
import transform
import dynamo

def handler(event, context):
    table_name = os.environ['DYNAMO_TABLE_NAME']
    sns_arn = os.environ['SNS_ARN']

    logging.info("Beginning ETL Job...")

    nyt_covid_data_url = 'https://raw.githubusercontent.com/nytimes/covid-19-data/master/us.csv'
    jh_covid_data_url = 'https://raw.githubusercontent.com/datasets/covid-19/master/data/time-series-19-covid-combined.csv'

    logging.info("Transforming Covid-19 Data")
    data = transform.transform_data(nyt_covid_data_url, jh_covid_data_url, sns_arn)

    number_of_updated_records = dynamo.batch_load_data(data, table_name, sns_arn)

    message = f"Updated DynamoDB Table: {table_name} with {number_of_updated_records} record(s)"
    subject = "US COVID-19 Records ETL"

    notifications.publish_message(sns_arn, message, subject)
