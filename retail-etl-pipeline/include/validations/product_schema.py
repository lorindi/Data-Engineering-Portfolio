import pandas as pd
import pandera.pandas as pa

from pandera.pandas import Column, Check
from pandera.errors import SchemaError

product_input_schema = pa.DataFrameSchema({
    "product_id": Column(int, unique=True),
    "category": Column(str),
    "brand": Column(str),
    "rating": Column(float),
    "in_stock": Column(bool),
    "launch_date": Column(str, nullable=True),
})


product_output_schema = pa.DataFrameSchema({
    "product_id": Column(int, unique=True),
    "category": Column(str, Check(lambda s: s.str.islower())),
    "brand": Column(str, Check(lambda s: s.str.isupper())),
    "rating": Column(float),
    "in_stock": Column(bool),
    "launch_date": Column(pa.DateTime, nullable=True),
})


def validate_input_products_schema(products_df: pd.DataFrame) -> pd.DataFrame:
    try:
        return product_input_schema.validate(products_df)
    except SchemaError as e:
        print(f"Pre-products schema error: {e}")
        return products_df


def validate_output_products_schema(products_df: pd.DataFrame) -> pd.DataFrame:
    try:
        return product_output_schema.validate(products_df)
    except SchemaError as e:
        print(f"Post-products schema error: {e}")
        raise