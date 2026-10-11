"""
Reproducible cleaning pipeline for the UCI Online Retail dataset.

Run from any working directory:
    python src/data_cleaning.py

Expected project structure:
    data/raw/Online Retail.xlsx
    data/processed/online_retail_clean.csv
"""

from pathlib import Path
import pandas as pd


PROJECT_ROOT = Path(__file__).resolve().parents[1]
INPUT_PATH = PROJECT_ROOT / "data" / "raw" / "Online Retail.xlsx"
OUTPUT_PATH = PROJECT_ROOT / "data" / "processed" / "online_retail_clean.csv"

EXPECTED_COLUMNS = [
    "invoice_no",
    "stock_code",
    "description",
    "quantity",
    "invoice_date",
    "unit_price",
    "customer_id",
    "country",
    "transaction_type",
    "revenue",
    "sales_revenue",
]
VALID_TRANSACTION_TYPES = {
    "SALE",
    "CANCELLATION",
    "INVENTORY_ADJUSTMENT",
    "BAD_DEBT_ADJUSTMENT",
}


def clean_online_retail(input_path: Path = INPUT_PATH) -> pd.DataFrame:
    """Load, clean, classify, and enrich the raw Online Retail dataset."""
    if not input_path.exists():
        raise FileNotFoundError(
            f"Raw dataset not found: {input_path}\n"
            "Make sure Online Retail.xlsx is saved in data/raw/."
        )

    df = pd.read_excel(input_path)
    rows_before = len(df)

    # Match the notebook: remove exact duplicate rows only.
    df = df.drop_duplicates().copy()
    rows_removed = rows_before - len(df)

    # Standardize the original column names, then apply the notebook's schema.
    df.columns = (
        df.columns.astype(str)
        .str.strip()
        .str.lower()
        .str.replace(" ", "_", regex=False)
    )

    original_columns = [
        "invoice_no",
        "stock_code",
        "description",
        "quantity",
        "invoice_date",
        "unit_price",
        "customer_id",
        "country",
    ]
    if list(df.columns) != original_columns:
        raise ValueError(
            "The raw dataset columns do not match the expected Online Retail "
            f"schema. Found: {list(df.columns)}"
        )

    # Nullable integer preserves missing customer IDs without converting IDs
    # into decimal-looking values.
    df["customer_id"] = df["customer_id"].astype("Int64")

    # Keep the transaction classification order used in the notebook.
    df["transaction_type"] = "SALE"

    df.loc[
        df["unit_price"] < 0,
        "transaction_type"
    ] = "BAD_DEBT_ADJUSTMENT"

    df.loc[
        (df["quantity"] < 0)
        & (~df["invoice_no"].astype(str).str.startswith("C")),
        "transaction_type"
    ] = "INVENTORY_ADJUSTMENT"

    df.loc[
        df["invoice_no"].astype(str).str.startswith("C"),
        "transaction_type"
    ] = "CANCELLATION"

    # Calculate transaction value and sales-only revenue, matching the notebook.
    df["revenue"] = df["quantity"] * df["unit_price"]
    df["sales_revenue"] = df["revenue"].where(
        df["transaction_type"] == "SALE",
        0,
    )

    # Validate the resulting dataset before exporting it.
    if df.duplicated().any():
        raise ValueError("Validation failed: duplicate rows remain.")

    if df["transaction_type"].isna().any():
        raise ValueError("Validation failed: transaction_type contains nulls.")

    unexpected_types = set(df["transaction_type"].unique()) - VALID_TRANSACTION_TYPES
    if unexpected_types:
        raise ValueError(
            f"Validation failed: unexpected transaction types: {unexpected_types}"
        )

    if df["invoice_date"].isna().any():
        raise ValueError("Validation failed: invoice_date contains missing values.")

    if not (df["sales_revenue"][
        df["transaction_type"] != "SALE"
    ] == 0).all():
        raise ValueError(
            "Validation failed: non-SALE rows have non-zero sales_revenue."
        )

    if list(df.columns) != EXPECTED_COLUMNS:
        raise ValueError(
            "Validation failed: output columns differ from the expected schema. "
            f"Found: {list(df.columns)}"
        )

    # Export in the project-standard location.
    OUTPUT_PATH.parent.mkdir(parents=True, exist_ok=True)
    df.to_csv(OUTPUT_PATH, index=False)

    print("CLEANING COMPLETE")
    print(f"Input file:              {input_path}")
    print(f"Output file:             {OUTPUT_PATH}")
    print(f"Rows before cleaning:    {rows_before:,}")
    print(f"Exact duplicates removed:{rows_removed:>8,}")
    print(f"Rows after cleaning:     {len(df):,}")
    print(f"Columns:                 {len(df.columns)}")
    print(f"Remaining duplicates:    {df.duplicated().sum():,}")
    print("\nTransaction types:")
    print(df["transaction_type"].value_counts().to_string())
    print("\nRevenue checks:")
    print(f"Total transaction value: {df['revenue'].sum():,.3f}")
    print(f"Total sales revenue:     {df['sales_revenue'].sum():,.3f}")
    print("\nMissing values:")
    print(df.isna().sum().to_string())

    return df


if __name__ == "__main__":
    clean_online_retail()
