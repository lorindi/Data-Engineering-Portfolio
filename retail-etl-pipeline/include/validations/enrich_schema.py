import pandas as pd
import pandera.pandas as pa

from pandera.pandas import Column, Check
from pandera.errors import SchemaErrors

enrich_output_schema = pa.DataFrameSchema({
    # from sales
    "sales_id": Column(int, unique=True),
    "product_id": Column(int),
    "region": Column(str),
    "quantity": Column(int, Check.gt(0)),
    "price": Column(float, Check.gt(0)),
    "discount": Column(float, Check.in_range(0, 1)),
    "order_status": Column(str),
    "timestamp": Column(pa.DateTime),
    "revenue": Column(float, Check.ge(0)),

    # from products (after merge)
    "category": Column(str),
    "brand": Column(str),
    "rating": Column(float),
    "in_stock": Column(bool),
    "launch_date": Column(pa.DateTime, nullable=True),

    # enriched columns
    "month": Column(str, Check.str_matches(r"^\d{4}-\d{2}$")),
    "week": Column(int, Check.in_range(1, 53)),
    "weekday": Column(str),
    "hour": Column(int, Check.in_range(0, 23)),
    "sales_bucket": Column(str, Check.isin(["Low", "Medium", "High"])),
})


def validate_output_enrich_schema(merged_df: pd.DataFrame) -> pd.DataFrame:
    try:
        return enrich_output_schema.validate(merged_df, lazy=True)
    except SchemaErrors as e:
        print(f"Enriched data validation failed:\n{e.failure_cases}")
        raise


sales_clean_schema = enrich_output_schema.remove_columns(["month", "week", "weekday", "hour", "sales_bucket"])


def validate_output_sales_clean_schema(sales_clean_df: pd.DataFrame) -> pd.DataFrame:
    try:
        return sales_clean_schema.validate(sales_clean_df, lazy=True)
    except SchemaErrors as e:
        print(f"Sales clean validation failed:\n{e.failure_cases}")
        raise
