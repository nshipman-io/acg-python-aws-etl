import pandas as pd

def clean_csv(csv):
  df = pd.read_csv(csv, parse_dates=['date'])
  return df

def filter_csv(csv):
    df = pd.read_csv(csv, parse_dates=['Date'])
    df.rename(
        columns={"Date":"date",
                 "Recovered":"recovered"},
        inplace=True
    )
    return df.loc[df['Country/Region'] == 'US']

def merge_dfs(df1, df2):

    df3 = pd.merge(left=df1, right=df2, how='left', left_on='date', right_on='date')
    df3.drop(df3.columns[[3,4,5,7]], axis=1, inplace=True)
    df3 = df3[df3.recovered.notnull()]
    return df3

def transform_data(primary_data_src, secondary_data_src):
    primary_df = clean_csv(primary_data_src)
    secondary_df = filter_csv(secondary_data_src)
    final_df = merge_dfs(primary_df, secondary_df)
    return final_df

