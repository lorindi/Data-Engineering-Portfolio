from airflow.exceptions import AirflowException

from include.s3_utils import get_storage_options


# Lists files of a given type in an S3 folder and returns their full s3:// paths.
def extract_data_from_s3(bucket: str, folder: str, aws_conn_id: str, file_type: str = "csv") -> list:
    print(f"Listing .{file_type} files in s3://{bucket}/{folder}")

    s3_hook, _ = get_storage_options(aws_conn_id=aws_conn_id)
    keys = s3_hook.list_keys(bucket_name=bucket, prefix=folder)

    if not keys:
        raise AirflowException(f"No files found in s3://{bucket}/{folder}")

    matched_paths = [f"s3://{bucket}/{key}" for key in keys if key.lower().endswith(f".{file_type}")]

    if not matched_paths:
        raise AirflowException(f"No .{file_type} files in s3://{bucket}/{folder}")

    return matched_paths
