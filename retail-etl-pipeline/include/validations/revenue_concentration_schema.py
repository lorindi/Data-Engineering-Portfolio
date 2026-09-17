import pandas as pd
import pandera.pandas as pa

from pandera.pandas import Column, Check
from pandera.errors import SchemaErrors

revenue_concentration_schema = pa.DataFrameSchema({
    "region": Column(str, Check.str_length(min_value=1), unique=True),
    "region_revenue": Column(float, Check.ge(0)),
    "revenue_share": Column(float, Check.in_range(0, 1)),
    "cumulative_share": Column(float, Check.in_range(0, 1.000001)),
})


def validate_output_revenue_concentration_schema(df: pd.DataFrame) -> pd.DataFrame:
    try:
        return revenue_concentration_schema.validate(df, lazy=True)
    except SchemaErrors as e:
        print(f"Revenue concentration validation failed:\n{e.failure_cases}")
        raise