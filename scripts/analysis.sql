-- Crecimiento de ventas mensual vs año anterior
WITH MonthlySales AS (
    SELECT 
        d.CalendarYear,
        d.MonthNumberOfYear,
        d.EnglishMonthName,
        SUM(f.SalesAmount) AS TotalSales
    FROM FactInternetSales f
    JOIN DimDate d ON f.OrderDateKey = d.DateKey
    GROUP BY d.CalendarYear, d.MonthNumberOfYear, d.EnglishMonthName
)
SELECT 
    curr.CalendarYear,
    curr.MonthNumberOfYear,
    curr.EnglishMonthName,
    curr.TotalSales AS CurrentYearSales,
    prev.TotalSales AS PreviousYearSales,
    ROUND(
        (curr.TotalSales - prev.TotalSales) / prev.TotalSales * 100, 2
    ) AS GrowthPct
FROM MonthlySales curr
LEFT JOIN MonthlySales prev 
    ON curr.MonthNumberOfYear = prev.MonthNumberOfYear
    AND curr.CalendarYear = prev.CalendarYear + 1
ORDER BY curr.CalendarYear, curr.MonthNumberOfYear;

-- Categorías que representan el 80% de ingresos
WITH CategorySales AS (
    SELECT 
        pc.EnglishProductCategoryName AS Category,
        SUM(f.SalesAmount) AS TotalSales
    FROM FactInternetSales f
    JOIN DimProduct p ON f.ProductKey = p.ProductKey
    JOIN DimProductSubcategory ps ON p.ProductSubcategoryKey = ps.ProductSubcategoryKey
    JOIN DimProductCategory pc ON ps.ProductCategoryKey = pc.ProductCategoryKey
    GROUP BY pc.EnglishProductCategoryName
),
Totals AS (
    SELECT SUM(TotalSales) AS GrandTotal FROM CategorySales
),
Ranked AS (
    SELECT 
        cs.Category,
        cs.TotalSales,
        ROUND(cs.TotalSales / t.GrandTotal * 100, 2) AS PctOfTotal,
        ROUND(
            SUM(cs.TotalSales) OVER (
                ORDER BY cs.TotalSales DESC
                ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
            ) / t.GrandTotal * 100, 2
        ) AS CumulativePct
    FROM CategorySales cs, Totals t
)
SELECT 
    Category,
    ROUND(TotalSales, 2) AS TotalSales,
    PctOfTotal,
    CumulativePct,
    CASE WHEN CumulativePct <= 80 THEN 'Top 80%' ELSE 'Remaining 20%' END AS Pareto
FROM Ranked
ORDER BY TotalSales DESC;

-- Sucursales con bajo rendimiento por geografía
WITH TerritoryPerformance AS (
    SELECT 
        st.SalesTerritoryRegion AS Region,
        st.SalesTerritoryCountry AS Country,
        st.SalesTerritoryGroup AS TerritoryGroup,
        SUM(f.SalesAmount) AS TotalSales,
        COUNT(DISTINCT f.SalesOrderNumber) AS TotalOrders,
        ROUND(AVG(f.SalesAmount), 2) AS AvgOrderValue
    FROM FactResellerSales f
    JOIN DimSalesTerritory st ON f.SalesTerritoryKey = st.SalesTerritoryKey
    GROUP BY 
        st.SalesTerritoryRegion,
        st.SalesTerritoryCountry,
        st.SalesTerritoryGroup
),
Avg AS (
    SELECT AVG(TotalSales) AS OverallAvg FROM TerritoryPerformance
)
SELECT 
    tp.Region,
    tp.Country,
    tp.TerritoryGroup,
    tp.TotalSales,
    tp.TotalOrders,
    tp.AvgOrderValue,
    a.OverallAvg AS BenchmarkSales,
    ROUND((tp.TotalSales - a.OverallAvg) / a.OverallAvg * 100, 2) AS VsAvgPct,
    CASE 
        WHEN tp.TotalSales < a.OverallAvg THEN 'Bajo rendimiento'
        ELSE 'Normal / Alto'
    END AS Performance
FROM TerritoryPerformance tp, Avg a
ORDER BY tp.TotalSales ASC;
