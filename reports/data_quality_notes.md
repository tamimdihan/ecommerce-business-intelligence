# Data Cleaning Decision Log

## Project

**E-commerce Business Intelligence Analysis**

## Dataset

**UCI Online Retail Dataset**

## Purpose

The raw dataset will remain unchanged. All cleaning and transformation decisions will be applied to a separate analytical dataset.

The objective is to create a reliable dataset for sales, customer, product, and business analysis while preserving unusual or operational records when they contain useful business information.

---

## 1. Duplicate Rows

### Problem

The dataset contains exact duplicate rows.

### Evidence

* `df.duplicated().sum()` = **5,268**
* **10,147 rows** belong to groups containing duplicates when using `keep=False`.
* Exact duplicates contain the same recorded values across the available columns.
* Where similar transaction/product records differ, the difference may be in `Quantity`.

### Business Meaning

Exact duplicates may represent accidental repeated records in the source data. However, repeated `InvoiceNo` values alone are not considered duplicates because one invoice can contain multiple product line items.

### Decision

**Remove exact duplicate rows from the analytical dataset.**

Do not remove rows simply because `InvoiceNo` or `StockCode` appears more than once.

### Reason

An exact duplicate contains no additional information and could inflate sales, quantity, and transaction-level metrics.

---

## 2. Cancellation Transactions

### Problem

Some transactions have negative quantities and invoice numbers beginning with `C`.

### Evidence

* **9,288** rows have `InvoiceNo` beginning with `C`.
* All observed `C` invoice rows have negative quantities.
* Cancellation records contain both identified and missing `CustomerID` values.

### Business Meaning

The `C` prefix provides a consistent indicator of cancellation transactions in this dataset.

### Decision

**Retain cancellation transactions in the analytical dataset and create an `Is_Cancellation` flag.**

### Reason

Cancellations are meaningful for business analysis. Removing them would prevent analysis of cancellation behavior and could distort net sales calculations.

They should, however, be separated from normal positive sales when calculating gross sales, net sales, cancellation rates, and related metrics.

---

## 3. Negative Quantity Without Cancellation Prefix

### Problem

Some negative-quantity records do not have an invoice number beginning with `C`.

### Evidence

* **1,336** rows have negative quantities but do not have the `C` prefix.
* All 1,336 records have:

  * `UnitPrice = 0`
  * missing `CustomerID`
* Descriptions frequently contain operational terms such as:

  * `check`
  * `damages`
  * `damaged`
  * `thrown away`
  * `Unsaleable, destroyed.`
  * `wet damaged`
  * `smashed`
  * `missing`
  * `rusty throw away`

### Business Meaning

These records appear to represent internal inventory adjustments, damaged goods, disposal, or operational corrections rather than normal customer sales.

### Decision

**Retain the records but classify them separately as internal adjustments.**

Create an appropriate flag such as `Is_Inventory_Adjustment`.

Exclude these records from normal customer sales/revenue analysis.

### Reason

Deleting them would destroy potentially useful operational information. Including them in sales analysis would incorrectly treat inventory adjustments as customer transactions.

---

## 4. Zero Unit Price

### Problem

Some records have `UnitPrice = 0`.

### Evidence

* **2,517** rows have zero UnitPrice.
* None of these rows are cancellation invoices.
* Descriptions frequently include operational terms such as:

  * `check`
  * `damages`
  * `damaged`
  * `adjustment`
  * `found`
  * `thrown away`
  * `Unsaleable, destroyed.`
  * `Manual`
  * `amazon`
  * `sold as set on dotcom`

### Business Meaning

Zero-price records do not necessarily represent incorrect prices. Many appear to represent internal or special operational transactions.

### Decision

**Do not automatically delete zero-price records.**

Retain them in the cleaned dataset and exclude them from normal revenue calculations where appropriate.

### Reason

A zero price may represent a legitimate operational record rather than missing or corrupted pricing.

---

## 5. Missing CustomerID

### Problem

A significant number of records have missing CustomerID values.

### Evidence

* **135,080** rows have missing CustomerID.
* **406,829** rows have a known CustomerID.
* Missing CustomerID records are heavily concentrated in the United Kingdom.
* Only **383** missing-CustomerID rows are cancellation transactions.

### Business Meaning

The absence of CustomerID appears to indicate that customer identity was not recorded for those transactions. It does not mean the transaction itself is invalid.

### Decision

**Do not delete rows with missing CustomerID.**

Keep the records for transaction, product, country, and sales analysis.

Exclude missing CustomerID records only from analyses that specifically require customer-level identification, such as customer retention or RFM segmentation.

### Reason

Deleting these rows would remove a substantial portion of valid transaction information and could bias sales analysis.

---

## 6. Invoice Number Repetition

### Problem

InvoiceNo values occur across multiple rows.

### Evidence

The dataset contains multiple product records under the same invoice number.

### Business Meaning

An invoice can contain multiple line items. Therefore, repeated InvoiceNo values are expected.

### Decision

**Do not treat repeated InvoiceNo values as duplicates.**

Use unique InvoiceNo counts when measuring the number of invoices.

### Reason

Removing repeated InvoiceNo values would incorrectly eliminate legitimate product line items.

---

## 7. Extreme Quantity Values

### Problem

Quantity contains unusually large positive and negative values.

### Evidence

* Minimum Quantity = **-80,995**
* Maximum Quantity = **80,995**
* The extreme positive and negative records involve the same product and customer and occur very close together in time.

### Business Meaning

The extreme values may represent a large transaction and its corresponding cancellation/adjustment rather than simple data-entry errors.

### Decision

**Do not remove extreme quantities based solely on their magnitude.**

Investigate and classify them according to transaction type before analysis.

### Reason

Outliers may represent real business events. Automatically removing them could eliminate meaningful transactions.

---

## 8. Negative UnitPrice Values

### Problem

The dataset contains negative UnitPrice values.

### Evidence

Initial audit identified records where UnitPrice is less than or equal to zero.

### Business Meaning

Negative prices may represent discounts, adjustments, corrections, or other special transactions rather than ordinary product prices.

### Decision

**Do not automatically replace or delete negative UnitPrice values.**

Investigate their descriptions, invoice types, and transaction context before determining their treatment.

### Reason

Changing these values without understanding their business meaning could create artificial revenue or pricing data.

---

# Current Cleaning Principles

The following principles will guide the cleaning process:

1. **Never modify the raw dataset.**
2. **Do not delete unusual records simply because they look strange.**
3. **Separate transaction types before calculating business metrics.**
4. **Do not confuse repeated InvoiceNo values with duplicate rows.**
5. **Preserve operational information when it may have business meaning.**
6. **Use evidence from the dataset to justify every transformation.**
7. **Document every cleaning decision so the analysis is reproducible.**
8. **Keep customer-level analysis separate from transaction-level analysis when CustomerID is missing.**

---

# Next Step

After this decision log is finalized, the next stage is to implement the decisions programmatically and create a separate processed dataset.

The raw file will remain untouched:

`data/raw/Online Retail.xlsx`

The cleaned analytical dataset will be saved separately under:

`data/processed/`








------------Disclaimer /// This report has been refined using AI.-------------