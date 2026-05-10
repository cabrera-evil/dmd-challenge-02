# DMD Challenge 02 — Adventure Works SSAS Cube

An OLAP multidimensional cube built on the **Adventure Works DW 2022** data warehouse, designed for business intelligence analysis of internet and reseller sales.

## Overview

This project defines an Analysis Services (SSAS) multidimensional database with dimensions, fact tables, and partitions for analyzing sales performance across products, territories, and time.

### Dimensions

| Dimension | Description |
|---|---|
| Dim Date | Temporal dimension for time-based slicing |
| Dim Product | Product catalog hierarchy |
| Dim Reseller | Reseller channel data |
| Dim Sales Territory | Geographic sales regions |
| Fact Internet Sales | Direct/online sales transactions |
| Fact Reseller Sales | Channel/reseller sales transactions |

### Key Metrics

- Sales Amount, Order Quantity, Unit Price
- Tax, Freight, Discounts
- Product cost and margin data

## Prerequisites

- SQL Server 2022 (local instance at `127.0.0.1`)
- AdventureWorksDW2022 database
- Visual Studio with SQL Server Data Tools (SSDT)

## Getting Started

1. Restore the **AdventureWorksDW2022** sample database to your local SQL Server instance.
2. Open `dmd-challenge-02.dwproj` in Visual Studio.
3. Deploy the project to your Analysis Services instance.

## Analysis Scripts

Pre-built T-SQL queries are in [`scripts/analysis.sql`](scripts/analysis.sql):

- **Monthly Sales Growth** — current month vs. same period prior year
- **Pareto Analysis** — product categories driving 80% of revenue
- **Territory Performance** — regional sales benchmarked against targets
