# E-Commerce Business Intelligence Report

## Executive Summary

This analysis evaluates sales performance, customer behavior, product performance, and business risks for a UK-based online retailer using transaction data from December 2010 to December 2011.

After data cleaning and validation, the analysis covered 536,641 transaction records. Total sales revenue from normal sales transactions was £10.64M across 20,726 orders, 3,812 products with positive-price sales, and 5.65M units sold.

The business is highly concentrated in the UK, which generated 84.59% of total sales revenue. Customer revenue is also concentrated: the top 10% of identifiable customers generated 61.41% of identifiable customer revenue.

Customer behavior analysis showed that 65.57% of identifiable customers were repeat customers. RFM segmentation identified 337 high-value customers as At-Risk, while 1,371 customers were classified as Inactive.

Product analysis revealed substantial differences between revenue and unit-volume leaders. Some products generate revenue through frequent purchases, while others are driven by unusually large transactions. One exceptional transaction contributed 80,995 units for a single product and should not be interpreted as normal recurring demand.

Cancellation-value transactions totaled £893.98K, equivalent to 8.40% of sales revenue. However, this figure includes operational and financial transactions and should not be interpreted as a customer return rate.

Overall, the analysis shows a business with strong repeat-customer contribution but significant dependence on the UK market and a concentrated group of high-value customers. These findings provide a basis for customer retention analysis, market diversification, and further investigation of unusual transaction patterns.






## 1. Business & Dataset Overview

The project uses the UCI Online Retail transaction dataset representing transactions from a UK-based online retailer.

### Analysis Period

December 2010 – December 2011

### Dataset

- Raw records: 541,909
- Cleaned records: 536,641
- Original columns: 8
- Final analytical columns: 11
- Countries represented: 38
- Identifiable customers in sales analysis: 4,339

### Business Questions

The analysis focused on:

- How much revenue did the business generate?
- How did sales change over time?
- Which countries generated the most revenue?
- Which products drove revenue and unit volume?
- How concentrated was customer revenue?
- How important were repeat customers?
- Which customers require attention based on RFM behavior?
- What transaction patterns and anomalies require investigation?





## 2. Data Quality & Methodology

The raw dataset contained several data-quality issues that required investigation before business analysis. Cleaning decisions were based on the observed data patterns and the business meaning of each transaction type rather than simply removing unusual records.

### Data Quality Findings

The raw dataset contained:

- 541,909 transaction records
- 5,268 exact duplicate rows
- 135,080 missing CustomerID values
- 10,624 negative-quantity records before duplicate removal
- 2,517 zero-price records before duplicate removal
- 2 negative UnitPrice records
- Missing product descriptions in a small number of records
- Extremely large positive and negative quantity values
- Cancellation transactions identified by invoice numbers beginning with `C`

### Cleaning Decisions

#### Exact Duplicates

5,268 exact duplicate rows were removed.

Repeated InvoiceNo values were retained because a single invoice can legitimately contain multiple product line items.

#### Cancellations

Transactions with invoice numbers beginning with `C` were classified as:

`CANCELLATION`

These records were retained because they provide information about negative transaction activity and cancellation value.

#### Inventory Adjustments

Negative-quantity transactions that did not have a cancellation invoice number were classified as:

`INVENTORY_ADJUSTMENT`

There were 1,336 such records. These transactions had zero unit prices, missing customer identifiers, and operational descriptions such as damaged, missing, adjustment, or unsaleable. They were therefore retained but excluded from normal sales-revenue analysis.

#### Zero-Price Transactions

Zero-price records were retained because they may represent operational or special transactions rather than data-entry errors.

They contribute zero revenue and were therefore excluded from customer revenue and behavioral analysis where a positive-price sale was required.

#### Missing Customer IDs

Transactions with missing CustomerID values were retained.

They remain useful for overall sales, product, country, and transaction analysis. However, they were excluded from customer-level analyses such as repeat-customer analysis and RFM segmentation because a customer cannot be reliably identified.

#### Negative Unit Prices

Two records contained negative unit prices. Both were identified as `Adjust bad debt` transactions.

They were classified as:

`BAD_DEBT_ADJUSTMENT`

and excluded from normal sales-revenue analysis while remaining in the cleaned dataset.

#### Extreme Quantities

Extremely large quantities were not automatically removed.

The largest quantity values were investigated and retained because unusual values may represent genuine bulk transactions or exceptional business events. One product contained an 80,995-unit transaction, which was treated as an exceptional transaction rather than normal recurring demand.

### Final Dataset

After removing exact duplicates, the cleaned dataset contained:

**536,641 records**

The final dataset includes additional analytical fields:

- `transaction_type`
- `revenue`
- `sales_revenue`

These fields allow normal sales, cancellations, inventory adjustments, and bad-debt adjustments to be analyzed separately.

### Analytical Approach

The project used a combination of:

- **SQL** for business-level aggregation and validation
- **Python/Pandas** for customer behavior and statistical analysis
- **RFM analysis** for customer segmentation
- **Power BI** for interactive business reporting

Revenue and customer metrics were calculated using appropriate transaction filters to avoid mixing normal sales with operational or financial adjustment records.




## 3. Key Business Findings

### 3.1 Strong Overall Sales Performance with Seasonal Variation

The business generated **£10.64M in sales revenue** across **20,726 orders** and sold approximately **5.65M units** during the analysis period.

Monthly revenue varied considerably. November 2011 recorded the highest full-month sales revenue at approximately **£1.50M**, while February 2011 recorded the lowest full-month revenue at approximately **£0.52M**.

Sales increased substantially during the second half of 2011, particularly from September through November.

**Business implication:** Revenue growth was not evenly distributed throughout the year, suggesting that seasonal demand and purchasing patterns should be considered when planning inventory, marketing, and operational capacity.

---

### 3.2 High Dependence on the UK Market

The UK generated approximately **£9.00M**, representing **84.59% of total sales revenue**.

The next largest markets were substantially smaller, including the Netherlands, EIRE, Germany, and France.

**Business implication:** The company's revenue base is heavily dependent on one geographic market. Changes in UK demand could therefore have a significant effect on overall business performance. International markets may provide opportunities for diversification, although their individual performance should be evaluated using customer, order, and profitability data before major investment decisions.

---

### 3.3 Repeat Customers Generate the Majority of Identifiable Customer Revenue

Among identifiable customers:

- **4,339 customers** were included in customer-level sales analysis.
- **2,845 customers (65.57%)** were repeat customers.
- Repeat customers generated approximately **£8.27M**, or **93.09% of identifiable customer revenue**.
- One-time customers generated approximately **£0.61M**, or **6.91%**.

The median customer placed **2 orders**, while the average was **4.27 orders**.

**Business implication:** Customer retention and repeat purchasing are closely associated with revenue generation in this dataset. Monitoring repeat-purchase behavior and maintaining relationships with existing customers should therefore be an important part of customer analysis.

---

### 3.4 Customer Revenue Is Highly Concentrated

Revenue was concentrated among a relatively small proportion of identifiable customers:

| Customer Group | Share of Identifiable Customer Revenue |
|---|---:|
| Top 1% | 31.84% |
| Top 5% | 50.39% |
| Top 10% | 61.41% |
| Top 20% | 74.66% |

The relationship between order frequency and customer revenue was positive, with a correlation of approximately **0.55**.

**Business implication:** A relatively small group of customers contributes a substantial share of identifiable revenue. Changes in the purchasing behavior of these customers could therefore materially affect revenue performance. This makes customer concentration an important monitoring metric.

---

### 3.5 Customer Risk Requires Monitoring

RFM segmentation identified several distinct customer groups:

| Segment | Customers | Revenue |
|---|---:|---:|
| High-Value Active | 957 | £5.79M |
| Loyal Repeat | 503 | £0.90M |
| High-Value At-Risk | 337 | £0.83M |
| Developing | 851 | £0.74M |
| Inactive | 1,371 | £0.49M |
| Recent / New | 319 | £0.15M |

The **337 High-Value At-Risk customers** generated approximately **£828.67K** in historical revenue.

The **1,371 Inactive customers** generated approximately **£487.71K** in historical revenue.

**Business implication:** The At-Risk group represents a customer segment that warrants further investigation because these customers previously generated substantial revenue but show weaker recent activity. The Inactive group is larger and may require a different reactivation approach.




## 4. Customer Analysis

Customer-level analysis was performed using identifiable customers with positive-price sales transactions. This produced a customer-level dataset of **4,338 customers** for RFM analysis.

### Customer Purchase Behavior

Customer purchasing behavior was highly uneven.

The median customer generated approximately **£668.57** in revenue and placed **2 orders**, compared with mean values of **£2,048.69** and **4.27 orders** respectively. The difference between the mean and median indicates that a relatively small group of customers contributes substantially higher revenue and order frequency.

Customer average order value also showed substantial variation. The median customer-level average order value was approximately **£291.94**, while several customers had exceptionally large average orders.

### Repeat vs One-Time Customers

Of the identifiable customers:

- **2,845 (65.57%)** were repeat customers.
- **1,493 (34.43%)** were one-time customers.

Repeat customers generated approximately **£8.27M**, representing **93.09% of identifiable customer revenue**.

The median average order value was also somewhat higher among repeat customers (**£302.56**) than one-time customers (**£255.91**). However, the difference in order value was much smaller than the difference in cumulative revenue contribution.

This indicates that the major distinction between the two groups is primarily **purchase frequency and cumulative customer value**, rather than a dramatic difference in individual order size.

### RFM Segmentation

Recency, frequency, and monetary value were used to segment customers based on their purchasing behavior.

The analysis identified:

- **High-Value Active:** 957 customers, £5.79M revenue
- **Loyal Repeat:** 503 customers, £0.90M revenue
- **High-Value At-Risk:** 337 customers, £0.83M revenue
- **Developing:** 851 customers, £0.74M revenue
- **Inactive:** 1,371 customers, £0.49M revenue
- **Recent / New:** 319 customers, £0.15M revenue

The High-Value Active segment represents the largest revenue contribution, while the High-Value At-Risk segment represents customers with substantial historical monetary value but weaker recent activity.

### Customer Revenue Concentration

Customer revenue concentration was also significant.

The top **1% of customers generated 31.84%** of identifiable customer revenue, while the top **10% generated 61.41%**.

The correlation between order frequency and total customer revenue was approximately **0.55**, indicating a moderate positive association. Customers who placed more orders generally generated more revenue, although frequency alone does not fully explain customer value.

### Customer Analysis Limitation

Customer-level analysis excludes transactions where CustomerID was unavailable. Therefore, customer revenue and RFM results represent **identifiable customers only** and should not be interpreted as a complete allocation of all company revenue across customers.





## 5. Product & Sales Analysis

Product-level analysis showed that revenue performance and sales volume are not distributed in the same way across products. Some products generated revenue through frequent recurring purchases, while others generated high revenue primarily through very large quantities.

### Product Revenue Performance

Among the leading merchandise products, several products generated substantial revenue:

- **REGENCY CAKESTAND 3 TIER:** £174,156.54 from 13,862 units across 1,989 invoices
- **PAPER CRAFT, LITTLE BIRDIE:** £168,469.60 from 80,995 units in 1 invoice
- **WHITE HANGING HEART T-LIGHT HOLDER:** £106,415.23 from 41,937 units across 2,270 invoices
- **PARTY BUNTING:** £99,445.23 from 18,287 units across 1,686 invoices
- **JUMBO BAG RED RETROSPOT:** £94,159.81 from 48,375 units across 2,092 invoices

These results show that product revenue can come from very different sales patterns. For example, REGENCY CAKESTAND 3 TIER generated substantial revenue through repeated purchases across many invoices, while other products generated large revenue through unusually high unit volumes.

### Recurring Demand vs Exceptional Transactions

One important finding was the presence of an exceptional transaction involving **PAPER CRAFT, LITTLE BIRDIE**, where **80,995 units** were recorded in a single invoice.

Because this transaction is substantially different from the normal purchasing pattern of the product, it should not automatically be treated as recurring customer demand. It should be validated against the original transaction records before being used for inventory or demand planning.

In contrast, products such as REGENCY CAKESTAND 3 TIER and WHITE HANGING HEART T-LIGHT HOLDER appeared across a large number of invoices, providing stronger evidence of recurring sales activity.

### Merchandise vs Operational Records

Operational stock codes such as **DOT**, **POST**, and **M** were excluded from merchandise product rankings in the Power BI dashboard because they represent operational or service-related records rather than normal merchandise products.

These records were **not deleted from the cleaned dataset**. They were excluded only where necessary to make merchandise-level comparisons meaningful.

Legitimate merchandise codes such as **23084** and **23203** were retained.

### Product Analysis Limitation

The product analysis measures **revenue, units, and order activity**, but the dataset does not contain product cost or gross-margin information.

Therefore, high-revenue products cannot automatically be described as the most profitable products.

The analysis also does not contain inventory availability, stock-out information, supplier costs, or product-level marketing expenditure. These factors would be required for a complete product profitability and demand-planning assessment.






## Recommendations

We'll turn the findings into business actions, such as:

1. Monitor the 337 high-value at-risk customers.
2. Track customer revenue concentration.
3. Investigate the 80,995-unit exceptional transaction.
4. Prepare for strong September–November demand.
5. Evaluate international markets beyond the UK.
6. Separate recurring product demand from exceptional bulk transactions.

## Limitations

We'll explicitly state things like:

- December 2011 is incomplete.
- CustomerID is missing for many transactions.
- Revenue ≠ profit because cost data isn't available.
- Cancellation value isn't the same thing as customer return rate.
- RFM is descriptive, not predictive.
- Dataset is historical 2010–2011 data.





------------Disclaimer /// This report has been refined using AI.-------------