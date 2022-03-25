import transform
import dynamo
import logging

def handler(event, context):
    logging.log("Beginning ETL Job...")
    nyt_covid_data_url = 'https://raw.githubusercontent.com/nytimes/covid-19-data/master/us.csv'
    jh_covid_data_url = 'https://raw.githubusercontent.com/datasets/covid-19/master/data/time-series-19-covid-combined.csv'
    logging.log("Transforming Covid-19 Data")
    data = transform.transform_data(nyt_covid_data_url,jh_covid_data_url)
    dynamo.batch_load_data(data)

