# Sales Performance
# I. Introduction
- Context: In a fast-moving consumer goods (FMCG) trading and distribution company, business data is stored in a dispersed manner across multiple sources, including Excel files sent via email, manual reports from the old ERP software, and data stored on Google Drive/OneDrive for each department
- Business requirement: Management requires the development of a unified reporting system that automates data aggregation and provides business performance analysis reports

# II. Data overview
Data source/file by BU:
- Sales department:
  + sales_transactions
  + sales_target_plan
  + customer_master
  + territory_mapping
  + return_transactions
- Distribution:
  + distributor_orders
  + distributor_master
- HR:
  + employee_master
- Marketing:
  + promotion_program
- Accounting:
  + product_master

# III. Pipeline summary
<img width="1672" height="941" alt="image" src="https://github.com/user-attachments/assets/d884027f-6d7d-489d-971c-6165b1c34041" />

# IV. Final report
## 1. Sales Performance
<img width="1446" height="811" alt="image" src="https://github.com/user-attachments/assets/002391cd-9dad-4dde-9906-a09853071af4" />

## 2. Customer & Product
<img width="1447" height="810" alt="image" src="https://github.com/user-attachments/assets/523c6ed5-50cf-41e6-a20f-2c97196bbff7" />

## 3. Distributors
<img width="1447" height="815" alt="image" src="https://github.com/user-attachments/assets/92ae33ac-c5c5-4c85-a379-c4b812ffe573" />

# V. Conclusion
- This project demonstrates an end-to-end data pipeline for bringing business data into a unified reporting workflow. Python extracts data from Google Drive and loads it into PostgreSQL, where it is organized using a medallion architecture: Bronze for raw data, Silver for cleaned data, and Gold for analytics-ready data. Power BI connects to the database to present business performance through an interactive dashboard.
- The pipeline provides a foundation for reducing manual data consolidation and making reporting more consistent. It can be extended to include additional sources, such as Excel files, ERP reports, and OneDrive, as well as further data-quality checks and automated refreshes.
- This project still needs more improvement to make it automatically update in real time when deploying in real life
