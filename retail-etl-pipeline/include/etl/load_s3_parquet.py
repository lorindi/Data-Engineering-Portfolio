import pandas as pd

from include.s3_utils import get_storage_options


def load_df_to_s3_csv(df: pd.DataFrame, s3_path: str, aws_conn_id: str) -> None:
    _, storage_options = get_storage_options(aws_conn_id)
    df.to_csv(s3_path, index=False, storage_options=storage_options)
    print(f"Finished writing CSV to S3: {s3_path}")


def load_df_to_s3_parquet(df: pd.DataFrame, s3_path: str, aws_conn_id: str) -> None:
    _, storage_options = get_storage_options(aws_conn_id)
    df.to_parquet(s3_path, index=False, storage_options=storage_options)
    print(f"Finished writing Parquet to S3: {s3_path}")


def read_parquet_from_s3(s3_path: str, aws_conn_id: str) -> pd.DataFrame:
    _, storage_options = get_storage_options(aws_conn_id)
    return pd.read_parquet(s3_path, storage_options=storage_options)