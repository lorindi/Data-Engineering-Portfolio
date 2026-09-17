from airflow.sdk import dag
from pendulum import datetime

from include.pipelines.retail_pipline import build_retail_pipeline

@dag(
    schedule=None,
    start_date=datetime(2021, 1, 1),
    catchup=False,
    tags=["retail"],
)

def retail_etl_dag():
    build_retail_pipeline()

retail_etl_dag()