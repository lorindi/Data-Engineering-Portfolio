import pandas as pd
import pandera.pandas as pa

from pandera.pandas import Column, Check
from pandera.errors import SchemaErrors

VALID_ORDER_STATUSES = ["Shipped", "Completed", "Pending", "Returned"]

sales_input_schema = pa.DataFrameSchema({
    "sales_id": Column(int, unique=True),
    "product_id": Column(int),
    "region": Column(str, nullable=True),
    "quantity": Column(int, Check.gt(0)),
    "price": Column(float, Check.gt(0)),
    "timestamp": Column(str),
    "discount": Column(float, Check.in_range(0, 1)),
    "order_status": Column(str, Check.isin(VALID_ORDER_STATUSES)),
})

sales_output_schema = pa.DataFrameSchema({
    "sales_id": Column(int, unique=True),
    "product_id": Column(int),
    "region": Column(str),
    "quantity": Column(int, Check.gt(0)),
    "price": Column(float, Check.gt(0)),
    "timestamp": Column(pa.DateTime),
    "discount": Column(float, Check.in_range(0, 1)),
    "order_status": Column(str, Check.isin(VALID_ORDER_STATUSES)),
    "revenue": Column(float, Check.ge(0)),
})


def validate_input_sales_schema(sales_df: pd.DataFrame) -> pd.DataFrame:
    try:
        return sales_input_schema.validate(sales_df, lazy=True)
    except SchemaErrors as e:
        summary = e.failure_cases.groupby(["column", "check"]).size()
        print(f"Input validation found {len(e.failure_cases)} invalid values:\n{summary}")
        return sales_df


# Fails the task if the cleaned data is still invalid.
def validate_output_sales_schema(sales_df: pd.DataFrame) -> pd.DataFrame:
    try:
        return sales_output_schema.validate(sales_df, lazy=True)
    except SchemaErrors as e:
        print(f"Output validation failed:\n{e.failure_cases}")
        raise