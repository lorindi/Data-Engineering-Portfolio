import pandas as pd

from include.validations.hourly_revenue_schema import validate_output_hourly_revenue
from include.validations.product_sales_schema import validate_output_product_sales_ranking_schema
from include.validations.revenue_concentration_schema import validate_output_revenue_concentration_schema
from include.validations.seasonal_sales_pattern_schema import validate_output_seasonal_sales_pattern_schema


def normalize_sales_columns(sales_df: pd.DataFrame) -> pd.DataFrame:
    sales_df = sales_df.copy()
    sales_df.columns = sales_df.columns.str.strip().str.lower().str.replace(" ", "_")
    return sales_df.rename(columns={"qty": "quantity", "time_stamp": "timestamp"})


def transform_sales_data(sales_df: pd.DataFrame) -> pd.DataFrame:
    sales_df = normalize_sales_columns(sales_df)

    rows_before = len(sales_df)
    sales_df["region"] = sales_df["region"].str.strip().str.lower().fillna("unknown")
    sales_df["timestamp"] = pd.to_datetime(sales_df["timestamp"], format="%d-%m-%y %H:%M", errors="coerce")
    sales_df = sales_df[sales_df["timestamp"].notna() & (sales_df["price"] > 0) & (sales_df["quantity"] > 0)].copy()
    print(f"Rejected {rows_before - len(sales_df)} invalid sales rows, kept {len(sales_df)}")

    sales_df["revenue"] = (sales_df["quantity"] * sales_df["price"] * (1 - sales_df["discount"])).round(2)
    sales_df.loc[sales_df["order_status"] == "Returned", "revenue"] = 0.0
    return sales_df


def transform_products_data(products_df: pd.DataFrame) -> pd.DataFrame:
    products_df = products_df.copy()
    products_df.columns = products_df.columns.str.strip().str.lower().str.replace(" ", "_")
    products_df["brand"] = products_df["brand"].str.strip().str.upper()
    products_df["category"] = products_df["category"].str.strip().str.lower()
    products_df["launch_date"] = pd.to_datetime(products_df["launch_date"], format="%Y-%m-%d", errors="coerce")
    products_df = products_df.dropna(subset=["product_id", "rating"])
    return products_df.drop_duplicates()


def merge_sales_and_products(sales_df: pd.DataFrame, products_df: pd.DataFrame) -> pd.DataFrame:
    return sales_df.merge(products_df, how="inner", on="product_id")


def enrich_merged_data(merged_df: pd.DataFrame) -> pd.DataFrame:
    merged_df = merged_df.copy()
    merged_df["month"] = merged_df["timestamp"].dt.to_period("M").astype(str)
    merged_df["week"] = merged_df["timestamp"].dt.isocalendar().week.astype("int64")
    merged_df["weekday"] = merged_df["timestamp"].dt.day_name()
    merged_df["hour"] = merged_df["timestamp"].dt.hour.astype("int64")
    merged_df["sales_bucket"] = pd.cut(
        merged_df["revenue"],
        bins=[0, 200, 800, float("inf")],
        labels=["Low", "Medium", "High"],
        include_lowest=True,
    ).astype(str)
    return merged_df


def hourly_sales_trend(enriched_df: pd.DataFrame) -> pd.DataFrame:
    agg = enriched_df.groupby(["region", "category", "hour"], as_index=False).agg(
        hourly_revenue=("revenue", "sum")
    )
    agg["hourly_revenue"] = agg["hourly_revenue"].round(2)

    idx = agg.groupby(["region", "category"])["hourly_revenue"].idxmax()
    peaks = agg.loc[idx].reset_index(drop=True)

    return validate_output_hourly_revenue(peaks)


def product_sales_ranking_with_brand(enriched_df: pd.DataFrame) -> pd.DataFrame:
    summary = enriched_df.groupby(["product_id", "category", "brand", "rating"], as_index=False).agg(
        revenue=("revenue", "sum"),
        sales_count=("product_id", "size"),
    )
    summary["revenue"] = summary["revenue"].round(2)

    # Percentile ranks (0-1) so revenue and sales count are on the same scale.
    revenue_rank = summary["revenue"].rank(method="average", pct=True)
    sales_count_rank = summary["sales_count"].rank(method="average", pct=True)
    performance_score = revenue_rank * 0.50 + sales_count_rank * 0.50

    summary["value_bucket"] = pd.cut(
        performance_score,
        bins=[0, 0.20, 0.80, 1],
        labels=["Low Performance", "Average", "BestSeller"],
        include_lowest=True,
    ).astype(str)

    return validate_output_product_sales_ranking_schema(summary)


def seasonal_sales_pattern(enriched_df: pd.DataFrame) -> pd.DataFrame:
    seasonal_df = enriched_df.copy()
    seasonal_df["timestamp"] = pd.to_datetime(seasonal_df["timestamp"], format="mixed", errors="coerce")
    seasonal_df["quarter"] = seasonal_df["timestamp"].dt.to_period("Q").astype(str)

    seasonal_patterns = seasonal_df.groupby(["quarter", "category"], as_index=False).agg(
        revenue=("revenue", "sum"),
    )
    seasonal_patterns["revenue"] = seasonal_patterns["revenue"].round(2)

    return validate_output_seasonal_sales_pattern_schema(seasonal_patterns)


def revenue_concentration(enriched_df: pd.DataFrame) -> pd.DataFrame:
    summary = enriched_df.groupby(["region"], as_index=False).agg(
        region_revenue=("revenue", "sum"),
    )
    summary["region_revenue"] = summary["region_revenue"].round(2)
    summary = summary.sort_values(by="region_revenue", ascending=False).reset_index(drop=True)

    total = summary["region_revenue"].sum()
    if total == 0:
        raise ValueError("Total revenue is 0")

    summary["revenue_share"] = summary["region_revenue"] / total
    summary["cumulative_share"] = summary["revenue_share"].cumsum().round(4)
    summary["revenue_share"] = summary["revenue_share"].round(4)

    return validate_output_revenue_concentration_schema(summary)
