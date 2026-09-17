import pandas as pd
import yaml
from airflow.exceptions import AirflowException
from airflow.sdk import task, task_group

from include.etl.extract_s3 import extract_data_from_s3
from include.etl.load_s3_parquet import load_df_to_s3_csv, load_df_to_s3_parquet, read_parquet_from_s3
from include.etl.transform import (
    enrich_merged_data,
    hourly_sales_trend,
    merge_sales_and_products,
    normalize_sales_columns,
    product_sales_ranking_with_brand,
    revenue_concentration,
    seasonal_sales_pattern,
    transform_products_data,
    transform_sales_data,
)
from include.s3_utils import get_storage_options
from include.validations.validate_inputs import validate_input_products_schema, validate_input_sales_schema
from include.validations.validate_outputs import (
    validate_output_enrich_schema,
    validate_output_products_schema,
    validate_output_sales_clean_schema,
    validate_output_sales_schema,
)

with open("include/config.yaml") as file:
    config = yaml.safe_load(file)

AWS_CONN_ID = config["aws_conn_id"]
BUCKET = config["s3"]["bucket"]


def s3_path(folder_key: str, file_name: str) -> str:
    return f"s3://{BUCKET}/{config['s3'][folder_key]}{file_name}"


def storage_options() -> dict:
    _, options = get_storage_options(AWS_CONN_ID)
    return options


@task_group(group_id="extract_group")
def extract_group():
    @task()
    def extract_csv_files() -> list:
        return extract_data_from_s3(BUCKET, config["s3"]["folder"], AWS_CONN_ID, "csv")

    @task()
    def extract_json_files() -> list:
        return extract_data_from_s3(BUCKET, config["s3"]["folder"], AWS_CONN_ID, "json")

    @task()
    def get_sales_path(paths: list) -> str:
        for path in paths:
            if "sales" in path.lower():
                return path
        raise AirflowException("Sales file not found")

    @task()
    def get_products_path(paths: list) -> str:
        for path in paths:
            if "product" in path.lower():
                return path
        raise AirflowException("Products file not found")

    return {
        "sales_path": get_sales_path(extract_csv_files()),
        "products_path": get_products_path(extract_json_files()),
    }


@task_group(group_id="validate_inputs_group")
def validate_inputs_group(sales_path: str, products_path: str):
    @task()
    def validate_sales_input(sales_path: str) -> str:
        df = pd.read_csv(sales_path, storage_options=storage_options())
        validate_input_sales_schema(normalize_sales_columns(df))
        return sales_path

    @task()
    def validate_products_input(products_path: str) -> str:
        df = pd.read_json(products_path, storage_options=storage_options())
        validate_input_products_schema(df)
        return products_path

    return {
        "sales_path": validate_sales_input(sales_path),
        "products_path": validate_products_input(products_path),
    }


@task_group(group_id="transform_group")
def transform_group(sales_path: str, products_path: str):
    @task()
    def transform_sales(sales_path: str) -> str:
        df = transform_sales_data(pd.read_csv(sales_path, storage_options=storage_options()))
        output_path = s3_path("staging_folder", "cleaned_sales.parquet")
        load_df_to_s3_parquet(df, output_path, AWS_CONN_ID)
        return output_path

    @task()
    def transform_products(products_path: str) -> str:
        df = transform_products_data(pd.read_json(products_path, storage_options=storage_options()))
        output_path = s3_path("staging_folder", "cleaned_products.parquet")
        load_df_to_s3_parquet(df, output_path, AWS_CONN_ID)
        return output_path

    @task()
    def merge_sales_products(sales_path: str, products_path: str) -> str:
        sales_df = read_parquet_from_s3(sales_path, AWS_CONN_ID)
        products_df = read_parquet_from_s3(products_path, AWS_CONN_ID)
        output_path = s3_path("staging_folder", "sales_clean.parquet")
        load_df_to_s3_parquet(merge_sales_and_products(sales_df, products_df), output_path, AWS_CONN_ID)
        return output_path

    @task()
    def enrich_sales(sales_clean_path: str) -> str:
        df = enrich_merged_data(read_parquet_from_s3(sales_clean_path, AWS_CONN_ID))
        output_path = s3_path("staging_folder", "enriched.parquet")
        load_df_to_s3_parquet(df, output_path, AWS_CONN_ID)
        return output_path

    cleaned_sales = transform_sales(sales_path)
    cleaned_products = transform_products(products_path)
    sales_clean = merge_sales_products(cleaned_sales, cleaned_products)
    enriched = enrich_sales(sales_clean)

    return {
        "cleaned_sales": cleaned_sales,
        "cleaned_products": cleaned_products,
        "sales_clean": sales_clean,
        "enriched": enriched,
    }


@task_group(group_id="validate_outputs_group")
def validate_outputs_group(cleaned_sales: str, cleaned_products: str, sales_clean: str, enriched: str):
    @task()
    def validate_sales_output(path: str) -> str:
        validate_output_sales_schema(read_parquet_from_s3(path, AWS_CONN_ID))
        return path

    @task()
    def validate_products_output(path: str) -> str:
        validate_output_products_schema(read_parquet_from_s3(path, AWS_CONN_ID))
        return path

    @task()
    def validate_sales_clean_output(path: str) -> str:
        validate_output_sales_clean_schema(read_parquet_from_s3(path, AWS_CONN_ID))
        return path

    @task()
    def validate_enriched_output(path: str) -> str:
        validate_output_enrich_schema(read_parquet_from_s3(path, AWS_CONN_ID))
        return path

    return {
        "cleaned_sales": validate_sales_output(cleaned_sales),
        "cleaned_products": validate_products_output(cleaned_products),
        "sales_clean": validate_sales_clean_output(sales_clean),
        "enriched": validate_enriched_output(enriched),
    }


@task_group(group_id="save_to_s3_group")
def save_to_s3_group(cleaned_sales: str, cleaned_products: str, sales_clean: str, enriched: str):
    @task()
    def save_as_csv(staging_path: str, file_name: str) -> str:
        output_path = s3_path("output_folder", file_name)
        load_df_to_s3_csv(read_parquet_from_s3(staging_path, AWS_CONN_ID), output_path, AWS_CONN_ID)
        return output_path

    return {
        "cleaned_sales": save_as_csv.override(task_id="save_cleaned_sales")(cleaned_sales, "cleaned_sales.csv"),
        "cleaned_products": save_as_csv.override(task_id="save_cleaned_products")(cleaned_products, "cleaned_products.csv"),
        "sales_clean": save_as_csv.override(task_id="save_sales_clean")(sales_clean, "sales_clean.csv"),
        "enriched": save_as_csv.override(task_id="save_enriched")(enriched, "enriched.csv"),
    }


@task_group(group_id="analytics_group")
def analytics_group(enriched_path: str):
    @task()
    def run_hourly_sales_trend(enriched_path: str) -> str:
        result = hourly_sales_trend(pd.read_csv(enriched_path, storage_options=storage_options()))
        output_path = s3_path("analytics", "hourly_sales_trend.csv")
        load_df_to_s3_csv(result, output_path, AWS_CONN_ID)
        return output_path

    @task()
    def run_product_sales_ranking_with_brand(enriched_path: str) -> str:
        result = product_sales_ranking_with_brand(pd.read_csv(enriched_path, storage_options=storage_options()))
        output_path = s3_path("analytics", "product_sales_ranking.csv")
        load_df_to_s3_csv(result, output_path, AWS_CONN_ID)
        return output_path

    @task()
    def run_seasonal_sales_pattern(enriched_path: str) -> str:
        result = seasonal_sales_pattern(pd.read_csv(enriched_path, storage_options=storage_options()))
        output_path = s3_path("analytics", "seasonal_sales_pattern.csv")
        load_df_to_s3_csv(result, output_path, AWS_CONN_ID)
        return output_path

    @task()
    def run_revenue_concentration(enriched_path: str) -> str:
        result = revenue_concentration(pd.read_csv(enriched_path, storage_options=storage_options()))
        output_path = s3_path("analytics", "revenue_concentration.csv")
        load_df_to_s3_csv(result, output_path, AWS_CONN_ID)
        return output_path

    run_hourly_sales_trend(enriched_path)
    run_product_sales_ranking_with_brand(enriched_path)
    run_seasonal_sales_pattern(enriched_path)
    run_revenue_concentration(enriched_path)


def build_retail_pipeline():
    raw = extract_group()
    validated_raw = validate_inputs_group(raw["sales_path"], raw["products_path"])
    staged = transform_group(validated_raw["sales_path"], validated_raw["products_path"])
    validated = validate_outputs_group(
        staged["cleaned_sales"], staged["cleaned_products"], staged["sales_clean"], staged["enriched"]
    )
    saved = save_to_s3_group(
        validated["cleaned_sales"], validated["cleaned_products"], validated["sales_clean"], validated["enriched"]
    )
    analytics_group(saved["enriched"])


# @task_group(group_id="load_group")
# def load_group(hourly_trend: str, product_ranking: str, seasonal_patterns: str, revenue_concentration: str):
#     @task()
#     def copy_csv(input_path: str, output_file: str):
#         df = pd.read_csv(input_path, storage_options=storage_options)
#
#         bucket = config["s3"]["bucket"]
#         folder = config["s3"]["output_folder"]
#
#         output_path = f"s3://{bucket}/{folder}{output_file}"
#         load_df_to_s3_csv(df, output_path, config["aws_conn_id"])
#         return output_path
#
#     copy_csv.override(task_id="load_hourly_trend")(hourly_trend, output_file="hourly_trend.csv")
#     copy_csv.override(task_id="load_product_sales_ranking")(product_ranking, output_file="product_sales_ranking.csv")
#     copy_csv.override(task_id="load_seasonal_patterns")(seasonal_patterns, output_file="seasonal_patterns.csv")
#     copy_csv.override(task_id="load_revenue_concentration")(revenue_concentration, output_file="revenue_concentration.csv")
#
#
#
# def build_retail_pipeline():
#     extract_output = extract_group()
#     sales_path = extract_output["sales_path"]
#     product_path = extract_output["products_path"]
#
#     transform_output = transform_group(sales_path, product_path)
#     enriched_path = transform_output["enriched"]
#
#     analytics_output = analytics_group(enriched_path)
#
#     load_group(
#         hourly_trend=analytics_output["hourly_trend"],
#         product_ranking=analytics_output["product_ranking"],
#         seasonal_patterns = analytics_output["seasonal_patterns"],
#         revenue_concentration=analytics_output["revenue_concentration"]
#     )

