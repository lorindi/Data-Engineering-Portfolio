import pandas as pd
import pandera.pandas as pa

from pandera.pandas import Column, Check
from pandera.errors import SchemaErrors

product_sales_ranking_schema = pa.DataFrameSchema({
    "product_id": Column(int, unique=True),
    "category": Column(str),
    "brand": Column(str),
    "rating": Column(float),
    "revenue": Column(float, Check.ge(0)),
    "sales_count": Column(int, Check.gt(0)),
    "value_bucket": Column(str, Check.isin(["Low Performance", "Average", "BestSeller"])),
})


def validate_output_product_sales_ranking_schema(df: pd.DataFrame) -> pd.DataFrame:
    try:
        return product_sales_ranking_schema.validate(df, lazy=True)
    except SchemaErrors as e:
        print(f"Product sales ranking validation failed:\n{e.failure_cases}")
        raise