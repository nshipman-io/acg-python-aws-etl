import transform
import dynamo

def main():
    nyt_covid_data_url = 'https://raw.githubusercontent.com/nytimes/covid-19-data/master/us.csv'
    jh_covid_data_url = 'https://raw.githubusercontent.com/datasets/covid-19/master/data/time-series-19-covid-combined.csv'

    data = transform.transform_data(nyt_covid_data_url,jh_covid_data_url)

    print(data)

    dynamo.batch_load_data(data)



if __name__ == "__main__":
    main()