import pandas as pd

def main():
    nyt_covid_data_url = 'https://raw.githubusercontent.com/nytimes/covid-19-data/master/us.csv'
    jh_covid_data_url = 'https://raw.githubusercontent.com/datasets/covid-19/master/data/time-series-19-covid-combined.csv'
    nyt_cleaned_df = clean_csv(nyt_covid_data_url)
    jh_filtered_df = filter_csv(jh_covid_data_url)
    final_df = merge_dfs(nyt_cleaned_df, jh_filtered_df)
    print(final_df)



def clean_csv(url):
  df = pd.read_csv(url, parse_dates=['date'])
  return df

def filter_csv(url):
    df = pd.read_csv(url, parse_dates=['Date'])
    df.rename(
        columns={"Date":"date",
                 "Recovered":"recovered"},
        inplace=True
    )
    return df.loc[df['Country/Region'] == 'US']

def merge_dfs(df1, df2):

    df3 = pd.merge(left=df1, right=df2, how='left', left_on='date', right_on='date')
    print(df3)
    df3.drop(df3.columns[[3,4,5,7]], axis=1, inplace=True)
    df3 = df3[df3.recovered.notnull()]
    return df3

if __name__ == "__main__":
    main()