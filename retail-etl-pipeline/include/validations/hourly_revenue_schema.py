import pandas as pd
import pandera.pandas as pa
from pandera.pandas import Column, Check
from pandera.errors import SchemaError

hourly_revenue_schema = pa.DataFrameSchema({
    "region": Column(str, nullable=True),
    "category": Column(str),
    "hour": Column(int, Check.in_range(0, 23), nullable=True),
    "hourly_revenue": Column(float, Check.greater_than_or_equal_to(0)),
})


def validate_output_hourly_revenue(df: pd.DataFrame) -> pd.DataFrame:
    try:
        return hourly_revenue_schema.validate(df)
    except SchemaError as e:
        print(f"Post-hourly revenue schema error: {e}")
        raise